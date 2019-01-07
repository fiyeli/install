#!/usr/bin/env ruby

require 'tty-prompt'
require 'ruby-progressbar'
require 'mkmf'
require 'open-uri'
require 'open_uri_redirections'
require 'fileutils'
require 'zip'
require 'faker'

# TODO: understand if we have to use loop0p1 or mm**1
# or we have to write before to dd image !
# we have to forgot loop0p1 ....
# dd must be last step

TMP_RASPBIAN = '/tmp/raspbian_lite_latest'.freeze
TMP_RASPBIAN_IMG = '/tmp/raspbian-stretch-lite.img'.freeze
TMP_BUILDING_IMG = '/tmp/fiyeli.img'.freeze
TMP_MOUNT_ENDPOINT = '/tmp/raspmount'.freeze
TMP_WPA_SUPPLICANT = '/tmp/wpa-supplicant'.freeze

DEV_MAPPER = nil

def exec_with_sudo(cmd, message)
  res = ""
  if ENV['USER'] != 'root'
    puts message
    puts "CMD: sudo #{cmd}"
    res = `sudo #{cmd}`
    puts "RES: #{res}"
  else
    res = `#{cmd}`
  end
  return res
end

def shut_down
  puts 'sync'
  `sync`
  puts "\n remove kpartx partition"
  cmd_kpartx = "kpartx -v -d #{TMP_BUILDING_IMG}"
  exec_with_sudo(cmd_kpartx, 'need root access to use kpartx')
  puts "\n umount gracefully..."
  cmd_umount = "umount #{TMP_MOUNT_ENDPOINT}"
  exec_with_sudo(cmd_umount,
                 "need root access to umount sd card on #{TMP_MOUNT_ENDPOINT}")
end

def mount_part(disk)
  cmd_mount = "mount #{disk} #{TMP_MOUNT_ENDPOINT}"
  puts 'mount sd on /tmp/sdcard'
  FileUtils.mkdir_p(TMP_MOUNT_ENDPOINT) unless File.exist?(TMP_MOUNT_ENDPOINT)

  exec_with_sudo(cmd_mount,
                 "need root access to mount sd card on #{TMP_MOUNT_ENDPOINT}")
end

prompt = TTY::Prompt.new

required_bin = %w[tail kpartx]
required_bin.each do |bin|
  unless find_executable(bin)
    STDERR.puts("ABORTED! You have to install #{bin}")
    exit(false)
  end
end

exlude_dist_contains = ['nvme']
disk = `lsblk --noheadings --raw -o NAME,MOUNTPOINT \
 | awk '$1~/[[:digit:]]/ && $2 == ""'`
       .lines.map { |e| "/dev/#{e.chomp}" }
       .delete_if do |element|
  exlude_dist_contains.any? { |e| element.include?(e) }
end
sd = prompt.select('Choose your disk?', disk).split[0].inspect

if File.file?(TMP_RASPBIAN)
  puts "raspbian is already download here #{TMP_RASPBIAN}"
else
  puts 'download latest raspbian'
  pbar = nil
  download = open('https://downloads.raspberrypi.org/raspbian_lite_latest', \
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

# copy the raw raspbian image to building image
`cp #{TMP_RASPBIAN_IMG} #{TMP_BUILDING_IMG}`
# use kpartx / kpartx create simlink
cmd_kpartx = "sudo kpartx -v -a #{TMP_BUILDING_IMG}"
# should be like loop0p1,loop0p2
DEV_MAPPER = exec_with_sudo(cmd_kpartx, 'need root access to use kpartx')
             .scan(/(loop.*)\s\(/)
puts DEV_MAPPER

puts('set up boot partition')
mount_part("/dev/mapper/#{DEV_MAPPER[0].first}")

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

# unmounted boot partition
puts 'sync'
`sync`
cmd_umount = "umount #{TMP_MOUNT_ENDPOINT}"
exec_with_sudo(cmd_umount,
               "need root access to umount sd card on #{TMP_MOUNT_ENDPOINT}")

puts('end setting boot partition')
mount_part("/dev/mapper/#{DEV_MAPPER[1].first}")

cmd_hostname = "echo  fiyeli-#{Faker::Science.scientist.gsub!(/\s/, '-')} "\
             " | sudo tee #{TMP_MOUNT_ENDPOINT}/etc/hostname"
exec_with_sudo(cmd_hostname,
               "need root access to umount sd card on #{TMP_MOUNT_ENDPOINT}")

cmd_dd = "dd if=#{TMP_BUILDING_IMG} of=#{sd} \
bs=4M conv=fsync status=progress"
exec_with_sudo(cmd_dd, 'need root access to dd image on sd card')

shut_down
