#!/usr/bin/env bash

index=0
while read line; do
    array[$index]="$line"
    index=$(($index+1))
done < ./Scripts/data

first_string="${array[0]}"
user_name=${first_string/login /}

echo "Привет, ${user_name}"
echo "
Введите:

0 - если хотите скачать последнюю версию апк из дженкинса

1 - если хотите обновить/добавить тесты из выбранного фича-файла в TEST REPOSITORY
2 - если хотите обновить/добавить все тесты в TEST REPOSITORY
3 - если хотите обновить андроид смоук прогон в TEST REPOSITORY
4 - если хотите обновить ios смоук прогон в TEST REPOSITORY

5 - если хотите запустить консоль калабаш-андроид
6 - если хотите запустить дефолтный прогон калабаш-андроид
7 - если хотите запустить прогон определенной фичи калабаш-андроид
8 - если хотите запустить прогон по тэгу калабаш-андроид

9 - если хотите запустить консоль калабаш-айос
10 - если хотите запустить дефолтный прогон калабаш-айос
11 - если хотите запустить прогон определенной фичи калабаш-айос
12 - если хотите запустить прогон по тэгу калабаш-айос
"

file_path= echo $PWD
read p

 if [ $p = 0 ]; then
    ruby -r "./scripts/get_apk.rb" -e "GetApk.new('$file_path').download_apk"

elif [ $p = 1 ]; then
    sh ./Scripts/update.sh

 elif [ $p = 2 ]; then
    ruby -r "./scripts/import_scenarios.rb" -e "Scenarios.new('$file_path').import_scenarios"

 elif [ $p = 3 ]; then
    five_string="${array[5]}"
    exec_key=${five_string/key_execution_and /}

    while true; do
        read -p "Хотите обновить андроид прогон ${exec_key}? (yes or no)" yn
        case $yn in
             [Nn]* ) exit;;
             * ) ruby -r "./scripts/update_exec.rb" -e "Execution.new('$file_path').update_test_execution('${exec_key}')";
             break;;
        esac
    done

 elif [ $p = 4 ]; then
    six_string="${array[6]}"
    exec_key=${six_string/key_execution_ios /}

    while true; do
        read -p "Хотите обновить ios прогон ${exec_key}? (yes or no)" yn
        case $yn in
             [Nn]* ) exit;;
             * ) ruby -r "./scripts/update_exec.rb" -e "Execution.new('$file_path').update_test_execution('${exec_key}')";
             break;;
        esac
    done

 elif [ $p = 5 ]; then
    sh ./Scripts/ca.sh

 elif [ $p = 6 ]; then
    sh ./Scripts/and.sh

 elif [ $p = 7 ]; then
    echo "Введите название фичи для прогона из папки features/scenarios/name.feature в формате <name>"
    read name
    sh ./Scripts/fa.sh $name

 elif [ $p = 8 ]; then
    echo "Введите тэг для прогона из папки в формате <tag>"
    read tag
    sh ./Scripts/ta.sh $tag

 elif [ $p = 9 ]; then
    sh ./Scripts/ci.sh

 elif [ $p = 10 ]; then
    sh ./Scripts/ios.sh

 elif [ $p = 11 ]; then
    echo "Введите название фичи для прогона из папки features/scenarios/name.feature в формате <name>"
    read name
    sh ./Scripts/fi.sh $name

 elif [ $p = 12 ]; then
    echo "Введите тэг для прогона из папки в формате <tag>"
    read tag
    sh ./Scripts/ti.sh $tag

 fi