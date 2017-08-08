# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class UserProvidesNewLdapPwTest < ActionDispatch::IntegrationTest
include IntegrationTest::AccountTeamSetupHelper
include IntegrationTest::DefaultHelper
  test 'Bob provides new ldap password and remembers old password' do
    #Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')

    #Mock
    LdapConnection.new.stubs(:login).returns(true)
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid, 'givenname').returns('Bob')
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid, 'sn').returns('test')

    account_path = get_account_path

    login_as('bob')

    #Recrypt
    post recryptrequests_recrypt_path, new_password: 'newPassword', old_password: 'password'
    logout

    login_as('bob', 'newPassword')

    #Test if Bob can see his account
    get account_path
    assert_select "input#cleartext_username", {value: "test"}
    assert_select "input#cleartext_password", {value: "password"}
  end

  test "Bob provides new ldap password and doesn't remember his old password" do
    #Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attributes(auth: 'ldap')

    #Mock
    LdapConnection.new.stubs(:login).returns(true)
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid.to_s, 'givenname').returns('Bob')
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid.to_s, 'sn').returns('test')

    account_path = get_account_path

    login_as('bob')

    #Recrypt
    post recryptrequests_recrypt_path, forgot_password: true, new_password: 'newPassword'

    login_as('admin')
    bobs_user_id = users(:bob).id
    recrypt_id = Recryptrequest.find_by_user_id(bobs_user_id).id
    post admin_recryptrequest_path(recrypt_id), _method: 'delete'

    #Test if user could see his account(he should see now)
    login_as('bob', 'newPassword')
    get account_path
    assert_select "input#cleartext_username", {value: "test"}
    assert_select "input#cleartext_password", {value: "password"}
  end

  test 'Bob provides new ldap password and entered wrong old password' do
    #Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')

    #Mock
    LdapConnection.new.stubs(:login).returns(true)
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid, 'givenname').returns('Bob')
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid, 'sn').returns('test')

    login_as('bob')

    #Recrypt
    post recryptrequests_recrypt_path, new_password: 'newPassword', old_password: 'wrong_password'

    #Test if user got error messages
    assert_match /Your OLD password was wrong/, flash[:error]
  end

  test 'Bob provides new ldap password and entered wrong new password' do
    #Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')

    #Mock
    LdapConnection.new.stubs(:login).returns(true)
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid, 'givenname').returns('Bob')
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid, 'sn').returns('test')

    #Test if Bob can see his account (should not)
    # cannot_access_account(get_account_path, 'bob')

    login_as('bob')

    #Recrypt
    LdapConnection.new.stubs(:login).returns(false)
    post recryptrequests_recrypt_path, new_password: 'wrong_password'

    #Test if user got error messages
    assert_match /Your NEW password was wrong/, flash[:error]
  end

  test 'Bob provides new ldap password over recryptrequest and entered wrong new password' do
    #Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')

    #Mock
    LdapConnection.new.stubs(:login).returns(true)
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid, 'givenname').returns('Bob')
    LdapConnection.new.stubs(:ldap_info).with(User.uid_by_username('bob').uid, 'sn').returns('test')

    #Test if Bob can see his account (should not)
    # cannot_access_account(get_account_path, 'bob')

    login_as('bob')

    #Recrypt
    LdapConnection.new.stubs(:login).returns(false)
    post recryptrequests_recrypt_path, forgot_password: true, new_password: 'wrong_password'

    #Test if user got error messages
    assert_match /Your NEW password was wrong/, flash[:error]
  end
end
