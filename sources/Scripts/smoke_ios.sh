#!/bin/bash

echo "===== RUNNING SMOKE SUITE IOS ====================="
cucumber -p ios -p html_report -t @smoke

