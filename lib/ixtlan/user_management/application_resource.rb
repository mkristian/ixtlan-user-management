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
    class Application
      include DataMapper::Resource

      def self.storage_name(arg)
        'ixtlan_applications'
      end

      # key for selectng the IdentityMap should remain this class if
      # there is no single table inheritance with Discriminator in place
      # i.e. the subclass used as key for the IdentityMap
      def self.base_model
        self
      end

      property :id, Serial, :auto_validation => false

      property :name, String, :required => true, :unique => true, :length => 32
      property :url, String, :required => true, :format => /^https?\:\/\/[a-z0-9\-\.]+(\.[a-z0-9]+)*(\:[0-9]+)?(\/\S*)?$/, :length => 64, :lazy => true
      property :updated_at, DateTime, :required => true, :lazy => true

      # do not record timestamps since they are set from outside
      def set_timestamps_on_save
      end
    end
  end
end