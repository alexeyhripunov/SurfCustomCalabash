#!/usr/bin/env bash
echo "enter json name with tests form file name.json in root dir in format <name>"

read json

echo "\nвведите код прогона TEST-EXECUTION в формате <BZN-344>"
echo "\nenter exec key TEST-EXECUTION in format <KEYPROJ-344>"

read code


username=$(head -n 2 ./Scripts/user | tail -n 1)
password=$(head -n 3 ./Scripts/user | tail -n 1)





curl -H "Content-Type: application/json" -X POST -u $username:$password --data @$json.json https://jira.surfstudio.ru/rest/raven/1.0/api/testexec/$code/test
