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

  it 'serializes with associations' do
    guard.permission_for( 'audits' ).allow_all( 12,123 )

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
                          "associations"=>["12", "123"]}]
      }
    }    
    result = factory.new_serializer( subject ).to_hash
    result.must_equal expected
  end

  it 'serializes with empty associations' do
    guard.permission_for( 'audits' ).allow_retrieve( [] )

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
                          "actions"=>[{ "verb"=>nil, 
                                        "name"=>"retrieve",
                                        "associations"=>[] }],
                          "allow"=>true,
                          "associations"=>nil}]
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
                          "associations"=>nil},
                        { "children" => [],
                          "resource"=>"errors",
                          "actions"=>[],
                          "allow"=>false,
                          "associations"=>nil},
                        { "children" => [],
                          "resource"=>"configuration",
                          "actions"=>[],
                          "allow"=>false,
                          "associations"=>nil}
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
                                        "name"=>"retrieve",
                                        "associations"=>nil}],
                          "allow"=>true,
                          "associations"=>nil},
                        { "children" => [],
                          "resource"=>"errors",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"create",
                                        "associations"=>nil}],
                          "allow"=>true,
                          "associations"=>nil},
                        { "children" => [],
                          "resource"=>"configuration",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"update",
                                        "associations"=>nil}],
                          "allow"=>true,
                          "associations"=>nil},
                        { "children" => [],
                          "resource"=>"users",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"delete",
                                        "associations"=>nil}],
                          "allow"=>true,
                          "associations"=>nil}
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
                                        "name"=>"retrieve",
                                        "associations"=>nil},
                                      { "verb" => nil,
                                        "name"=>"create",
                                        "associations"=>nil},
                                      { "verb" => nil,
                                        "name"=>"update",
                                        "associations"=>nil}],
                          "allow"=>true,
                          "associations"=>["domain"]},
                        { "children" => [],
                          "resource"=>"users",
                          "actions"=>[{ "verb" => nil,
                                        "name"=>"delete",
                                        "associations"=>nil}],
                          "allow"=>true,
                          "associations"=>["nodomain", "domain"]}
                       ]
      }
    }
    result = factory.new_serializer( subject ).to_hash
    result.must_equal expected
  end

end
