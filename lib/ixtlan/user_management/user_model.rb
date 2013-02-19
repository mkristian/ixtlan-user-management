require 'ixtlan/user_management/group_model'
module Ixtlan
  module UserManagement
    class User
      include Virtus

      attribute :login, String
      attribute :name, String
      attribute :groups, Array[Group]

      def initialize( params = {} )
        super params[ 'user' ] || params
      end
    end
  end
end
