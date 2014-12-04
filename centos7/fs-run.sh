#!/bin/bash

sudo docker run -d --net=host -v $PWD/data:/data naelyn/fileserve
