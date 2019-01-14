#!/usr/bin/env ruby

require 'optparse'
require 'tty-prompt'
require 'ruby-progressbar'
require 'mkmf'
require 'open-uri'
require 'open_uri_redirections'
require 'fileutils'
require 'zip'
require 'faker'

TMP_RASPBIAN = '/tmp/raspbian_lite_latest'.freeze
TMP_RASPBIAN_IMG = '/tmp/raspbian-stretch-lite.img'.freeze
TMP_BUILDING_IMG = '/tmp/fiyeli.img'.freeze
TMP_MOUNT_ENDPOINT = '/tmp/raspmount'.freeze
TMP_WPA_SUPPLICANT = '/tmp/wpa-supplicant'.freeze

PROMPT = TTY::Prompt.new

def exec_with_sudo(cmd, message)
  res = ''
  if ENV['USER'] != 'root'
    puts message
    puts "CMD: sudo #{cmd}"
    res = `sudo #{cmd}`
    puts "RES: #{res}"
  else
    res = `#{cmd}`
  end
  res
end

def shut_down
  # nothing for the moment
end

def mount_part(disk)
  cmd_mount = "mount #{disk} #{TMP_MOUNT_ENDPOINT}"
  puts 'mount sd on /tmp/sdcard'
  FileUtils.mkdir_p(TMP_MOUNT_ENDPOINT) unless File.exist?(TMP_MOUNT_ENDPOINT)

  exec_with_sudo(cmd_mount,
                 "need root access to mount sd card on #{TMP_MOUNT_ENDPOINT}")
end

def check_prerequisite
  required_bin = %w[tail kpartx nmap sshpass hwinfo]
  required_bin.each do |bin|
    unless find_executable(bin)
      STDERR.puts("ABORTED! You have to install #{bin}")
      exit(false)
    end
  end
end

def find_disk
  exlude_dist_contains = %w[nvme sdb sda ram loop]
  disk = `hwinfo --short --disk | tail -n +2`.lines.map(&:chomp)
                                             .delete_if do |element|
    exlude_dist_contains.any? { |e| element.include?(e) }
  end
  abort('no device found') if disk.empty?
  sd = PROMPT.select('Choose your disk?', disk).split[0].inspect
  sd
end

def check_before_downlaod
  if File.file?(TMP_RASPBIAN)
    puts "raspbian is already download here #{TMP_RASPBIAN}"
    false
  else
    puts 'download latest raspbian'
    true
  end
end

def download_latest_zip
  return unless check_before_downlaod

  pbar = nil
  download = open('https://downloads.raspberrypi.org/raspbian_lite_latest', \
                  allow_redirections: :all, \
                  content_length_proc: lambda { |t|
                    pbar = ProgressBar.create(total: t) if t && t > 0
                  }, progress_proc: lambda do |s|
                                      pbar.progress = s if pbar
                                    end)
  IO.copy_stream(download, TMP_RASPBIAN)
end

def unzip_img
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
end

def download_and_extract
  download_latest_zip
  unzip_img
end

