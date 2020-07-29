#!/bin/bash

echo "===== RUNNING TEST SUITE IOS ====================="
cucumber -p ios features/scenarios/$1

