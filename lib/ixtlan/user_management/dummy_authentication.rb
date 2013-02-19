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
module Ixtlan
  module UserManagement
    module DummyAuthentication

      def self.need_dummy?( rest, server )
        url = rest.to_server( server ).url
        (url =~ /localhost/ || url =~ /127.0.0.1/ || url =~ /::1/) && !(ENV['SSO'] == 'true' || ENV['SSO'] == '')
      end

      def login(login, password)
        if ! login.blank? && password.blank?
          result = setup_user
          result.login = login.sub( /\[.*/, '' )
          result.name = result.login.capitalize
          result.groups = [ setup_group( login ) ]
          result.applications = [] if result.respond_to? :applications
          result
        end
      end

      protected

      def setup_user
        if u = user_model.get!(1)
          result = u
        else
          result.id = 1
          result.updated_at = DateTime.now
        end
      end

      def user_model
        User
      end
        
      def setup_group( login )
        group_for( Group, login )
      end

      def group_for( model, login )
        model.new('name' => login.sub( /\[.*/, '' ) )
      end

      def split( login )
        login.sub( /.*\[/ , '' ).sub( /\].*/, '' ).split( /,/ )
      end

    end
  end
end