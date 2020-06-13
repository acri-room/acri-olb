require 'fileutils'
require 'json'

def parse_time(str)
  return str.split(':')
end

def str_time(time)
  return "#{time[0]}:#{time[1]}:#{time[2]}"
end

def parse_date(str)
  return str.split('-')
end

# Return the data path corresponding date and hostname.
# If the file does not exist, the file will be generated.
def data_path(year, month, date, host)
  dir = "#{BASEDIR}/#{year}/#{month}/#{date}"
  path = "#{dir}/#{host}.json"
  FileUtils.mkdir_p(dir) # force to create the directory
  if File.exists?(path) == false then
    # generate the file with an empty data
    open(path, "w"){|f| f.puts("{}") }
  end
  return path # should have valid data
end

def load_datafile(year, month, date, host)
  path = data_path(year, month, date, host)
  data = nil
  open(path, 'r'){|f| data = JSON.parse(f.read())}
  return data
end

def save_datafile(year, month, date, host, contents)
  path = data_path(year, month, date, host)
  open(path, 'w'){|f| f.puts(JSON.generate(contents))}
end
