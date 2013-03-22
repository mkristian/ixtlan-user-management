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
  
    class SessionCuba < CubaAPI

      def self.authenticator
        self[ :authenticator ] ||= Authenticator.new( self[ :rest ] )
      end

      def log( msg )
        if self.respond_to? :audit
          audit( msg, { :username => login } )
        else
          warn( "[#{login}] #{msg}" )
        end
      end
  
      def login_and_password
        source = parse_request_body rescue nil
        source = req if source.nil? || source.empty?
        auth = source[ 'authentication' ] || source
        [ auth[ 'login' ] || auth[ 'email' ], auth[ 'password' ] ]
      end
      
      def login
        login_and_password[ 0 ]
      end

      define do
        on post, :reset_password do
          if msg = self.class.authenticator.reset_password( login_and_password[ 0 ] )
            log msg
            head 200
          else
            log "user/email not found"
            head 404
          end
        end

        on post do
          user = self.class.authenticator.login( *login_and_password )
          if user      
            current_user( user )
            # be compliant with rack-protection and rack-csrf
            csrf = session[ :csrf ] || session[ "csrf.token" ]
            res[ 'X-CSRF-TOKEN' ] = csrf if csrf
            write self.class.sessions.create( user )
          else
            log "access denied"
            head 403
          end
        end
        
        on authenticated? do
          on get, 'me' do
            if current_user.respond_to? :updated_at
              if modified_since.nil? || current_user.updated_at > modified_since
                last_modified( current_user.updated_at )
                browser_only_cache_no_store
                write current_user, :use => :me
              else
                last_modified( modified_since )          
              end
            else
              browser_only_cache_no_store
              write current_user, :use => :me
            end
          end

          on get, 'ping' do
            self.class.authenticator.ping( current_user )
            head 200
          end
        end

        on get, /(me|ping)/ do
          head :unauthorized
        end

        on delete do
          self.class.authenticator.logout( current_user ) if current_user
          log "logout"
          reset_current_user
          head 200
        end

      end
    end
  end
end
