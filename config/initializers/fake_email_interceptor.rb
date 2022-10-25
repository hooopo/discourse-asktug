# frozen_string_literal: true
module FakeEmailInterceptor
  def send
    if @message && @message.to && @message.to.select { |email| email =~ /fake.email/ }.present?
      return skip(SkippedEmailLog.reason_types[:custom], custom_reason: 'fake email')
    end
    super
  end
end

::Email::Sender.send(:prepend, FakeEmailInterceptor)
