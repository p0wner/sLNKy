### REQUIRE GEMS ###
require 'time'
require 'colorize'
require 'ostruct'
require 'thor'
require 'terminal-table'
require 'date'
####################

### REQUIRE REX FILES ###
# disable warning messages
$VERBOSE = nil

require 'rex/text.rb'
require 'rex/socket.rb'
require 'rex/proto/smb.rb'
require 'rex/proto/dcerpc.rb'
require 'rex/encoder/ndr.rb'

# enable warning messages
$VERBOSE = false
#########################

### REQUIRE LOCAL FILES ###
require_relative 'alerts.rb'
require_relative 'array'
require_relative 'hash.rb'
require_relative 'helper_methods.rb'
require_relative 'log.rb'
require_relative 'logrecord.rb'
require_relative 'object.rb'
require_relative 'share.rb'
require_relative 'simpleclient.rb'
require_relative 'template.rb'

require_relative 'modes_of_operation/bruteforce_shares.rb'
require_relative 'modes_of_operation/clean_lnks.rb'
require_relative 'modes_of_operation/drop_lnk.rb'
require_relative 'modes_of_operation/drop_stealth_lnk.rb'
require_relative 'modes_of_operation/generate_file.rb'
###########################