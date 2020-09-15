#!/bin/bash

echo "===== RUNNING TEST SUITE IOS ====================="
cucumber -p ios -t @$1

