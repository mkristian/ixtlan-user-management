# -*- coding: utf-8 -*-
require File.expand_path( File.join( File.dirname( __FILE__ ),
                                     'spec_helper.rb' ) )

require 'ixtlan/user_management/guard'

describe Ixtlan::UserManagement::Guard do

  subject { Ixtlan::UserManagement::Guard.new }

  let( :root ) do
    unless u = Ixtlan::UserManagement::User.first
      u = Ixtlan::UserManagement::User.create( :login => 'root',
                                               :name => 'Root',
                                               :updated_at => DateTime.now )
      u.groups << Ixtlan::UserManagement::Group.create( :name => 'root' )
    end
    u
  end

  let( :resources ) { %w( audits errors configuration ) }

  before do
    %w( audits errors configuration ).each do |resource|
      subject.permission_for( resource ).deny_all
    end
  end

  it 'allows all' do
    subject.all_permissions.each { |p| p.allow_all }
    
    [ :get, :post, :put, :delete ].each do |m|
      %w( audits errors configuration ).each do |resource|
        [ 'domain1', nil ].each do |asso|
          subject.allow?( resource, m, asso ).must_equal true
        end
      end
    end
  end

  it 'allows all with associations' do
    subject.all_permissions.each do |p| 
      p.allow_all
      p.associations = [ 'domain', 'nodomain' ]
    end
    
    [ :get, :post, :put, :delete ].each do |m|
      %w( audits errors configuration ).each do |resource|
        [ 'something', nil ].each do |asso|
          subject.allow?( resource, m, asso ).must_equal false
        end
      end
    end
    [ :get, :post, :put, :delete ].each do |m|
      %w( audits errors configuration ).each do |resource|
        subject.allow?( resource, m, 'domain' ).must_equal true
      end
    end
  end

  it 'denies all' do    
    [ :get, :post, :put, :delete ].each do |m|
      %w( audits errors configuration ).each do |resource|
        [ 'domain', nil ].each do |asso|
          subject.allow?( resource, m, asso ).must_equal false
        end
      end
    end
  end

  Ixtlan::UserManagement::Permission::METHODS.each do |method|

    it "#{method.to_s.sub( /_/, 's ')}" do
      subject.all_permissions.each { |p| p.send method }
    
      #subject.all_permissions.each { |p| puts p.attributes.to_yaml }
      meth = method.to_s.sub( /allow_/, '' )
      [ :get, :post, :put, :delete ].each do |m|
        %w( audits errors configuration ).each do |resource|
          [ 'domain', nil ].each do |asso|
            expected = Ixtlan::UserManagement::Guard::METHODS[ m ] 
            subject.allow?( resource, m, asso ).must_equal(expected == meth)
          end
        end
      end
    end

    it "#{method.to_s.sub( /_/, 's ')} with associations" do
      subject.all_permissions.each do |p| 
        p.send method
        p.associations = [ 'domain', 'nodomain' ]
      end

      [ :get, :post, :put, :delete ].each do |m|
        %w( audits errors configuration ).each do |resource|
          [ 'something', nil ].each do |asso|
            subject.allow?( resource, m, asso ).must_equal false
          end
        end
      end
      meth = method.to_s.sub( /allow_/, '' )
      [ :get, :post, :put, :delete ].each do |m|
        %w( audits errors configuration ).each do |resource|
          expected = Ixtlan::UserManagement::Guard::METHODS[ m ] 
          subject.allow?( resource, m, 'domain' ).must_equal(expected == meth)
        end
      end
    end
    it "#{method.to_s.sub( /_/, 's ')} with action with associations" do
      subject.all_permissions.each do |p| 
        p.send method, 'domain', 'nodomain'
      end

      [ :get, :post, :put, :delete ].each do |m|
        %w( audits errors configuration ).each do |resource|
          [ 'something', nil ].each do |asso|
            subject.allow?( resource, m, asso ).must_equal false
          end
        end
      end
      meth = method.to_s.sub( /allow_/, '' )
      [ :get, :post, :put, :delete ].each do |m|
        %w( audits errors configuration ).each do |resource|
          expected = Ixtlan::UserManagement::Guard::METHODS[ m ] 
          subject.allow?( resource, m, 'domain' ).must_equal(expected == meth)
        end
      end
    end
  end
end
