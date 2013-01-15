module Beanstreamy
  class Config
    attr_accessor :payment_url, :merchant_id, :hash_key, :approved_url, :declined_url, :error_url

    def initialize
      @payment_url = "https://www.beanstream.com/scripts/payment/payment.asp"
    end
  end

  mattr_accessor :config
  @@config = Config.new
end

require 'beanstreamy/util'

if defined?(ActiveMerchant)
  require 'beanstreamy/gateway'
end

if defined?(ActionView)
  require 'beanstreamy/hosted_payment_helper'

  ActionView::Base.send :include, Beanstreamy::HostedPaymentHelper
end
