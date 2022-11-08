# frozen_string_literal: true

# name: discourse-asktug
# about: Discourse plugin for asktug.com
# version: 0.0.1
# authors: Hooopo Wang
# url: https://github.com/hooopo/discourse-asktug
# required_version: 2.7.0

PLUGIN_NAME ||= 'discourse-asktug'

enabled_site_setting :asktug_enabled

after_initialize do
  [
    "../config/initializers/fake_email_interceptor.rb",
    "../app/jobs/scheduled/helper_reminder.rb"
  ].each { |path| require File.expand_path(path, __FILE__) }
end
