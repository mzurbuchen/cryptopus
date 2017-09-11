# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::MaintenanceTasksController < Admin::AdminController

  helper_method :removed_ldap_users

  # GET /admin/maintenance_tasks
  def index
    @maintenance_tasks = MaintenanceTask.list
    @maintenance_logs = Log.where(log_type: 'maintenance_task')
  end

  # DELETE /admin/users/1
  def destroy
    user.destroy

    respond_to do |format|
      format.html do
        redirect_to admin_users_path
      end
    end
  end

  # GET /admin/maintenance_tasks/1/prepare
  def prepare
    task = MaintenanceTask::TASKS[params[:id].to_i]
    @maintenance_task = MaintenanceTask.constantize_class(task)
    flash[:notice] = @maintenance_task.hint
  end

  # POST /admin/maintenance_tasks/1/execute
  def execute
    param_values = { private_key: session[:private_key] }

    param_values.merge!(params[:task_params])
    task = MaintenanceTask.initialize_task(params[:id], current_user, param_values)

    if task.execute
      flash[:notice] = t('flashes.admin.maintenance_tasks.succeed')
    else
      flash[:error] = t('flashes.admin.maintenance_tasks.failed')
    end
    redirect_to admin_maintenance_tasks_path
  end

  def removed_ldap_users
    if Setting.value('ldap', 'enable') == false
      raise 'cannot list removed ldap users if ldap is disabled'
    end

    ldap_connection = LdapConnection.new

    User.ldap.collect do |user|
      user unless ldap_connection.exists?(user.username)
    end.compact

  end

  private

  def user
    @user ||= User.find(params[:id])
  end

  def ldap_usernames
    User.ldap.collect { |user| user.username }
  end
end
