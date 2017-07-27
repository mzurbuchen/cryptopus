# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class LdapToolsTest <  ActiveSupport::TestCase

#  test 'authenticates with valid user password' do
#    username = 'bob'
#    password = 'ldappw'
#
#    Net::LDAP.any_instance.expects(:bind_as)...
#
#    assert_equal true, LdapTools.login(username, password)
#  end

  test 'can not login when ldap is disabled' do
    Net::LDAP.expects(:new).never
    assert_nil LdapTools.login("mzurbuchen", "auto1234")
  end

  test 'does not return uid if unknown user' do
    LdapTools.unstub(:get_uid_by_username)
    LdapTools.unstub(:connect)
    Setting.expects(:value).with(:ldap, :basename).returns("basename").twice
    Setting.expects(:value).with(:ldap, :hostname).returns("hostname")
    Setting.expects(:value).with(:ldap, :portnumber).returns("portnumber")
    Setting.expects(:value).with(:ldap, :bind_dn).returns("bind_dn").twice
    Setting.expects(:value).with(:ldap, :bind_password).returns("bind_password")
    Setting.expects(:value).with(:ldap, :enable).returns(true)
    Setting.expects(:value).with(:ldap, :enable).returns(true)
    assert_equal "UID of the user not found", LdapTools.get_uid_by_username("test")
  end

  test 'connect initializes ldap connection' do
    LdapTools.unstub(:connect)
    Setting.expects(:value).with(:ldap, :basename).returns("basename")
    Setting.expects(:value).with(:ldap, :hostname).returns("hostname")
    Setting.expects(:value).with(:ldap, :portnumber).returns("portnumber")
    Setting.expects(:value).with(:ldap, :bind_dn).returns("bind_dn").twice
    Setting.expects(:value).with(:ldap, :bind_password).returns("bind_password")
    Setting.expects(:value).with(:ldap, :enable).returns(true)

    assert_nothing_raised do
      LdapTools.connect
    end
  end
end
