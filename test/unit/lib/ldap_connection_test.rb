# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class LdapConnectionTest <  ActiveSupport::TestCase

  LdapConnection::MANDATORY_LDAP_SETTING_KEYS.each do |k|
    test "raises error on missing mandatory setting value: #{k}" do
      Setting.find_by(key: "ldap_#{k}").update!(value: '')
      assert_raises ArgumentError do
        ldap_connection
      end
    end
  end

  test 'authenticates with valid user password' do
  user_entry = mock()
  user_entry.expects(:dn)
             .returns('uid=bob,ou=puzzle,ou=users,dc=puzzle,dc=itc')

    Net::LDAP.any_instance.expects(:bind_as)
             .with({base: 'example_basename', filter: "uid=#{'bob'}", password: 'pw'})
             .returns([user_entry])

    Net::LDAP.any_instance.expects(:bind)
             .returns(true)
    unstub_ldap_tools
    assert_equal true, ldap_connection.login('bob', 'pw')
  end

  test 'does not authenticate with valid user but invalid password' do
    Net::LDAP.any_instance.expects(:bind_as)
             .with({base: 'example_basename', filter: "uid=#{'bob'}", password: 'pw'})
             .returns(false)

    unstub_ldap_tools
    assert_equal false, ldap_connection.login('bob', 'pw')
  end

  test 'does not authenticate if username contains invalid characters' do
    Net::LDAP.any_instance.expects(:bind_as).never

    unstub_ldap_tools
    assert_equal false, ldap_connection.login('bob$', 'pw')
  end

  test 'does not authenticate if user does not exist' do
    Net::LDAP.any_instance.expects(:bind_as)
              .with({base: 'example_basename', filter: "uid=#{'mrunknown'}", password: 'pw'})
              .returns(false)

    unstub_ldap_tools
    assert_equal false, ldap_connection.login('mrunknown', 'pw')
  end

  test 'does not return info if uid does not exist' do
    filter = Net::LDAP::Filter.eq('uidnumber', 1)

    Net::LDAP::Filter.expects(:eq)
                     .with('uidnumber', '1')
                     .returns(filter)

    Net::LDAP.any_instance.expects(:search)
        .with(base: 'example_basename', filter: filter)
        .returns(nil)

    unstub_ldap_tools
    assert_equal 'No <uid for uid 1>', ldap_connection.ldap_info('1', 'uid')
  end


  test 'does not return info if attribute does not exist' do
    filter = Net::LDAP::Filter.eq('uidnumber', 1)

    Net::LDAP::Filter.expects(:eq)
                     .with('uidnumber', '1')
                     .returns(filter)

    entry = mock()
    entry.expects(:try)
         .with('unknown_attr')

    Net::LDAP.any_instance.expects(:search)
        .with(base: 'example_basename', filter: filter)
        .returns([entry])

    unstub_ldap_tools
    assert_equal 'No <unknown_attr for uid 1>', ldap_connection.ldap_info('1', 'unknown_attr')
  end

  test 'returns ldap info' do
    filter = Net::LDAP::Filter.eq('uidnumber', 1)

    Net::LDAP::Filter.expects(:eq)
                     .with('uidnumber', '1')
                     .returns(filter)

    entry = mock()
    entry.expects(:try)
         .with('uid')
         .returns(["bob"])

    Net::LDAP.any_instance.expects(:search)
        .with(base: 'example_basename', filter: filter)
        .returns([entry])

    unstub_ldap_tools
    assert_equal 'bob', ldap_connection.ldap_info('1', 'uid')
  end

  test 'does not return uidnumber if username invalid' do
    Net::LDAP.any_instance.expects(:search).never

    unstub_ldap_tools
    assert_nil ldap_connection.uidnumber_by_username('bob$')
  end

  test 'returns uidnumber by username' do
    filter = Net::LDAP::Filter.eq('uid', 'bob')

    Net::LDAP::Filter.expects(:eq)
                     .with('uid', 'bob')
                     .returns(filter)

    entry = mock()
    entry.expects(:uidnumber)
         .returns([1])

    Net::LDAP.any_instance.expects(:search)
        .with(base: 'example_basename', filter: filter, attributes: ['uidnumber'])
        .yields(entry)

    unstub_ldap_tools
    assert_equal '1', ldap_connection.uidnumber_by_username('bob')
  end

  test 'does not return uidnumber if username not exists' do
    assert_raises 'No uidnumber for user unknown_user found' do
      unstub_ldap_tools
      ldap_connection.uidnumber_by_username('bob')
    end
  end

  def ldap_connection
     LdapConnection.new
  end

end
