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
require 'ixtlan/user_management/authenticator'

module Ixtlan
  module UserManagement
    module SessionPlugin

      module ClassMethods
        def authenticator
          self[ :authenticator ] ||= Authenticator.new( self[ :rest ] )
        end
      end

      def log( msg )
        if self.respond_to? :audit
          audit( msg, { :username => login } )
        else
          warn( "[#{login}] #{msg}" )
        end
      end
  
      def login_and_password
        source = parse_request_body
        source = req if source && source.empty?
        auth = source[ 'authentication' ] || source
        [ auth[ 'login' ] || auth[ 'email' ], auth[ 'password' ] ]
      end
      
      def login
        login_and_password[ 0 ]
      end
    end
  end
end
