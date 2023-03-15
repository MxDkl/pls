#!/bin/bash

# add your openai api key here
token="sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# disable globbing, to prevent OpenAI's command from being prematurely expanded
set -f

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

# parse the 'content' field of the response which is in JSON format
command=$(echo $response | jq -r '.choices[0].message.content')

# echo the command
echo -e -n "\033[0;31m" # set color to red
echo $command

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

# re-enable globbing
set +f

# execute the command
echo -e -n "\033[0;34m" # set color to blue
eval "$command"

# navigate back to the original working directory
cd $cwd
