#!/usr/bin/env bash

source ./lib/dm/helper.sh


echo "--- is_int ---"
echo "Is 7 integer?"
if is_int "7"; then echo 'True'
else echo 'False'
fi
echo

echo "--- empty ---"
# BLANK=""
echo "Is $BLANK empty?"
empty "$BLANK"
if [ $? -eq 0 ]; then echo "True"
else echo "False"
fi
echo

echo "--- file_exists ---"
FILE="/etc/hosts"
echo "Is '$FILE' exists?"
file_exists "$FILE"
if [ $? -eq 0 ]; then echo "True"
else echo "False"
fi
echo

echo "--- dir_exists ---"
DIR="/var"
echo "Is '$DIR' exists?"
dir_exists "$DIR"
if [ $? -eq 0 ]; then echo "True"
else echo "False"
fi
echo

echo "--- test ---"
echo "- Accepts function"
echo_haha()
{
    echo "haha"
}
[ $(test echo_haha) = "haha" ] && echo "True"
echo

echo "- Accepts returned value"
[ 1 -eq 1 ]
test $? --te "True" --fe "False"
echo

echo "- Echo when accpeted function return, or accepted returned value is equal to, 0"
test echo_haha --te "True"
echo

echo "- Echo when accpeted function return, or accepted returned value is equal to, 1"
[ 1 -eq 0 ]
test $? --fe "True"
echo

echo "- Execute callback when argument returns, or is, 0"
test echo_haha --txec "echo True"
echo

echo "- Execute callback when argument returns, or is, 1"
[ 1 -eq 0 ]
test $? --fxec "echo True"
echo

echo "--- is_int ---"
INT="100"
echo "Is $INT an integer?"
test --te "TRUE!!!" --fe "FALSE!!!" --txec "echo TRUE EXECUTION!" --fxec "echo FALSE EXECUTION!" is_int $INT
echo

INT="100a"
echo "Is $INT an integer?"
test --te "TRUE!!!" --fe "FALSE!!!" --txec "echo TRUE EXECUTION!" --fxec "echo FALSE EXECUTION!" is_int $INT
echo

echo 'Not exit!'