#!/bin/env ruby

# Scan for existing image source in a given datastore
# mailto: svallero@to.infn.it

# ARGV[0] is the datastore id
# ARGV[1] is the reference iqn
# ARGV[2] is the current image id

# Requirements
require 'pp'
require 'optparse'

# OpenNebula libraries

ONE_LOCATION=ENV['ONE_LOCATION']

if !ONE_LOCATION
RUBY_LIB_LOCATION='/usr/lib/one/ruby'
else
RUBY_LIB_LOCATION=ONE_LOCATION+'/lib/ruby'
end

$: << RUBY_LIB_LOCATION

require 'opennebula'

$one_client = OpenNebula::Client.new('oneadmin:xxx','http://localhost:2633/RPC2')


def main
  #puts "Reference datastore_id is: #{ARGV[0]}"
  #puts "Reference IQN is: #{ARGV[1]}"
  # Get list of datastores...
  ds_pool = OpenNebula::DatastorePool.new($one_client)
  rc = ds_pool.info
  if OpenNebula.is_error?(rc)
    puts 'Error while getting list of datastores:'
    puts rc.message
    exit 1
  end

  # ...and images therein
  image_pool = OpenNebula::ImagePool.new($one_client, -2)
  rc = image_pool.info
  if OpenNebula.is_error?(rc)
    puts 'Error while getting list of images:'
    puts rc.message
    exit 1
  end

  # loop on datastores
  ds_pool.each do |ds|
    # only consider reference datastore
    next unless ds.id == ARGV[0].to_i
    image_pool.each do |img|
      next if img['DATASTORE_ID'].to_i != ds.id
      image_path = img['SOURCE']
      if image_path == ARGV[1] && img.id != ARGV[2].to_i
        puts "IQN is already linked to image_id #{img.id}"
        exit 1
      end 
    end

  end
exit 0
end

# Entry point

main
