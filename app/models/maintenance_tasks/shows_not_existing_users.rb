# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 33 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class MaintenanceTasks::ShowsNotExistingUsers < MaintenanceTask
  self.label = 'Not existing users'
  self.description = 'Shows not existing users.'
  self.task_params = [{ label: :delete_user }]

  def execute
    super do
      raise 'Only admins can run this Task' unless @current_user.admin?

      not_existing_users
    end
  end

  private

  def not_existing_users
    User.find_each { |user| return user unless user.exists? }
  end
end
