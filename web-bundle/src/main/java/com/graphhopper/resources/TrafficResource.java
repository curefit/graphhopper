/*
 *  Licensed to GraphHopper GmbH under one or more contributor
 *  license agreements. See the NOTICE file distributed with this work for
 *  additional information regarding copyright ownership.
 *
 *  GraphHopper GmbH licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.graphhopper.resources;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.graphhopper.GraphHopper;
import com.graphhopper.helpers.DataUpdater;
import com.graphhopper.routing.util.EdgeFilter;
import com.graphhopper.storage.index.LocationIndex;
import com.graphhopper.storage.index.QueryResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * This class defines a new endpoint to submit access and speed changes to the graph.
 *
 * @author Peter Karich
 * @author Michael Zilske
 *
 */
@Path("traffic")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class TrafficResource {

    private DataUpdater dataUpdater;
    private Logger logger = LoggerFactory.getLogger(RouteResource.class);
    private Lock dataFeedLock = new ReentrantLock();

    private GraphHopper graphHopper;

    @Inject
    TrafficResource(GraphHopper graphHopper) {
        logger.info("graphhopper is null ?: {}", graphHopper != null ? true : false);

        this.graphHopper = graphHopper;
        this.dataUpdater = new DataUpdater(dataFeedLock, graphHopper);
    }

    @POST
    @Path("feed")
    @Consumes({MediaType.APPLICATION_JSON})
    public void feed(String body){

        try {
            logger.info("Got call to update data");
            ObjectMapper objectMapper = new ObjectMapper();
            DataUpdater.RoadData roadData = objectMapper.readValue(body, DataUpdater.RoadData.class);
            logger.info("To update data {}", roadData);
            this.dataUpdater.feed((roadData));
        } catch (Exception e){
            this.logger.error("Error while feeding data", e);
        }
    }


    @GET
    @Path("closestEdge")
    @Produces({MediaType.APPLICATION_JSON})
    public Map closestPoint(@QueryParam("latlon") String latlon){

        Map<String, Object> resp = new HashMap();
        try {
            Double lat = Double.parseDouble(latlon.split(",")[0]);
            Double lon = Double.parseDouble(latlon.split(",")[1]);

            logger.info("Call to get closest point lat {}  lon {}", lat, lon);
            LocationIndex locationIndex = graphHopper.getLocationIndex();
            QueryResult closest = locationIndex.findClosest(lat, lon, EdgeFilter.ALL_EDGES);
            resp.put("closest", closest);
            resp.put("way", closest.getClosestEdge().fetchWayGeometry(1).toString());
            return resp;
        } catch (Exception e){
            this.logger.error("Error while feeding data", e);
            throw e;
        }
    }


}
