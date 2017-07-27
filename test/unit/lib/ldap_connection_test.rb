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

  #test 'authenticates with valid user password' do
    #username = 'bob'
    #password = 'bobstar42'
    #userdn = 'bobs_dn'

    #ldap_entry = mock()
    #ldap_entry.expects(:dn).returns(userdn)
    #ldap = mock()
    #ldap.expects(:bind_as)
        #.with(base: ldap_config[:basename], filter: "uid=#{username}", password: password)
        #.returns([ ldap_entry ])
    #Net::LDAP.expects(:new)
             #.with(host: ldap_config[:hostname], port: ldap_config[:port], encryption: :simple_tls)
             #.returns(ldap)
    #ldap = mock()
    #ldap.expects(:bind).returns(true)
    #Net::LDAP.expects(:new)
             #.with(host: ldap_config[:hostname],
                   #port: ldap_config[:port],
                   #encryption: :simple_tls,
                   #auth: { method: :simple,
                           #username: userdn,
                           #password: password })
              #.returns(ldap)

    #assert_equal true, ldap_connect.login(username, password)
  #end

  #test 'does not authenticate with valid user but invalid password' do
    #username = 'bob'
    #password = 'bobstar666'
    #userdn = 'bobs_dn'

    #ldap_entry = mock()
    #ldap_entry.expects(:dn).returns(userdn)
    #ldap = mock()
    #ldap.expects(:bind_as)
        #.with(base: ldap_config[:basename], filter: "uid=#{username}", password: password)
        #.returns([ ldap_entry ])
    #Net::LDAP.expects(:new)
             #.with(host: ldap_config[:hostname], port: ldap_config[:port], encryption: :simple_tls)
             #.returns(ldap)
    #ldap = mock()
    #ldap.expects(:bind).returns(false)
    #Net::LDAP.expects(:new)
             #.with(host: ldap_config[:hostname],
                   #port: ldap_config[:port],
                   #encryption: :simple_tls,
                   #auth: { method: :simple,
                           #username: userdn,
                           #password: password })
              #.returns(ldap)

    #assert_equal false, ldap_connect.login(username, password)
  #end

  #test 'does not authenticate if username contains invalid characters' do
    #username = 'bob50$'
    #password = 'bobstar42'

    #Net::LDAP.expects(:new)
             #.with(host: ldap_config[:hostname], port: ldap_config[:port], encryption: :simple_tls)

    #assert_equal false, ldap_connect.login(username, password)
  #end

  #test 'uid raises error if non existing user' do
    #skip()
  #end

  #test 'gets ldap info for existing user' do
    #uid = 1
    #username = 'bob'
    #password = 'bobstar42'
    #userdn = 'bobs_dn'
    #attribute = { username: 'bob', password: 'bobstar42', userdn: 'bobs_dn' }

    #ldap_entry = mock()
    #ldap_entry.expects(:dn).returns(userdn)
    #ldap = mock()
    #ldap.expects(:bind_as)
        #.with(base: ldap_config[:basename], filter: "uid=#{username}", password: password)
        #.returns([ ldap_entry ])
    #Net::LDAP.expects(:new)
             #.with(host: ldap_config[:hostname], port: ldap_config[:port], encryption: :simple_tls)
             #.returns(ldap)
    #ldap = mock()
    #ldap.expects(:bind).returns(true)
    #Net::LDAP.expects(:new)
             #.with(host: ldap_config[:hostname],
                   #port: ldap_config[:port],
                   #encryption: :simple_tls,
                   #auth: { method: :simple,
                           #username: userdn,
                           #password: password })
              #.returns(ldap)
    #ldap = mock()
    #ldap.expects(:eq)
        #.with('uidnumber', uid)
        #.returns(true)

    #ldap = mock()
    #ldap.expects(:search)
        #.with(base: ldap_config[:basename],
              #filter: "uidnumber=#{uid}",
              #attributes: [attribute])
        #.returns("bob bobstar42 bobs_dn")

    #assert_equal 'bob', ldap_connect.ldap_info(uid, attribute)
  #end

  #test 'returns error message if unable to connect' do
    #skip()
  #end

  def ldap_connection
     LdapConnection.new
  end

end
