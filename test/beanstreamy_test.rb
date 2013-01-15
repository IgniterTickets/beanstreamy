require 'test_helper'

class BeanstreamyTest < ActionView::TestCase
  include Beanstreamy::HostedPaymentHelper

  test "beanstream_hosted_payment_form renders a form" do
    beanstream_hosted_payment_form(3456, :id => "sample_form", :merchant_id => "454353534", :hash_key => "FK49Clk34Jd") do
    end
    assert_select "form#sample_form"
  end
end
