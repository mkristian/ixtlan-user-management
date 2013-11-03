# -*- coding: utf-8 -*-
require File.expand_path( File.join( File.dirname( __FILE__ ),
                                     'spec_helper.rb' ) )

require 'ixtlan/user_management/session_model'
require 'ixtlan/user_management/session_serializer'
require 'ixtlan/user_management/guard'
require 'ixtlan/babel/factory'

describe Ixtlan::UserManagement::Session do

  subject do
    c = Ixtlan::UserManagement::Session.new
    c.user = root
    c
  end

  let( :root ) do
    unless u = Ixtlan::UserManagement::User.first
      u = Ixtlan::UserManagement::User.create( :login => 'root',
                                               :name => 'Root',
                                               :updated_at => DateTime.now )
    end
    u
  end

  let( :factory ) { Ixtlan::Babel::Factory.new }

  let( :guard ) { Ixtlan::UserManagement::Guard.new }

  it 'serializes without permissions' do
    expected = {
      "session"=>{"idle_session_timeout"=>30,
        "user"=>{
          "id"=>1,
          "login"=>"root",
          "name"=>"Root"
        },
        "permissions"=>[]
      }
    }
    result = factory.new_serializer( subject ).to_hash
    result.must_equal expected
  end

  it 'serializes with root permissions' do
    %w( audits errors configuration ).each do |resource|
      guard.permission_for( resource ).allow_all
    end

    subject.permissions = guard.all_permissions

    expected = {
      "session"=>{"idle_session_timeout"=>30,
        "user"=>{
          "id"=>1,
          "login"=>"root",
          "name"=>"Root"
        },
        "permissions"=>[{ "children" => [],
                          "resource"=>"audits",
                          "actions"=>[],
                          "allow"=>false,
                          "associations"=>[]},
                        { "children" => [],
                          "resource"=>"errors",
                          "actions"=>[],
                          "allow"=>false,
                          "associations"=>[]},
                        { "children" => [],
                          "resource"=>"configuration",
                          "actions"=>[],
                          "allow"=>false,
                          "associations"=>[]}
                       ]
      }
    }
    result = factory.new_serializer( subject ).to_hash
    result.must_equal expected
  end

  it 'serializes with some permissions' do
    guard.permission_for( 'audits' ).allow_retrieve
    guard.permission_for( 'errors' ).allow_create
    guard.permission_for( 'configuration' ).allow_update
    guard.permission_for( 'users' ).allow_delete

    subject.permissions = guard.all_permissions

    expected = {
      "session"=>{"idle_session_timeout"=>30,
        "user"=>{
          "id"=>1,
          "login"=>"root",
          "name"=>"Root"
        },
        "permissions"=>[{ "children" => [],
                          "resource"=>"audits",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"retrieve"}],
                          "allow"=>true,
                          "associations"=>[]},
                        { "children" => [],
                          "resource"=>"errors",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"create"}],
                          "allow"=>true,
                          "associations"=>[]},
                        { "children" => [],
                          "resource"=>"configuration",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"update"}],
                          "allow"=>true,
                          "associations"=>[]},
                        { "children" => [],
                          "resource"=>"users",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"delete"}],
                          "allow"=>true,
                          "associations"=>[]}
                       ]
      }
    }
    result = factory.new_serializer( subject ).to_hash
    result.must_equal expected
  end

  it 'serializes permissions with assoications' do
    guard.permission_for( 'audits', 'domain' ).allow_mutate
    guard.permission_for( 'users', 'nodomain', 'domain' ).allow_delete

    subject.permissions = guard.all_permissions

    expected = {
      "session"=>{"idle_session_timeout"=>30,
        "user"=>{
          "id"=>1,
          "login"=>"root",
          "name"=>"Root"
        },
        "permissions"=>[{ "children" => [],
                          "resource"=>"audits",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"retrieve"},
                                      { "verb" => nil,
                                        "name"=>"create"},
                                      { "verb" => nil,
                                        "name"=>"update"}],
                          "allow"=>true,
                          "associations"=>["domain"]},
                        { "children" => [],
                          "resource"=>"users",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"delete"}],
                          "allow"=>true,
                          "associations"=>["nodomain", "domain"]}
                       ]
      }
    }
    result = factory.new_serializer( subject ).to_hash
    result.must_equal expected
  end

end
