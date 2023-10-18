# Please CLI

Please is a CLI tool that translates natural language into shell commands.

Installation:
- clone this repo
- configure your ~/.pls config file with your openai api key
- chmod +x pls
- add pls to your path

Requirements:
- jq binary (commandline JSON processor)
- curl binary (commandline HTTP client)
- openai api key

Usage:
```
pls [natural language command]
```
Examples:
```
pls list all files in the current directory
pls list all files in the current directory that contain "foo"
pls make a directory called "foo" with 3 files in it that each have 1000 random words
pls use iptables to forward all traffic from port 80 to port 8501
pls zip all files in the current directory that contain the word "foo" and save to desktop
```

Warning:
- be careful when running as root because it is unpredictable and could do anything

Configure your ~/.pls config file with your openai api key:
```bash
cat <<EOF > ~/.pls
{
"api_key": "your api key",
"api_base": "https://api.openai.com/v1",
"model": "gpt-4-0613"
}
EOF
```
