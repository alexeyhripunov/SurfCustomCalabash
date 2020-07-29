#!/usr/bin/env bash

echo "===== PARLLEL RUNNING TEST SUITE ANDROID====================="
parallel_calabash -a L.apk -o '-p android -f pretty -f html -o reports/'<%= ENV['DEVICE_INFO']%>'.html -t @test' features/ --concurrent