def prepare_img
  # copy the raw raspbian image to building image
  `cp #{TMP_RASPBIAN_IMG} #{TMP_BUILDING_IMG}`
  # use kpartx / kpartx create simlink
  cmd_kpartx = "sudo kpartx -v -a #{TMP_BUILDING_IMG}"
  # should be like loop0p1,loop0p2
  dev_mapper = exec_with_sudo(cmd_kpartx, 'need root access to use kpartx')
               .scan(/(loop.*)\s\(/)
  puts dev_mapper

  puts('set up boot partition')
  mount_part("/dev/mapper/#{dev_mapper[0].first}")
  dev_mapper
end

def set_trap
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
end

def enable_ssh
  cmd_touch = "echo 'ssh file at boot' | sudo tee #{TMP_MOUNT_ENDPOINT}/ssh"
  exec_with_sudo(cmd_touch, 'need root to touch ssh at /boot')
end

def create_wpa_supplicant
  ssid = PROMPT.ask('Give me your SSID ?')
  passwd = PROMPT.ask('Give me your password ?')
  File.open(TMP_WPA_SUPPLICANT, 'w') do |file|
    file.write("ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
  network={
      ssid=\"#{ssid}\"
      psk=\"#{passwd}\"
      key_mgmt=WPA-PSK
  }")
  end
end

def enable_wpa
  create_wpa_supplicant
  cmd_create_wpa_supplicant =
    "cp #{TMP_WPA_SUPPLICANT} #{TMP_MOUNT_ENDPOINT}/wpa_supplicant.conf"
  exec_with_sudo(cmd_create_wpa_supplicant,
                 'need root to mv wpa_supplicant.conf at /boot')
end

def setup_rasp_boot
  enable_ssh
  enable_wpa
  enable_camera
end

def enable_camera
  `echo "\nstart_x=1\ngpu_mem=128\n" | sudo tee -a #{TMP_MOUNT_ENDPOINT}/config.txt`
end

def umount_part1_img
  # unmounted boot partition
  puts 'sync'
  `sync`
  cmd_umount = "umount #{TMP_MOUNT_ENDPOINT}"
  exec_with_sudo(cmd_umount,
                 "need root access to umount sd card on #{TMP_MOUNT_ENDPOINT}")
end

def build_part2_img(dev_mapper)
  puts('end setting boot partition')
  mount_part("/dev/mapper/#{dev_mapper[1].first}")

  hostname = "fiyeli-#{Faker::Science.scientist.gsub!(/\s/, '-')}"
  cmd_hostname = "echo #{hostname} "\
                 " | sudo tee #{TMP_MOUNT_ENDPOINT}/etc/hostname"
  exec_with_sudo(cmd_hostname,
                 "need root access to umount sd card on #{TMP_MOUNT_ENDPOINT}")
  hostname
end

def umount_part2_img_and_remove_mapper
  puts 'sync'
  `sync`
  puts "\n umount gracefully..."
  cmd_umount = "umount #{TMP_MOUNT_ENDPOINT}"
  exec_with_sudo(cmd_umount,
                 "need root access to umount sd card on #{TMP_MOUNT_ENDPOINT}")
  puts "\n remove kpartx partition"
  cmd_kpartx = "kpartx -v -d #{TMP_BUILDING_IMG}"
  exec_with_sudo(cmd_kpartx, 'need root access to use kpartx')
end

def dd_image_on_sd(sd_dev)
  cmd_dd = "dd if=#{TMP_BUILDING_IMG} of=#{sd_dev} \
  bs=4M conv=fsync status=progress"
  exec_with_sudo(cmd_dd, 'need root access to dd image on sd card')

  puts 'remove and put the sd card in raspberry'
end

def wait_and_scan(hostname)
  PROMPT.keypress('Press key for run scan')
  puts 'during 90 seconds the script scan network waiting the raspberry'

  require_relative 'find-rasp'

  ip = find_rasp(hostname)
  if ip != 'NOT FOUND'
    puts "your raspberry IP is : #{ip}"
  else
    puts 'timeout your raspberry was not found'
  end
end

def ensure_context
  check_prerequisite
  set_trap
end

def part2(dev_mapper)
  hostname = build_part2_img(dev_mapper)

  umount_part2_img_and_remove_mapper
  hostname
end

def main
  ensure_context

  sd = find_disk

  download_and_extract

  dev_mapper = prepare_img

  setup_rasp_boot

  umount_part1_img

  hostname = part2(dev_mapper)

  dd_image_on_sd(sd)

  wait_and_scan(hostname)

  shut_down
end

options = {}
OptionParser.new do |opt|
  opt.on('--scan HOSTNAME') { |o| options[:scan] = o }
end.parse!

if options.include? :scan
  wait_and_scan options[:scan]
else
  main
end
