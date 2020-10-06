module Fedex
  class Rates
		attr_reader :request_xml, :response_xml, :rates

		def initialize(rates = [], request_xml: '', response_xml: '')
			@rates = rates
			@request_xml = request_xml unless request_xml.empty?
      		@response_xml = response_xml unless response_xml.empty?
		end
	end
end