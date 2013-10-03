# -*- coding: utf-8 -*-
require File.expand_path( File.join( File.dirname( __FILE__ ),
                                     'spec_helper.rb' ) )

require 'ixtlan/user_management/session_manager'
require 'ixtlan/user_management/user_resource'
require 'ixtlan/user_management/group_model'

describe Ixtlan::UserManagement::SessionManager do

  subject { Ixtlan::UserManagement::SessionManager.new }

  let( :user ) do
    unless u = Ixtlan::UserManagement::User.first
      u = Ixtlan::UserManagement::User.create( :login => 'root',
                                               :name => 'Root',
                                               :updated_at => DateTime.now )
    end
    u.groups = [ Ixtlan::UserManagement::Group.new( :name => 'root' ),
                 Ixtlan::UserManagement::Group.new( :name => 'admin' )]
    u
  end

  it 'roundtrip convert the session' do
    expected = {
      "login"=>"root",
      "name"=>"Root",
      "groups"=>[{"name"=>"root"},
                 {"name"=>"admin"}]
    }

    data = subject.to_session( user )
    data.must_equal expected

    roundtrip = subject.from_session( data )
    user.must_equal roundtrip
  end

end
