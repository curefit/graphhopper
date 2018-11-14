#true is given so that even if the container doesn't exists, the command should not fail, because if the command fails, it will fail the CodeDeploy process also.
sudo docker stop graphhopper-traffic || true
sudo docker rm graphhopper-traffic || true
sudo rm -rf /home/ubuntu/graphhopper-traffic