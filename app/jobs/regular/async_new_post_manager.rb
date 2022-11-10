# frozen_string_literal: true
module Jobs
  class AsyncNewPostManager < ::Jobs::Base
    sidekiq_options queue: 'critical', retry: false

    def execute(opts)
      Rails.logger.info "start async group msg"
      user = User.find(opts[:user])
      manager = NewPostManager.new(user, opts[:manager])
      manager.perform
      Rails.logger.info "finish async group msg"
    end
  end
end
