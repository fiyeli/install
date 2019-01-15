#!/usr/bin/env ruby

require 'hooray'

def find_raspberries
  seek = Hooray::Seek.new
  raspberries = seek.nodes.select do |element|
    p element
    # mac adress of raspberry
    !element.mac.nil? && element.mac[0..7].upcase.tr(':', '') == 'B827EB'
  end
  raspberries
end

def scan_network_and_test_ssh(hostname)
  20.times do
    find_raspberriesraspberries.each do |raspberry|
      real_hostname = `sshpass -p raspberry \
      ssh -o UserKnownHostsFile=/dev/null \
      -oStrictHostKeyChecking=no pi@#{raspberry.ip.to_s} hostname`
      return raspberry.ip if hostname.chomp == real_hostname.chomp
    end
    sleep(5)
  end
  nil
end

def find_rasp(hostname)
  res = scan_network_and_test_ssh(hostname)
  return res.to_s if res.class.to_s == 'IPAddr'

  'NOT FOUND'
end
