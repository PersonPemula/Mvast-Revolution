#!/system/bin/sh

#____________________________________
# Mvest Copyright © REXX FLOSS™
# Edited by @PersonPenggoreng
# Recode at 17-12 - 23.08
#____________________________________

wait_until_login() {
while [[ `getprop sys.boot_completed` -ne 1 && -d "/sdcard" ]]
do
sleep 2
done
local test_file="/sdcard/.PERMISSION_TEST"
touch "$test_file"
while [ ! -f "$test_file" ]; do
touch "$test_file"
sleep 2
done
rm "$test_file"
}

wait_until_login

file="/storage/emulated/0/MvastUniversal.log"

if [ ! -f "$file" ]; then
    touch "$file"
    echo "File mvast.log telah dibuat."
else
    echo "File mvast.log sudah ada."
fi

sleep 5

sh /data/adb/modules/mvast-rev/mvast/mvast-service.sh