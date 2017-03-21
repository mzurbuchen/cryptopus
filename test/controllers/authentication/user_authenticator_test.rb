# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require_relative '../../../app/controllers/authentication/user_authenticator.rb'
require_relative '../../../app/controllers/authentication/brute_force_detector.rb'
require 'test_helper'

class UserAuthenticatorTest < ActiveSupport::TestCase

  test 'authenticates bob' do
    @params = {username: 'bob', password: 'password'}

    assert_equal true, authenticate
  end

  test 'authentication invalid if blank password' do
    @params = {username: 'bob', password: ''}

    assert_equal false, authenticate
  end

  test 'authenticates against ldap' do
    @params = {username: 'bob', password: 'ldappw'}
    bob.update_attribute(:auth, 'ldap')
    LdapTools.expects(:ldap_login).with('bob', 'ldappw').returns(true)
    assert_equal true, authenticate
  end

  test 'doesnt authenticate against ldap' do
    @params = {username: 'bob', password: 'wrongldappw'}
    bob.update_attribute(:auth, 'ldap')
    LdapTools.expects(:ldap_login).with('bob', 'wrongldappw').returns(false)

    assert_equal false, authenticate
  end

  test 'increasing of failed login attempts and it\'s defined delays' do
    @params = {username: 'bob', password: 'wrong password'}
    bruteForceDetector = Authentication::BruteForceDetector.new(bob)
    locktimes = Authentication::BruteForceDetector::LOCK_TIME_FAILED_LOGIN_ATTEMPT
    assert_equal 10, locktimes.count
    locktimes.each_with_index do |timer, i|
      attempt = i + 1

      bob.update_attribute(:failed_login_attempts, attempt)
      last_failed_login_time = Time.now.utc - (locktimes[attempt].seconds)
      bob.update_attribute(:last_failed_login_attempt_at, last_failed_login_time)

      authenticate

      assert_not bruteForceDetector.send(:user_temporarly_locked?), 'bob shouldnt be locked temporarly'

      authenticate

      return if attempt == locktimes.count - 1

      assert_equal attempt + 1, bob.failed_login_attempts
      assert last_failed_login_time.to_i <= bob.reload.last_failed_login_attempt_at.to_i
    end
  end

  test 'authentication fails if required params missing' do
    @params = {}

    assert_equal false, authenticate
    assert_match /Invalid user \/ password/, authenticator.errors.first
  end

  test 'authentication fails if invalid credentials' do
    @params = {username: 'bob', password: 'invalid'}

    assert_equal false, authenticate
    assert_match /Invalid user \/ password/, authenticator.errors.first
  end

  test 'authentication fails if user does not exist' do
    @params = {username: 'nobody', password: 'password'}

    assert_equal false, authenticate
    assert_match /Invalid user \/ password/, authenticator.errors.first
  end

  test 'authentication succeeds if user and password match' do
    @params = {username: 'bob', password: 'password'}

    assert_equal true, authenticate
  end

  private
  def authenticate
    authenticator.password_auth!
  end

  def authenticator
    @authenticator ||= Authentication::UserAuthenticator.new(@params)
  end

  def bob
    users(:bob)
  end
end
