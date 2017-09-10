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

  def execute
    super do
      raise 'Only admins can run this Task' unless @current_user.admin?

      list_removed_ldap_users

      list_all_users
    end
  end

  private

  def list_removed_ldap_users
    User.find_each { |user| return user unless user.present? }
  end

  def list_all_users

  end
end
