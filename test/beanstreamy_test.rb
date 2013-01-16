require 'test_helper'

class BeanstreamyTest < ActionView::TestCase
  include Beanstreamy::HostedPaymentHelper

  test "beanstream_hosted_payment_form returns a form" do
    actual = beanstream_hosted_payment_form(3456, :id => "sample_form", :merchant_id => "454353534", :hash_key => "FK49Clk34Jd")
    expected = %q(<form action="https://www.beanstream.com/scripts/payment/payment.asp" id="sample_form" method="post"><input id="merchant_id" name="merchant_id" type="hidden" value="454353534" /><input id="trnAmount" name="trnAmount" type="hidden" value="34.56" /><input id="ordItemPrice" name="ordItemPrice" type="hidden" value="0.00" /><input id="ordShippingPrice" name="ordShippingPrice" type="hidden" value="0.00" /><input id="ordTax1Price" name="ordTax1Price" type="hidden" value="0.00" /><input id="ordTax2Price" name="ordTax2Price" type="hidden" value="0.00" /><input id="hashValue" name="hashValue" type="hidden" value="492c29aa7563f3dfefbcfd79806b2b5b504e323c" /></form>)
    assert_dom_equal expected, actual
  end
end
