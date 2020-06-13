#!/usr/bin/env ruby
##
## Monitor OLB data and generate local DB
##

require 'time'

load 'config.rb'
load 'util.rb'

# add reservation
def make_reservation(host, user, date, time)
  contents = load_datafile(date[0], date[1], date[2], host)
  contents[str_time(time)] = user
  save_datafile(date[0], date[1], date[2], host, contents)
end

# remove reservation
def make_cancellation(host, user, date, time)
  contents = load_datafile(date[0], date[1], date[2], host)
  contents.delete(str_time(time))
  save_datafile(date[0], date[1], date[2], host, contents)
end

# check reserve/cancel and operation
def action(entry)
  return if entry == nil or entry.size < 1 # nothing to do
  return if entry[0] != VERSION # nothing to do

  if(entry[1] == 'reserve') then
    make_reservation(entry[2], entry[3], parse_date(entry[4]), parse_time(entry[5]))
  elsif(entry[1] == 'cancel') then
    make_cancellation(entry[2], entry[3], parse_date(entry[4]), parse_time(entry[5]))
  end  
end

# parse CSV and make/cancel reservation
def parse(csv_str)
  csv_str.split("\n").each{|line|
    entry = line.strip.split(/\s*,\s*/)
    action(entry)
  }
end

######################################################
# main:
#  open data file and start operation
######################################################
if File.exist?(WP_LOCK) == false
  exit(0) # nothing to do
end

open(LOCAL_LOCK, 'w'){|local_lock|
  local_lock.flock(File::LOCK_EX) # get DB lock
  open(WP_LOCK, 'r'){|wp_lock|
    wp_lock.flock(File::LOCK_EX) # get WP lock

    # under getting both of DB and WP lock
    open(WP_DATA, "r"){|f| parse(f.read())}
    open(WP_DATA, "w"){|f| f.write("")} # clear WP log

    wp_lock.flock(File::LOCK_UN)
  }
  local_lock.flock(File::LOCK_UN)
}
