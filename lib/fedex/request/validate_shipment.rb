# frozen_string_literal: true

require 'fedex/request/base'
require 'fedex/request/shipment'

module Fedex
  module Request
    class ValidateShipment < Shipment

      private

      def failure_response(api_response, response, request)
        error_message = begin
                          if response[:shipment_reply]
                            [response[:shipment_reply][:notifications]].flatten.first[:message]
                          else
                            "#{api_response["Fault"]["detail"]["fault"]["reason"]}\n--#{api_response["Fault"]["detail"]["fault"]["details"]["ValidationFailureDetail"]["message"].join("\n--")}"
                          end
                        rescue StandardError
                          $1
                        end
        raise RateError.new(error_message, api_response, request)
      end

      def success_response(_api_response, response)
        @response_details = response[:shipment_reply]
      end

      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.ValidateShipmentRequest(xmlns: "http://fedex.com/ws/ship/v#{service[:version]}")  do
            add_standard_request_details(xml)

            add_requested_shipment(xml)
          end
        end
        builder.doc.root.to_xml
      end

      # Successful request
      def success?(response)
        response[:shipment_reply] &&
          %w{SUCCESS WARNING NOTE}.include?(response[:shipment_reply][:highest_severity])
      end
    end
  end
end
