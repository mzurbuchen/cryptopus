# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'net/ldap'

class LdapConnection

  MANDATORY_LDAP_SETTING_KEYS = %i[hostname portnumber basename].freeze
  LDAP_SETTING_KEYS = (MANDATORY_LDAP_SETTING_KEYS + %i[bind_dn bind_password]).freeze

  def initialize
    collect_settings
    assert_setting_values
  end

  def login(username, password)
    return false unless username_valid?(username)
    result = connection.bind_as(base: settings[:basename],
                                filter: "uid=#{username}",
                                password: password)
    if result
      ldap = connection(method: :simple, username: result.first.dn, password: password)
      return true if ldap.bind
    end
    false
  end

  def ldap_info(uidnumber, attribute)
    filter = Net::LDAP::Filter.eq('uidnumber', uidnumber)
    result = connection.search(base: settings[:basename],
                               filter: filter).try(:first).try(attribute).try :first
    result.present? ? result : "No <#{attribute} for uid #{uidnumber}>"
  end

  def uid_by_username(username)
    return unless username_valid?(username)
    filter = Net::LDAP::Filter.eq('uid', username)
    connection.search(base: settings[:basename],
                      filter: filter,
                      attributes: ['uidnumber']) do |entry|
                        return entry.uidnumber[0].to_s if entry.respond_to?(:uidnumber)
                      end
    raise 'UID of the user not found'
  end

  private

  attr_reader :settings

  def collect_settings
    @settings = {}
    LDAP_SETTING_KEYS.each do |k|
      @settings[k] = Setting.value(:ldap, k)
    end
  end

  def assert_setting_values
    MANDATORY_LDAP_SETTING_KEYS.each do |k|
      raise ArgumentError, "missing config field: #{k}" if settings[k].blank?
    end
  end

  def username_valid?(username)
    username =~ /^[a-zA-Z\d]+$/
  end

  def connection(options = {})
    params = { host: settings[:hostname], port: settings[:portnumber], encryption: :simple_tls }
    params.merge(options)
    Net::LDAP.new(params)
  end
end
