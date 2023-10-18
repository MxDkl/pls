#!/bin/bash

function error_out(){
    local _message=$1
    echo -e -n "\033[0;31m" # set color to red
    echo "${_message}"
    exit 1
}

function check_var(){
    local _var=$1
    local _name=$2
    if [ -z "${_var}" ]; then
        error_out "Error: ${_name} not set."
    fi
}

# returns the value or the default value if the value is not set
function get_var(){
    local _var=$1
    local _default=$2
    if [ -z "${_var}" ]; then
        echo "${_default}"
    else
        echo "${_var}"
    fi
}

# read the file ~/.pls to get the json config, if the file exists
if [ -f ~/.pls ]; then
  json_config=$(cat ~/.pls)
else
  error_out "Error: ~/.pls file not found."
fi

# read the api key, base url, and model from the json config
openai_api_key=$(get_var $(jq -r '.api_key' <<< "$json_config") '')
openai_api_base=$(get_var $(jq -r '.api_base' <<< "$json_config") 'https://api.openai.com/v1')
openai_model=$(get_var $(jq -r '.model' <<< "$json_config") 'gpt-4-0613')

# check all required variables are set
check_var $openai_api_key 'openapi api key'

# exit if no command is given
if [ -z "$1" ]; then
  error_out "Error: no command given."
fi

# get user cli arguments as a string
args=$*

# save the current working directory to a variable
cwd=$(pwd)

# save os name to a variable
if [[ -f /etc/*-release ]]; then
    os=$(cat /etc/*-release | grep "NAME" -m 1 | cut -d "=" -f 2 | sed 's/"//g' | tr ' ' '_')
else
  os=$(uname -s)
fi

# disable globbing, to prevent OpenAI's command from being prematurely expanded
set -f

# use curl to get openai api response
response=$(curl -s ${openai_api_base}/chat/completions \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer '$openai_api_key'' \
  -d '{
  "model": "'$openai_model'",
  "messages": [{"role": "system", "content": "You are a helpful assistant. You will generate '$SHELL' commands based on user input. Your response should contain ONLY the command and NO explanation. Do NOT ever use newlines to seperate commands, instead use ; or &&. The operating system is '$os'. The current working directory is '$cwd'."}, {"role": "user", "content": "'"$args"'"}],
  "temperature": 0.0
}')

# if OpenAI reported an error, tell the user, then exit the script
error=$(echo $response | jq -r '.error.message')
if [ "$error" != "null" ]
then
    echo -e -n "\033[0;31m" # set color to red
    echo "Error from OpenAI API:"
    echo $error
    echo "Aborted."
    exit 1
fi

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
echo -e "\033[0m" # reset color
eval "$command"

# navigate back to the original working directory
cd $cwd
