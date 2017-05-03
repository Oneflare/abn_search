# frozen_string_literal: true

module Abn

  class Client

    SOAP_API_WSDL_URL = "http://www.abn.business.gov.au/abrxmlsearch/ABRXMLSearch.asmx?WSDL"

    attr_accessor :errors, :guid, :proxy, :client_options

    # Setup a new instance of the ABN search class.
    #
    # @param [String] guid - the ABR GUID for Web Services access
    # @param [Hash] options - options detailed below
    # @option options [String] :proxy Proxy URL string if required (Example: http://user:pass@host.example.com:443)
    # @return [ABNSearch]
    def initialize(guid = nil, options = {})
      self.errors = []
      self.guid = guid
      self.proxy = options[:proxy]

      # savon client options
      self.client_options = { wsdl: SOAP_API_WSDL_URL }
      client_options[:proxy] = proxy if proxy
    end

    # Performs an ABR search for the ABN setup upon initialization
    #
    # @param [String] acn - the acn you wish to search for
    # @return [Hash] search result in a hash
    def search_by_acn(acn)
      self.errors << "No ACN provided." && return if acn.nil?
      self.errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if self.guid.nil?

      begin
        client = Savon.client(self.client_options)
        response = client.call(:abr_search_by_asic, message: { authenticationGuid: self.guid, searchString: acn.gsub(" ", ""), includeHistoricalDetails: "N" })
        result = response.body[:abr_search_by_asic_response][:abr_payload_search_results][:response][:business_entity]
        return parse_search_result(result)
      rescue => ex
        self.errors << ex.to_s
      end
    end

    # Performs an ABR search for the ABN setup upon initialization
    #
    # @param [String] abn - the abn you wish to search for
    # @return [Hash] search result in a hash
    def search(abn)
      self.errors << "No ABN provided." && return if abn.nil?
      self.errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if self.guid.nil?

      begin
        client = Savon.client(self.client_options)
        response = client.call(:abr_search_by_abn, message: { authenticationGuid: guid, searchString: abn.gsub(" ", ""), includeHistoricalDetails: "N" })
        result = response.body[:abr_search_by_abn_response][:abr_payload_search_results][:response][:business_entity]
        return parse_search_result(result)
      rescue => ex
        self.errors << ex.to_s
      end
    end

    # Searches the ABR registry by name. Simply pass in the search term and which state(s) to search in.
    #
    # @param [String] name - the search term
    # @param [Array] states - a list of states that you wish to filter by
    # @param [String] postcode - the postcode you wish to filter by
    # @return [Array] search results in an array
    def search_by_name(name, states=["NSW"], postcode="ALL")

      begin
        client = Savon.client(self.client_options)
        request = {
          externalNameSearch: {
            authenticationGuid: self.guid, name: name,
            filters: {
              nameType: {
                tradingName: "Y", legalName: "Y"
              },
              postcode: postcode,
              "stateCode" => {
                "QLD" => states.include?("QLD") ? "Y" : "N",
                "NT" => states.include?("NT") ? "Y" : "N",
                "SA" => states.include?("SA") ? "Y" : "N",
                "WA" => states.include?("WA") ? "Y" : "N",
                "VIC" => states.include?("VIC") ? "Y" : "N",
                "ACT" => states.include?("ACT") ? "Y" : "N",
                "TAS" => states.include?("TAS") ? "Y" : "N",
                "NSW" => states.include?("NSW") ? "Y" : "N"
              }
            }
          },
          authenticationGuid: self.guid
        }

        response = client.call(:abr_search_by_name, message: request)
        result_list = response.body[:abr_search_by_name_response][:abr_payload_search_results][:response][:search_results_list]

        if result_list.empty?
          return []
        else
          results = response.body[:abr_search_by_name_response][:abr_payload_search_results][:response][:search_results_list][:search_results_record]
          return [parse_search_result(results)] if !results.is_a?(Array)
          return results.map do |r| parse_search_result(r) end
        end
      rescue => ex
        self.errors << ex.to_s
      end
    end

    def parse_search_result(result)
      entity = Abn::Entity.new
      entity.acn                = result[:asic_number] rescue nil
      entity.abn                = result[:abn][:identifier_value] rescue nil
      entity.entity_type        = result[:entity_type][:entity_description] rescue nil
      entity.status             = result[:entity_status][:entity_status_code] rescue nil
      entity.main_name          = result[:main_name][:organisation_name] rescue nil
      entity.trading_name       = result[:main_trading_name][:organisation_name] rescue nil
      entity.legal_name         = "#{result[:legal_name][:given_name]} #{result[:legal_name][:family_name]}" rescue nil
      entity.legal_name2        = result[:full_name] rescue nil
      entity.other_trading_name = result[:other_trading_name][:organisation_name] rescue nil
      entity.active_from_date   = result[:entity_status][:effective_from] rescue nil
      entity.address_state_code = result[:main_business_physical_address][:state_code] rescue nil
      entity.address_post_code  = result[:main_business_physical_address][:postcode] rescue nil
      entity.address_from_date  = result[:main_business_physical_address][:effective_from] rescue nil
      entity.last_updated       = result[:record_last_updated_date] rescue nil
      entity.gst_from_date      = result[:goods_and_services_tax][:effective_from] rescue nil
      entity.name               = entity.best_name
      return entity.instance_values
    end

    def valid?
      errors.empty?
    end

  end

end
