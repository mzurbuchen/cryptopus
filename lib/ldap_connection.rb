# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

 require 'net/ldap'

 class LdapConnection

   MANDATORY_LDAP_SETTING_KEYS = %i(hostname portnumber basename).freeze
   LDAP_SETTING_KEYS = (MANDATORY_LDAP_SETTING_KEYS + %i(bind_dn bind_password)).freeze

   def initialize

     collect_settings
     assert_setting_values
   end

   def login(username, password)
     return false unless username_valid?(username)
     result = connection.bind_as({base: ldap_config[:basename], filter: "uid=#{username}", password: password})


     ldap = connection({ method: :simple, username: result.first.dn, password: password })
     ldap.bind
   end

   def ldap_info(uid, attribute)
    filter = Net::LDAP::Filter.eq('uidnumber', uid)
    ldap_config.search(base: ldap_config[:basename],
                 filter: filter,
                 attributes: [attribute]) do |entry|
                   entry.each do |attr, values|
                     if attr.to_st == attribute
                       return values[0].to_s
                     end
                   end
                 end
                 "No <#{attribute} for uid #{uid}>"
   end

   private

   attr_reader :ldap_config, :settings

   def collect_settings
     @settings = {}
     LDAP_SETTING_KEYS.each do |k|
       @settings[k] = Setting.value(:ldap, k)
     end

   end

   def assert_setting_values
     MANDATORY_LDAP_SETTING_KEYS.each do |k|
       raise ArgumentError.new("missing config field: #{k}") unless settings[k].present?
     end
   end

   def username_valid?(username)
     username =~ /^[a-zA-Z\d]+$/
   end

   def connection(options = {})
     params =   { host: settings[:hostname], port: @ldap_config[:port], encryption: :simple_tls }
     params.merge(options)
     Net::LDAP.new(params)
   end
 end
