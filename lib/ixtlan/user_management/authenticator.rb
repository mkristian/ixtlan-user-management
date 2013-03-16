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
require 'ixtlan/user_management/authentication_model'
module Ixtlan
  module UserManagement
    class Authenticator

      def initialize( restserver )
        @restserver = restserver
      end

      def user_new( params )
        User.new( params )
      end

      def login( username_or_email, password )
        user = nil
        @restserver.create( Authentication.new(:login => username_or_email, :password => password) ) do |json, req|
          user = user_new( JSON.load( json ) ) unless json.strip == ''
          #tell restserver to ignore response
          nil
        end
        user
      end
      
      def reset_password( username_or_email )
        result = nil
        @restserver.create( Authentication.new( :login => username_or_email ), 
                            :reset_password ) do |json, req|
          result = json unless json.strip == ''
          #tell restserver to ignore response
          nil
        end
        result
      end

      def ping( user )
        # do nothing
      end

      def logout( user )
        # do nothing
      end
    end
  end
end
