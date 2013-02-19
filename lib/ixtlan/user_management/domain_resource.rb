module Ixtlan
  module UserManagement
    class Domain

      include DataMapper::Resource

      def self.storage_name(arg)
        'ixtlan_domains'
      end

      # key for selectng the IdentityMap should remain this class if
      # there is no single table inheritance with Discriminator in place
      # i.e. the subclass used as key for the IdentityMap
      def self.base_model
        self
      end

      ALL_ID = 1
      DEFAULT_ID = 2

      ALL_NAME= 'ALL'
      DEFAULT_NAME = 'DEFAULT'

      def self.ALL
        first_or_create( :id => ALL_ID, :name => ALL_NAME )
      end

      def self.DEFAULT
        first_or_create( :id => DEFAULT_ID, :name => DEFAULT_NAME )
      end

      def self.almost_all( args = {} )
        all( { :id.gt => ALL_ID }.merge( args ) )
      end

      def self.first_or_create( args )
        first( args ) || create!( args.merge( {:updated_at => DateTime.new( 1 ) } ) )
      end

      property :id, Serial  
      property :name, String, :unique => true, :format => /ALL|DEFAULT|^[a-z]+$/,:required => true, :length => 32

      timestamps :updated_at

      # do not record timestamps since they are set from outside
      def set_timestamps_on_save
      end

      def all?
        name == ALL_NAME
      end

      def default?
        name == DEFAULT_NAME
      end
    end
  end
end
