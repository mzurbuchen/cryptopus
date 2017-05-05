# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class LoginsController < ApplicationController

  before_filter :redirect_if_ldap_user, only: [:show_update_password, :update_password]
  before_filter :redirect_if_logged_in, only: [:login]

  skip_before_filter :verify_authenticity_token, only: [:authenticate]

  def login
  end

  def authenticate
    strength = PasswordStrength.test(params[:username], params[:password])
    authenticator = Authentication::UserAuthenticator.new(params)

    if authenticator.password_auth!
      begin
        create_session(authenticator.user, params[:password])
      rescue Exceptions::DecryptFailed
        redirect_to recryptrequests_new_ldap_password_path
        return
      end
      if strength.weak? || !strength.valid?
        flash[:alert] = t('flashes.logins.weak_password')
      end
      redirect_after_sucessful_login
    else
      flash[:error] = t('flashes.logins.auth_failed')
      redirect_to login_login_path
    end
  end

  def logout
    flash_notice = flash[:notice]
    reset_session
    flash[:notice] = flash_notice

    redirect_to params[:jumpto] || login_login_path
  end

  def show_update_password
    render :show_update_password
  end

  def update_password
    if password_params_valid?
      current_user.update_password(params[:old_password], params[:new_password1])
      flash[:notice] = t('flashes.logins.new_password_set')
      redirect_to teams_path
    else
      render :show_update_password
    end
  end

  # POST /login/changelocale
  def changelocale
    locale = params[:new_locale]
    if locale.present?
      current_user.update_attribute(:preferred_locale, locale)
    end

    redirect_to :back
  end

  private

  def create_session(user, password)
    user.update_info

    set_session_attributes(user, password)

    CryptUtils.validate_keypair(session[:private_key], user.public_key)
  end

  def redirect_after_sucessful_login
    if session[:jumpto].blank?
      redirect_to search_path
    else
      jump_to = session[:jumpto]
      session[:jumpto] = nil
      redirect_to jump_to
    end
  end

  def set_session_attributes(user, password)
    jumpto = session[:jumpto]
    reset_session
    session[:jumpto] = jumpto
    session[:username] = user.username
    session[:user_id] = user.id.to_s
    session[:private_key] = user.decrypt_private_key(password)
  end

  def redirect_if_ldap_user
    redirect_to search_path if current_user.ldap?
  end

  def redirect_if_logged_in
    redirect_to search_path if current_user
  end

  def password_params_valid?
    unless current_user.authenticate(params[:old_password])
      flash[:error] = t('flashes.logins.wrong_password')
      return false
    end

    if params[:new_password1] != params[:new_password2]
      flash[:error] = t('flashes.logins.new_passwords.not_equal')
      return false
    end
    true
  end
end
