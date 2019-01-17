# Create the SD card
## Requirement
You will need ruby to create the SD card. You can use [rbenv](https://github.com/rbenv/rbenv) or install Ruby on your computer.
You will anyway have to install some dependencies.
Open a Terminal, go into the project repository and complete the following steps if needed :
```bash
sudo apt install ruby ruby-dev gem # If you don't use rbenv
sudo apt install kpartx nmap sshpass hwinfo net-tools
```
For the following command you have to add sudo if you don't use rbenv.
```bash
gem update --system
gem install bundle
bundle install
```
## Run the SD-maker
You can run the SD-Maker script by executing the following command :
```console
./sd-card.rb
```
It will :
- Download, extract and mount the latest Raspbian Image
- Ask for your SSID / wifi password 

# Run installation on Raspberry Pi
Once the SD-maker script is over, plug the micro-sd card in the Raspberry.
The Fiyeli installation Ansible material is in the 'ansible' folder :
```console
cd ansible
```

## Installation
First, update your 'hosts' file with your server ip.

Then run the Ansible installation script: 
```console
ansible-playbook playbook.yml -i hosts --ask-pass -c paramiko -vv
```

## Troubleshooting
- Mismatch key :
```
fatal: [192.168.43.234]: UNREACHABLE! => {"changed": false, "msg": "host key mismatch for 192.168.43.234", "unreachable": true}
```
Host key of the remote host was changed. Either your are being attacked by a Man-in-the-Middle type attack or you re-installed your raspberry pi without changing it's IP address.

If your are sure to be in the second case (most likely), you can disable Ansible host key checking :
```console
export ANSIBLE_HOST_KEY_CHECKING=False
```
And then run again the network scan (see Utils section).


# Utils
To find the ip of the Raspberry on the network given its name, run :
```console
./sd-card.rb --scan {Raspberry name}
# For example : ./sd-card.rb --scan fiyeli-Crazy-Cat-Lady
```
