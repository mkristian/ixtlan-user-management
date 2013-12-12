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
require 'virtus'
module Ixtlan
  module UserManagement
    class Action   
      include Virtus
      
      attribute :verb, String
      attribute :name, String
      attribute :associations, Array[String], :default => nil
    end
    class Permission   
      include Virtus
      
      METHODS = [ :allow_retrieve, 
                  :allow_create, 
                  :allow_update, 
                  :allow_delete ]
      
      attribute :parent, Permission
      attribute :children, Array[Permission]
      attribute :resource, String
      attribute :actions, Array[Action], :default => []
      attribute :allow, Boolean, :default => true
      attribute :associations, Array[String], :default => nil
     
      def parent=( pt )
        super
        if pt
          pt.children << self
        elsif parent
          parent.children.delete self
        end
      end

      def allow?( method, association = nil )
        action = self.actions.detect { |a| a.name == method }
        if self.allow 
          action != nil && ( action.associations.nil? || action.associations.include?( association ) )
        else
          action.nil? #TODO associations
        end
      end

      def allow_all( *associations )
        self.allow = false
        self.actions.clear
        set_asso( self, *associations )
        self
      end

      def set_asso( obj, *associations )
        case associations.first
        when NilClass
          # leave default
        when Array
          # assume empty
          obj.associations = associations.flatten
        else
          obj.associations = associations
        end
      end
      
      def deny_all
        self.allow = true
        self.actions.clear
        self
      end

      def allow_mutate( *associations )
        allow_retrieve( *associations )
        allow_create( *associations )
        allow_update( *associations )
        self
      end
      
      def method_missing( method, *args )
        if METHODS.include?( method )
          a = Action.new( :name => method.to_s.sub( /allow_/, '' ) )
          set_asso( a, *args )
          self.actions << a
          self
        elsif METHODS.include?( method.to_s.sub( /_verb$/, '' ).to_sym )
          verb = args.first
          args = args[ 1..-1 ]
          a = Action.new( :name => method.to_s.gsub( /allow_|_verb/, '' ),
                          :verb => verb )
          set_asso( a, *args )
          self.actions << a
          self
        else
          super
        end
      end
    end
  end
end
