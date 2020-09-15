#!/bin/bash

password=12345678
alias=my

echo "===== RUNNING SIGNING  ====================="

static_param="{\"keystore_location\":\"my.keystore\",\"keystore_password\":\"12345678\",\"keystore_alias\":\"my\"}"
echo $static_param > /.calabash_settings
calabash-android resign L.apk


