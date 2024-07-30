#!/bin/bash

image=pmliquify/torizon-v4l2-test

docker login
docker build -t ${image} . 
docker push ${image}