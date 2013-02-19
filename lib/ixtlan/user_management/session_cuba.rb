require 'ixtlan/user_management/session_plugin'

module Ixtlan
  module UserManagement
  
    class SessionCuba < CubaAPI

      plugin SessionPlugin

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
        
        on get, :ping do
          self.class.authenticator.ping( current_user )
          head 200
        end
        
        on delete, current_user do
          self.class.authenticator.logout( current_user )
          log "logout"
          reset_current_user
          head 200
        end
      end
    end
  end
end
