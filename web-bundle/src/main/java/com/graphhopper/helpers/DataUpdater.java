package com.graphhopper.helpers;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.graphhopper.GraphHopper;
import com.graphhopper.routing.util.EdgeFilter;
import com.graphhopper.routing.util.FlagEncoder;
import com.graphhopper.storage.Graph;
import com.graphhopper.storage.index.LocationIndex;
import com.graphhopper.storage.index.QueryResult;
import com.graphhopper.util.EdgeIteratorState;
import com.graphhopper.util.shapes.GHPoint;
import gnu.trove.set.hash.TIntHashSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.Lock;


/**
 * Shamelessly copying from
 * https://github.com/karussell/graphhopper-traffic-data-integration/pull/3/files
 */
public class DataUpdater {

    class Point {

        public final double lat;
        public final double lon;

        public Point(double lat, double lon) {
            this.lat = lat;
            this.lon = lon;
        }

        public GHPoint toGHPoint() {
            return new GHPoint(lat, lon);
        }

        @Override
        public String toString() {
            return lat + ", " + lon;
        }
    }

    class RoadEntry {

        private List<Point> points;
        private double value;
        private String valueType;
        private String mode;
        private String id;

        public RoadEntry() {
        }

        public RoadEntry(String id, List<Point> points, double value, String valueType, String mode) {
            this.points = points;
            this.value = value;
            this.valueType = valueType;
            this.mode = mode;
            this.id = id;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public List<Point> getPoints() {
            return points;
        }

        public void setPoints(List<Point> points) {
            this.points = points;
        }

        public void setValue(double value) {
            this.value = value;
        }

        public double getValue() {
            return value;
        }

        public void setValueType(String type) {
            this.valueType = type;
        }

        /**
         * E.g. speed or any
         */
        public String getValueType() {
            return valueType;
        }

        /**
         * Currently 'replace', 'multiply' and 'add' are supported
         */
        public String getMode() {
            return mode;
        }

        public void setMode(String mode) {
            this.mode = mode;
        }

        @Override
        public String toString() {
            return "points:" + points + ", value:" + value + ", type:" + valueType + ", mode:" + mode;
        }
    }

    public class RoadData extends ArrayList<RoadEntry> {

    }


    @Inject
    private GraphHopper hopper;

    @Inject
    private ObjectMapper objectMapper;

    private final Logger logger = LoggerFactory.getLogger(getClass());
    private final Lock writeLock;
    private final long seconds = 150;
    private RoadData currentRoads;

    public DataUpdater(Lock writeLock) {
        this.writeLock = writeLock;
    }

    public void feed(RoadData data) {
        writeLock.lock();
        try {
            logger.info("Feeding data");
            lockedFeed(data);
        } finally {
            writeLock.unlock();
        }
    }

    private void lockedFeed(RoadData data) {
        currentRoads = data;
        Graph graph = hopper.getGraphHopperStorage();
        FlagEncoder carEncoder = hopper.getEncodingManager().getEncoder("car");
        LocationIndex locationIndex = hopper.getLocationIndex();

        int errors = 0;
        int updates = 0;
        TIntHashSet edgeIds = new TIntHashSet(data.size());

        logger.info("Got {} entries for loading", data.size());
        for (RoadEntry entry : data) {

            // TODO get more than one point -> our map matching component
            Point point = entry.getPoints().get(entry.getPoints().size() / 2);
            QueryResult qr = locationIndex.findClosest(point.lat, point.lon, EdgeFilter.ALL_EDGES);
            if (!qr.isValid()) {
                // logger.info("no matching road found for entry " + entry.getId() + " at " + point);
                errors++;
                continue;
            }

            int edgeId = qr.getClosestEdge().getEdge();
            if (edgeIds.contains(edgeId)) {
                // TODO this wouldn't happen with our map matching component
                errors++;
                continue;
            }

            edgeIds.add(edgeId);
            EdgeIteratorState edge = graph.getEdgeIteratorState(edgeId, Integer.MIN_VALUE);
            double value = entry.getValue();
            if ("replace".equalsIgnoreCase(entry.getMode())) {
                if ("speed".equalsIgnoreCase(entry.getValueType())) {
                    double oldSpeed = carEncoder.getSpeed(edge.getFlags());
                    if (oldSpeed != value) {
                        updates++;
                        // TODO use different speed for the different directions (see e.g. Bike2WeightFlagEncoder)
                        logger.info("Speed change at " + entry.getId() + " (" + point + "). Old: " + oldSpeed + ", new:" + value);
                        edge.setFlags(carEncoder.setSpeed(edge.getFlags(), value));
                    }
                } else {
                    throw new IllegalStateException("currently no other value type than 'speed' is supported");
                }
            } else {
                throw new IllegalStateException("currently no other mode than 'replace' is supported");
            }
        }

        logger.info("Updated " + updates + " street elements of " + data.size() + ". Unchanged:" + (data.size() - updates) + ", errors:" + errors);
    }

    private final AtomicBoolean running = new AtomicBoolean(false);


    public void stop() {
        running.set(false);
    }

    public RoadData getAll() {
        if (currentRoads == null) {
            return new RoadData();
        }

        return currentRoads;
    }

    private class TrafficFeature {
        @JsonProperty("attributes")
        public TrafficAttributes attributes;

        @JsonProperty("geometry")
        public TrafficGeometry geometry;
    }

    private class TrafficAttributes {
        @JsonProperty("IDENTIFIER")
        public String identifier;

        @JsonProperty("AUSLASTUNG")
        public Integer auslastung;
    }

    private class TrafficGeometry {
        @JsonProperty("paths")
        public List<List<List<Double>>> paths;
    }
}