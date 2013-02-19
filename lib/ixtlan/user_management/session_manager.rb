#
# Copyright (C) 2013 Christian Meier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
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