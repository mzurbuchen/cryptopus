# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class LdapToolsTest <  ActiveSupport::TestCase

  test 'authenticates with valid user password' do
    username = 'bob'
    password = 'ldappw'

    Net::LDAP.any_instance.expects(:bind_as)...

    assert_equal true, LdapTools.login(username, password)
  end

end
