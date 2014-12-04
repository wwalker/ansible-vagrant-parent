#!/bin/bash

git clone http://git-wip-us.apache.org/repos/asf/incubator-aurora.git
cd incubator-aurora
./gradlew distZip

cp dist/distributions/aurora-scheduler-*.zip ..
