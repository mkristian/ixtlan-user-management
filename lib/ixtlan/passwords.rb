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
require 'yaml'
require 'erb'
module Ixtlan
  class HashWithDefault < ::Hash
    def get( key, default = HashWithDefault.new )
      self[ key ] || default
    end
  end

  class Passwords

    def self.symbolize_keys(h)
      result = HashWithDefault.new

      h.each do |k, v|
        v = ' ' if v.nil?
        if v.is_a?(Hash)
          result[k.to_sym] = symbolize_keys(v) unless v.size == 0
        else
          result[k.to_sym] = v unless k.to_sym == v.to_sym
        end
      end
      result
    end

    def self.load( file )
      rel_file = File.expand_path( file ).sub( /#{File.expand_path '.' }\/?/, '' )
      if File.exists?( file )
        warn "[Passwords] Loaded #{rel_file} file"
        symbolize_keys( YAML::load( ERB.new( IO.read( file ) ).result ) )
      else
        warn "[Passwords] No #{rel_file} file to load"
      end
    end

    def self.config( file = 'password.yml' )
      @config ||= load( file ) || HashWithDefault.new
    end

    def self.[]( key )
      @config[ key ]
    end

    def self.get( key, default = nil )
      if default
        @config.get( key, default )
      else
        @config.get( key )
      end
    end
  end
end