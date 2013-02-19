require 'ixtlan/user_management/user_serializer'
require 'ixtlan/user_management/session_model'
require 'ixtlan/user_management/session_serializer'

module Ixtlan
  module UserManagement
    class SessionManager

      attr_accessor :idle_session_timeout, :block

      def initialize( &block )
        @block = block || lambda { [] }
      end
      
      def serializer( user )
        UserSerializer.new( user )
      end

      def to_session( user )
        serializer( user ).use( :session ).to_hash
      end

      if User.respond_to?( :properties )
        def from_session( data ) 
          if data
            data = data.dup
            groups = (data.delete( 'groups' ) || []).collect do |g|
              Group.new( g )
            end
            user = User.first( :login => data[ 'login' ] )
            user.groups = groups
            user
          end
        end
      else
        def from_session( data ) 
          if data
            User.new( data )
          end
        end
      end

      def create( user )
        Session.new( 'user' => user,
                     'permissions' => block.call( user.groups ),
                     'idle_session_timeout' => idle_session_timeout )
      end
    end
  end
end
