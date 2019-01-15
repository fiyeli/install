# Create the SD card
## Requirements 
In order to run the SD-maker script written in Ruby, you have to install some dependencies.
Open a Terminal, go into the project repository and complete the following steps if needed :
```bash
sudo apt install ruby ruby-dev gem kpartx nmap sshpass hwinfo  
sudo gem install bundle
sudo bundle install
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
