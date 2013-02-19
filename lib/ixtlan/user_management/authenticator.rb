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
