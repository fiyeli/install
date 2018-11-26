#!/usr/bin/env ruby

require 'tty-prompt'
require 'ruby-progressbar'
require 'mkmf'
require 'open-uri'
require 'open_uri_redirections'
require 'zip'

TMP_RASPBIAN = '/tmp/raspbian_latest'.freeze
TMP_RASPBIAN_IMG = '/tmp/raspbian.img'.freeze

prompt = TTY::Prompt.new

required_bin = %w[tail hwinfo]
required_bin.each do |bin|
  unless find_executable(bin)
    STDERR.puts("ABORTED! You have to install #{bin}")
    exit(false)
  end
end

find_executable('hwinfo')

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

if File.file?(TMP_RASPBIAN)
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
if ENV['USER'] != 'root'
  puts 'need root access to dd image on sd card'
  exec("sudo #{cmd_dd}")
else
  exec(cmd_dd)
end
