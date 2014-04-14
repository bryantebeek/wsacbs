require 'rest_client'
require 'colors'
require 'optparse'

options = {:notation => :rpn}

op = OptionParser.new do |opts|
  opts.banner = "Usage: ruby client-state.rb [options]"

  opts.on("-n", "--notation [NOTATION]", [:pn, :rpn, :normal],
          "Notation: pn, rpn, normal") do |v|
    options[:notation] = v
  end

  opts.on("--url URL", "Specify URL") do |v|
    options[:url] = v
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

op.parse!

if options[:url].nil?
  puts "Missing options: url"
  puts op
  exit
end

SYNTAX_ERROR = "syntax error"
DIV_BY_0 = "division by zero"
EQUATIONS = {:nr2 => {:pn => "+&1&1",
                      :rpn => "1&1&+",
                      :normal => "1+1"},
             :nr4 => {:pn => "+&1&ACC",
                      :rpn => "1&ACC&+",
                      :normal => "1+ACC"},
             :nr7 => {:pn => "+&:&+&-&32.48&44.96&*&71.55&55.86&53.83&44.81",
                      :rpn => "32.48&44.96&-&71.55&55.86&*&+&53.83&:&44.81&+",
                      :normal => "(((32.48-44.96)+(71.55*55.86)):53.83)+44.81"}}

test_no = 0

#   __
#  /  \
# | () |
#  \__/

r = RestClient.delete options[:url]
if r.code != 204
  puts "(#{test_no}) wrong http code"
else
  puts "(#{test_no})".hl(:green)
end

test_no += 1

#  _
# / |
# | |
# |_|

r = RestClient.get options[:url]

unless r.body.empty?
  puts "(#{test_no}) server should not contain any records".hl(:red)
else
  puts "(#{test_no})".hl(:green)
end

test_no += 1

#  ___
# |_  )
#  / /
# /___|

r = RestClient.post options[:url], {:equation => EQUATIONS[:nr2][options[:notation]]}
if r.code != 201
  puts "(#{test_no}) wrong http code (#{r.code})".hl(:red)
else
  puts "(#{test_no})".hl(:green)
end
id = r.body

test_no += 1

#  ____
# |__ /
#  |_ \
# |___/

r = RestClient.get "#{options[:url]}/#{id}"
if r.body.to_f != 2
  puts "(#{test_no}) wrong result (#{r.body})".hl(:red)
else
  puts "(#{test_no})".hl(:green)
end

test_no += 1

#  _ _
# | | |
# |_  _|
#   |_|

r = RestClient.put "#{options[:url]}/#{id}", {:equation => EQUATIONS[:nr4][options[:notation]]}
if r.code != 200
  puts "(#{test_no}) wrong http code (#{r.code})".hl(:red)
else
  puts "(#{test_no})".hl(:green)
end

test_no += 1

#  ___
# | __|
# |__ \
# |___/

r = RestClient.get "#{options[:url]}/#{id}"
if r.body.to_f != 3
  puts "(#{test_no}) wrong result (#{r.body})".hl(:red)
else
  puts "(#{test_no})".hl(:green)
end

test_no += 1

#   __
#  / /
# / _ \
# \___/

r = RestClient.get options[:url]
unless r.body.split(',').length == 1
  puts "(#{test_no}) server should not contain one record".hl(:red)
else
  puts "(#{test_no})".hl(:green)
end

test_no += 1

#  ____
# |__  |
#   / /
#  /_/

r = RestClient.post options[:url], {:equation => EQUATIONS[:nr7][options[:notation]]}
if r.code != 201
  puts "(#{test_no}) wrong http code (#{r.code})".hl(:red)
else
  puts "(#{test_no})".hl(:green)
end
id = r.body

test_no += 1

#  ___
# ( _ )
# / _ \
# \___/

r = RestClient.get "#{options[:url]}/#{id}"
if r.body.to_f.round(2) != 118.83
  puts "(#{test_no}) wrong result (#{r.body})".hl(:red)
else
  puts "(#{test_no})".hl(:green)
end

test_no += 1

#  ___
# / _ \
# \_, /
#  /_/

r = RestClient.get options[:url]
unless r.body.split(',').length == 2
  puts "(#{test_no}) server should not contain two records instead of #{r.body.split(',').length}".hl(:red)
else
  puts "(#{test_no})".hl(:green)
end
