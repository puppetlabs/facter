def get_temp
  `mktemp -d -t tmpXXXXXX`.strip
end

def erb(erbfile,  outfile)
  template = File.read(erbfile)
  message = ERB.new(template, nil, "-")
  output = message.result(binding)
  File.open(outfile, 'w') { |f| f.write output }
  puts "Generated: #{outfile}"
end

def cp_pr(src, dest, options={})
  mandatory = {:preserve => true}
  cp_r(src, dest, options.merge(mandatory))
end

def cp_p(src, dest, options={})
  mandatory = {:preserve => true}
  cp(src, dest, options.merge(mandatory))
end

def mv_f(src, dest, options={})
  force = {:force => true}
  mv(src, dest, options.merge(mandatory))
end

def check_tool(tool)
  %x{which #{tool}}
  unless $?.success?
    STDERR.puts "#{tool} is required for this task but could not be found."
    exit 1
  end
end

