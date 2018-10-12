require 'net/http'

def http_download(uri_str, file_name, limit:10)
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  info "connecting #{uri_str}"
  response = Net::HTTP.get_response(URI.parse(uri_str))
  case response
  when Net::HTTPSuccess
    info "saving to #{file_name}"
    open(file_name, "wb") do |file|
      file.write(response.body)
    end
    response
  when Net::HTTPRedirection
    http_download(response['location'], file_name, limit:limit-1)
  else
    response.value
  end
end

def parse_option(opt_key,sep=' ')
  fetch(opt_key).map do |k,v|
    k = k.to_s
    if k.size == 1
      m = "-"
    elsif k.size > 1
      m = "--"
    else
      raise ArgumentError,"Invalid option"
    end
    case v
    when NilClass
      nil
    when FalseClass
      [m,k,sep,"no"].join
    when TrueClass
      [m,k].join
    else
      [m,k,sep,v].join
    end
  end.compact
end

def remote_env(str)
  capture(:echo,"\"#{str}\"")
end

def print_process(role,cmd)
  output = {}
  on roles(role), in: :parallel do |host|
    result = capture("ps u -C '#{cmd}' | egrep \"^$USER|$UID|USER\"")
    output[host] = "[#{host.hostname}]\n#{result}"
  end
  roles(role).each{|host| puts output[host]}
end
