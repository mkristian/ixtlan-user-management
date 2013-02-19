require 'virtus'
module Ixtlan
  module UserManagement
    class Session
      include Virtus

      attribute :idle_session_timeout, Integer
      attribute :user, User
      attribute :permissions, Array[Object]

      def to_s
        "Session( #{user.name}<#{user.login}> groups[ #{user.groups.collect { |g| g.name }.join ',' } ] #{idle_session_timeout} )"
      end
    end
  end
end
