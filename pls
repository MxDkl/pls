#!/bin/bash

# add your openai api key here
token="sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# get user cli arguments as a string
args=$*

# save the current working directory to a variable
cwd=$(pwd)

# use curl to get openai api response
response=$(curl -s https://api.openai.com/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer '$token'' \
  -d '{
  "model": "gpt-3.5-turbo",
  "messages": [{"role": "system", "content": "You are a helpful assistant. You will generate '$SHELL' commands based on user input. Your response should contain ONLY the command and NO explanation. Do NOT ever use newlines to seperate commands, instead use ; or &&. The current working directory is '$cwd'."}, {"role": "user", "content": "'"$args"'"}]
}')

# echo the 'content' field of the response which is in JSON format
echo -e -n "\033[0;31m" # set color to red
echo $response | jq '.choices[0].message.content' | sed -e 's/^.//' -e 's/.$//'

# make the user confirm the command
echo -e -n "\033[0;34m" # set color to blue
read -n 1 -s -r -p "Press any button to continue, or n to cancel: "

# if the user presses n, exit the script
if [[ $REPLY =~ ^[Nn]$ ]]
then
    echo -e -n "\033[0;31m" # set color to red
    echo $REPLY
    echo "Aborted."
    exit 0
fi
echo -e -n "\033[0;32m" # set color to green
echo $REPLY
echo "Executing command..."
echo ""

# save command to file, execute the command from file, remove the file
echo $response | jq '.choices[0].message.content' | sed -e 's/^.//' -e 's/.$//' > ".tempplscmd"
echo -e -n "\033[0;34m" # set color to blue
source ".tempplscmd"
cd $cwd
rm ".tempplscmd"