#!/bin/bash

echo "===== RUNNING SMOKE SUITE ANDROID====================="
calabash-android run L.apk -p android -p html_report -t @smoke

