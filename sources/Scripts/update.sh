#!/usr/bin/env bash

echo "введите название фича файла с обновленными тестами из папки features/scenarios/name.feature в формате <name>"
echo "enter feature file name with updated tests from dir features/scenarios/name.feature in format <name>"

read path

index=0
while read line; do
    array[$index]="$line"
    index=$(($index+1))
done < ./Scripts/data

first_string="${array[0]}"
username=${first_string/login /}

second_string="${array[1]}"
password=${second_string/jira_pass /}

third_string="${array[2]}"
code=${third_string/project_key /}


curl  -H "Content-Type: multipart/form-data" -u  $username:$password -F "file=@features/scenarios/$path.feature" https://jira.surfstudio.ru/rest/raven/1.0/import/feature?projectKey=$code