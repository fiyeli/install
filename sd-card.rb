#!/usr/bin/env ruby

require 'tty-prompt'
require 'ruby-progressbar'
require 'mkmf'
require 'open-uri'
require 'open_uri_redirections'
require 'fileutils'
require 'zip'

TMP_RASPBIAN = '/tmp/raspbian_latest'.freeze
TMP_RASPBIAN_IMG = '/tmp/raspbian.img'.freeze
TMP_MOUNT_ENDPOINT = '/tmp/raspmount'.freeze
TMP_WPA_SUPPLICANT = '/tmp/wpa-supplicant'.freeze

def exec_with_sudo(cmd, message)
  if ENV['USER'] != 'root'
    puts message
    system("sudo #{cmd}")
  else
    system(cmd)
  end
end

prompt = TTY::Prompt.new

required_bin = %w[tail hwinfo kpartx]
required_bin.each do |bin|
  unless find_executable(bin)
    STDERR.puts("ABORTED! You have to install #{bin}")
    exit(false)
  end
end

disk = `hwinfo --short --disk | tail -n +2`.lines.map(&:chomp)

sd = prompt.select('Choose your disk?', disk).split[0].inspect

if File.file?(TMP_RASPBIAN)
  puts "raspbian is already download here #{TMP_RASPBIAN}"
else
  puts 'download latest raspbian'
  pbar = nil
  download = open('https://downloads.raspberrypi.org/raspbian_latest', \
                  allow_redirections: :all, \
                  content_length_proc: lambda { |t|
                    pbar = ProgressBar.create(total: t) if t && t > 0
                  },

                  progress_proc: lambda { |s|
                    pbar.progress = s if pbar
                  })
  IO.copy_stream(download, TMP_RASPBIAN)
end

if File.file?(TMP_RASPBIAN_IMG)
  puts "raspbian already unziped here #{TMP_RASPBIAN_IMG}"
else
  puts 'unzip raspian'
  Zip::File.open(TMP_RASPBIAN) do |zip_file|
    # Find specific entry
    entry = zip_file.glob('*.img').first
    # Extract to file/directory/symlink
    puts "Extracting #{entry.name}"
    entry.extract(TMP_RASPBIAN_IMG)
  end
end
cmd_dd = "dd if=#{TMP_RASPBIAN_IMG} of=#{sd} \
bs=4M conv=fsync status=progress"
exec_with_sudo(cmd_dd, 'need root access to dd image on sd card')

# use kpartx / kpartx create simlink
cmd_kpartx = "sudo kpartx -a #{TMP_RASPBIAN_IMG}"
exec_with_sudo(cmd_kpartx, 'need root access to use kpartx')

cmd_mount = "mount /dev/mapper/loop0p1 #{TMP_MOUNT_ENDPOINT}"
puts 'mount sd on /tmp/sdcard'
FileUtils.mkdir_p(TMP_MOUNT_ENDPOINT) unless File.exist?(TMP_MOUNT_ENDPOINT)

exec_with_sudo(cmd_mount,
               "need root access to mount sd card on #{TMP_MOUNT_ENDPOINT}")
def shut_down
  puts "\n umount gracefully..."
  cmd_umount = "umount #{TMP_MOUNT_ENDPOINT}"
  exec_with_sudo(cmd_umount,
                 "need root access to umount sd card on #{TMP_MOUNT_ENDPOINT}")
end

# Trap ^C
Signal.trap('INT') do
  shut_down
  exit
end

# Trap `Kill `
Signal.trap('TERM') do
  shut_down
  exit
end

cmd_touch = "echo 'make ssh file at boot' | sudo tee #{TMP_MOUNT_ENDPOINT}/ssh"
exec_with_sudo(cmd_touch, 'need root to touch ssh at /boot')

# TODO: https://howchoo.com/g/ote0ywmzywj/how-to-enable-ssh-on-raspbian-without-a-screen

ssid = prompt.ask('Give me your SSID ?')
passwd = prompt.ask('Give me your password ?')
File.open(TMP_WPA_SUPPLICANT, 'w') do |file|
  file.write("ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
network={
    ssid=\"#{ssid}\"
    psk=\"#{passwd}\"
    key_mgmt=WPA-PSK
}")
end
cmd_create_wpa_supplicant =
  "cp #{TMP_WPA_SUPPLICANT} #{TMP_MOUNT_ENDPOINT}/wpa_supplicant.conf"
exec_with_sudo(cmd_create_wpa_supplicant,
               'need root to mv wpa_supplicant.conf at /boot')

shut_down
