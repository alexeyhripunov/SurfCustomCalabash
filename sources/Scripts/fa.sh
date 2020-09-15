#!/bin/bash

echo "===== RUNNING TEST SUITE ANDROID====================="
echo "$1"
calabash-android run L.apk -p android features/scenarios/$1

