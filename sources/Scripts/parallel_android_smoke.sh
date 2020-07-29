#!/usr/bin/env bash

echo "===== PARLLEL RUNNING SMOKE SUITE ANDROID====================="
parallel_calabash -a L.apk -o '-p android -f pretty -f html -o outputs/report.html -t @smoke' features/ --concurrent