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


# Utils
To find your ip on network
```console
./sd-card.rb --scan fiyeli-Emil-Fischer
```
