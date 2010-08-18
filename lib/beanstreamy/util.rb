module Beanstreamy
  module Util

    def self.hash_value(key, message)
      Digest::SHA1.hexdigest(message + key)
    end

    def self.amount(cents)
      sprintf("%.2f", cents.to_f / 100)
    end

    def self.hash_expiry(expire_at)
      # Beanstream uses PST/PDT for all their timestamps. Time stamps only have minute resolution,
      # so the seconds need chopping off.
      expire_at.in_time_zone("Pacific Time (US & Canada)").to_s(:number)[0..-3]
    end

    def self.add_address(params, options)
      prepare_address_for_non_american_countries(options)
      # Bug Alert:
      # IE8 - URI not escaping '@' as '%40' combined with Beanstream's bewildering hash computations
      #
      # Firefox parameters posted:
      #
      # merchant_id=208950000&trnAmount=212.00&approvedPage=http%3A%2F%2F192.168.1.120%3A3000%2Fcheckout%2Fapproved&declinedPage=http%3A%2F%2F192.168.1.120%3A3000%2Fcheckout%2Fdeclined&errorPage=http%3A%2F%2F192.168.1.120%3A3000%2Fcheckout%2Fdeclined&hashExpiry=201008171546&ordTax1Price=0.00&ordAddress1=%231511+9918+101st&shipCity=Edmonton&ordProvince=AB&shipName=Timothy+Frison&ordItemPrice=212.00&shipProvince=AB&ordName=Timothy+Frison&shipEmailAddress=dalorface%40gmail.com&ordAddress2=&shipPostalCode=T5K2L1&ordPostalCode=T5K2L1&ordEmailAddress=dalorface%40gmail.com&ordTax2Price=0.00&shipPhoneNumber=5433215123&ordShippingPrice=0.00&shipCountry=CA&ordPhoneNumber=5433215123&trnOrderNumber=R641043381&shipAddress1=%231511+9918+101st&ordCity=Edmonton&ordCountry=CA&shipAddress2=&trnCardOwner=Timothy+Frison&hashValue=94d4593177b06626e650c8b664e844f297941e3b&trnCardType=VI&trnCardNumber=4030000010001234+&trnCardCvd=123&trnExpMonth=08&trnExpYear=10&commit=Purchase+Tickets
      #
      # IE 8 parameters posted:
      # merchant_id=208950000&trnAmount=212.00&approvedPage=http%3A%2F%2F192.168.1.120%3A3000%2Fcheckout%2Fapproved&declinedPage=http%3A%2F%2F192.168.1.120%3A3000%2Fcheckout%2Fdeclined&errorPage=http%3A%2F%2F192.168.1.120%3A3000%2Fcheckout%2Fdeclined&hashExpiry=201008171549&ordTax1Price=0.00&ordAddress1=%231511+9918+101st&shipCity=Edmonton&ordProvince=AB&shipName=Timothy+Frison&ordItemPrice=212.00&shipProvince=AB&ordName=Timothy+Frison&shipEmailAddress=dalorface@gmail.com&ordAddress2=&shipPostalCode=T5K2L1&ordPostalCode=T5K2L1&ordEmailAddress=dalorface@gmail.com&ordTax2Price=0.00&shipPhoneNumber=5433215123&ordShippingPrice=0.00&shipCountry=CA&ordPhoneNumber=5433215123&trnOrderNumber=R360757155&shipAddress1=%231511+9918+101st&ordCity=Edmonton&ordCountry=CA&shipAddress2=&trnCardOwner=Timothy+Frison&hashValue=138ff5d52ffef909e88791c55a9a2365599c55b8&trnCardType=VI&trnCardNumber=4030000010001234+&trnCardCvd=123&trnExpMonth=08&trnExpYear=10&commit=Purchase+Tickets
      #
      # Note the difference for: shipEmailAddress and ordEmailAddress
      #
      # In short, hash validation fails in IE8 because of the way '@' is not URI escaped in IE.
      # The solution: No longer 'require' an address to be posted to beanstream, post all the
      # address EXCEPT the email. This way hash validation will pass.
      #
      # Mike Ketler (mketler@beanstream.com) and Chris Lloyd (clloyd@beanstream.com) were the
      # contact points for this. Mike handled the technical side of things. We diagnosed the issue,
      # and the 'kludge' solution is don't send the email (which we proposed as the solution).
      if billing_address = options[:billing_address] || options[:address]
        params[:ordName]          = billing_address[:name]
       # params[:ordEmailAddress]  = options[:email] # IE8 HATES EMAIL ADDRESS + BEANSTREAM
        params[:ordPhoneNumber]   = billing_address[:phone]
        params[:ordAddress1]      = billing_address[:address1]
        params[:ordAddress2]      = billing_address[:address2]
        params[:ordCity]          = billing_address[:city]
        params[:ordProvince]      = billing_address[:province]    || billing_address[:state]
        params[:ordPostalCode]    = billing_address[:postal_code] || billing_address[:zip]
        params[:ordCountry]       = billing_address[:country]
      end

      if shipping_address = options[:shipping_address]
        params[:shipName]         = shipping_address[:name]
       # params[:shipEmailAddress] = options[:email] # IE8 HATES EMAIL ADDRESS + BEANSTREAM WIL
        params[:shipPhoneNumber]  = shipping_address[:phone]
        params[:shipAddress1]     = shipping_address[:address1]
        params[:shipAddress2]     = shipping_address[:address2]
        params[:shipCity]         = shipping_address[:city]
        params[:shipProvince]     = shipping_address[:province]    || shipping_address[:state]
        params[:shipPostalCode]   = shipping_address[:postal_code] || shipping_address[:zip]
        params[:shipCountry]      = shipping_address[:country]
        params[:shippingMethod]   = shipping_address[:shipping_method]
        params[:deliveryEstimate] = shipping_address[:delivery_estimate]
      end  
    end

    def self.prepare_address_for_non_american_countries(options)
      [ options[:billing_address], options[:shipping_address] ].compact.each do |address|
        unless ['US', 'CA'].include?(address[:country])
          address[:province] = '--'
          address[:postal_code]   = '000000' unless address[:postal_code] || address[:zip]
        end
      end
    end

    def self.add_invoice(params, options)
      params[:trnOrderNumber]   = options[:order_id]
      params[:trnComments]      = options[:description]
      params[:ordItemPrice]     = amount(options[:subtotal])
      params[:ordShippingPrice] = amount(options[:shipping])
      params[:ordTax1Price]     = amount(options[:tax1] || options[:tax])
      params[:ordTax2Price]     = amount(options[:tax2])
      params[:ref1]             = options[:custom]
    end
  end
end
