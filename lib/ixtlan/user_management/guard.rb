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
require 'ixtlan/user_management/permission_model'
module Ixtlan
  module UserManagement
    class Guard
      METHODS = {
        :post => 'create',
        :get => 'retrieve',
        :put => 'update',
        :delete => 'delete'
      }

      def allow?( resource ,method, association = nil )
        perms = permissions[ resource ] || []
        perms.one? do |perm|
          ( perm.associations.empty? || 
            perm.associations.include?( association.to_s ) ) && 
          perm.allow?( METHODS[ method ] ) #TODO, associations )
        end
      end

      def associations( resource, method = nil )
        perms = permissions[ resource ] || []
        perms.collect { |perm| perm.associations }.flatten
        # TODO method 
      end
      
      def check_parent( resource, parent_resource )
        perms = permissions[ resource ]
        if perms
          perms.each do |perm|
            if perm.parent && perm.parent.resource != parent_resource
              raise 'parent resource is not guarded'
            end
          end
        end
      end

      def all_permissions
        permissions.values.flatten.select { |pp| pp.parent.nil? }
      end

      def permissions
        @permissions ||= {}
      end

      def permissions_new( resource )
        pp = Permission.new( :resource => resource )
        ( permissions[ resource ] ||= [] ) << pp
        pp
      end
      
      def permission_for( resource, *associations, &block ) 
        current = permissions_new( resource )
	associations.flatten!
        if associations.first.is_a? Permission
          current.parent = associations.first
          associations = associations[ 1..-1 ]
        end
        current.associations = associations unless associations.empty?
        block.call current if block
        current
      end
    end
  end
end
