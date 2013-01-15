require 'test_helper'

class NavigationTest < ActiveSupport::IntegrationCase
  test 'payment index page renders a beanstream form' do
    visit payment_path
    assert page.has_selector?("form#sample_form")
  end
end
