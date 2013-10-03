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
        perm = permissions( resource )
        (perm.associations.empty? || 
          perm.associations.include?( association.to_s ) ) && 
          perm.allow?( METHODS[ method ] ) #TODO, associations )
      end

      def associations( resource, method )
        perm = permissions( resource )
        unless perm.associations.empty?
          perm.associations
        end
        # TODO method 
      end
      
      def all_permissions
        @permissions.values
      end

      def permissions( resource )
        @permissions ||= {}
        @permissions[ resource ] ||= Permission.new( :resource => resource )
      end
      
      def permission( resource, *associations, &block ) 
        current = permissions( resource )
        current.associations = associations unless associations.empty?
        block.call current if block
        current
      end
    end
  end
end
