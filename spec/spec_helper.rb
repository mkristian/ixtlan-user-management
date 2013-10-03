# single spec setup
$LOAD_PATH.unshift File.join( File.dirname( File.expand_path( File.dirname( __FILE__ ) ) ),
                              'lib' )

begin
  require 'minitest'
rescue LoadError
end
require 'minitest/autorun'

require 'dm-timestamps'
require 'dm-migrations'
require 'dm-validations'
#DataMapper::Logger.new(STDOUT, :debug)

#require 'ixtlan/session'
require 'ixtlan/user_management/user_resource'
require 'ixtlan/audit/resource'
require 'ixtlan/errors/resource'
require 'ixtlan/remote'
require 'ixtlan/gettext'

require 'ixtlan/configuration/resource'

DataMapper.setup :default, 'sqlite3::memory:'
DataMapper.finalize

# single entry in pool for the memory sqlite3
# otherwise sqlite3 sometimes does not find certain tables :(
class DataObjects::Pooling::Pool

  alias :initialize_old :initialize

  def initialize(max_size, resource, args)
    initialize_old( 1, resource, args)
  end
end

DataObjects::Pooling.pools
DataMapper.auto_migrate!
