#
# ABR Search
#
# Request examples;
#
# Search by ABN
# > a = ABNSearch::ABR.new("your-guid")
# > result = a.search("56206894472")
#
# Search by name and return an array of results
# > a = ABNSearch::ABR.new("your-guid")
# > result = a.search_by_name("Sony", {states:['NSW', 'VIC']})
# > another_result = a.search_by_name("Sony", {postcode:2040})
#

require 'savon'

module ABNSearch

  class ABR

    ENDPOINT = "http://www.abn.business.gov.au/abrxmlsearch/ABRXMLSearch.asmx?WSDL"

    @@errors          = []
    @@guid            = nil
    @@proxy           = nil
    @@client_options  = {}

    attr_accessor :errors, :guid, :proxy, :client_options

    # Setup a new instance of the ABN search class.
    #
    # @param [String] guid - the ABR GUID for Web Services access
    # @param [Hash] options - options detailed below
    # @option options [String] :proxy Proxy URL string if required (Example: http://user:pass@host.example.com:443)
    # @return [ABNSearch]
    #
    def initialize(guid, options = {})
      @@guid = guid
      @@proxy = options[:proxy] || nil
      @@client_options = { wsdl: ENDPOINT }
      @@client_options.merge!({ proxy: @@proxy }) unless @@proxy.nil?
    end

    # Performs an ABR search by ASIC
    #
    # @param [String] acn - the acn you wish to search for
    # @return [ABNSearch] search results in class instance
    def self.search_by_acn(acn)
      raise ArgumentError, "ACN #{acn} is invalid" unless ABNSearch::Entity.valid_acn?(acn)
      check_guid

      begin
        client = Savon.client(@@client_options)

        response = client.call(:abr_search_by_asic, message: { authenticationGuid: @@guid, searchString: acn.gsub(" ", ""), includeHistoricalDetails: "N" })

        validate_response(response,:abr_search_by_asic_response)

      rescue => e
        raise "ABNSearch::ABR#search_by_acn raised #{e.class}: #{e.message}"
      end
    end

    # Performs an ABR search by ABN
    #
    # @param [String] abn - the abn you wish to search for
    # @return [ABNSearch] search results in class instance
    def self.search(abn)
      raise ArgumentError, "ABN #{abn} is invalid" unless ABNSearch::Entity.valid?(abn)
      check_guid

      begin
        client = Savon.client(@@client_options)

        response = client.call(:abr_search_by_abn, message: { authenticationGuid: @@guid, searchString: abn.gsub(/\s+/, ""), includeHistoricalDetails: "N" })

        validate_response(response,:abr_search_by_abn_response)
      rescue => e
        raise "ABNSearch::ABR#search raised #{e.class}: #{e.message}"
      end
    end

    # Performs an ABR search by name
    #
    # @param [String] name - the search term
    # @param [Hash] options hash - :states, :postcode and :parse_results
    # @param [String] postcode - the postcode you wish to filter by
    # TODO: clean up this method
    def search_by_name(name, options={})
      raise ArgumentError, "No search string provided" unless name.is_a?(String)
      check_guid

      begin
        options[:states]        ||= ['NSW','QLD','VIC','SA','WA','TAS','ACT','NT']
        options[:postcode]      ||= 'ALL'
        client = Savon.client(@@client_options)
        request = {
          externalNameSearch: {
            authenticationGuid: @@guid, name: name,
            filters: {
              nameType: {
                tradingName: 'Y', legalName: 'Y'
              },
              postcode: options[:postcode],
              "stateCode" => {
                'QLD' => options[:states].include?('QLD') ? "Y" : "N",
                'NT' => options[:states].include?('NT') ? "Y" : "N",
                'SA' => options[:states].include?('SA') ? "Y" : "N",
                'WA' => options[:states].include?('WA') ? "Y" : "N",
                'VIC' => options[:states].include?('VIC') ? "Y" : "N",
                'ACT' => options[:states].include?('ACT') ? "Y" : "N",
                'TAS' => options[:states].include?('TAS') ? "Y" : "N",
                'NSW' => options[:states].include?('NSW') ? "Y" : "N"
              }
            }
          },
          authenticationGuid: @@guid
        }

        response = client.call(:abr_search_by_name, message: request)
        result_list = response.body[:abr_search_by_name_response][:abr_payload_search_results][:response][:search_results_list]

        if result_list.blank?
          return []
        else
          results = response.body[:abr_search_by_name_response][:abr_payload_search_results][:response][:search_results_list][:search_results_record]
          return [parse_search_result(results)] if !results.is_a?(Array)
          return results.map do |r| parse_search_result(r) end
        end
      rescue => ex
        @@errors << ex.to_s
      end
    end

    #######
    private
    #######

    def self.validate_response(response,expected_first_symbol)
      if response.body[expected_first_symbol][:abr_payload_search_results][:response][:business_entity].nil?
        return {
          result: :error,
          payload: response.body[expected_first_symbol][:abr_payload_search_results][:response][:exception]
        }
      else
        return {
          result: :success,
          payload: response.body[expected_first_symbol][:abr_payload_search_results][:response][:business_entity]
        }
      end
    end

    def self.check_guid
      raise ArgumentError, 'No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx' if @@guid.nil?
      true
    end

  end

end
