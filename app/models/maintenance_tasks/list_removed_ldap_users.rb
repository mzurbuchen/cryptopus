# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 33 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class MaintenanceTasks::ListRemovedLdapUsers < MaintenanceTask
  self.label = 'List removed ldap users'
  self.description = 'Lists the ldap users which have been removed.'
  self.task_params = [{ label: 'ListRemovedLdapUsers' }]
  self.executable = false
end
