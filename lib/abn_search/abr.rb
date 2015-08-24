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

    # Performs an ABR search for the ABN setup upon initialization
    #
    # @param [String] acn - the acn you wish to search for
    # @return [ABNSearch] search results in class instance
    # TODO: cleanup the acn method
    def search_by_acn(acn)
      @@errors << "No ACN provided." && return if acn.nil?
      @@errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if @@guid.nil?

      begin
        client = Savon.client(@@client_options)

        response = client.call(:abr_search_by_asic, message: { authenticationGuid: @@guid, searchString: acn.gsub(" ", ""), includeHistoricalDetails: "N" })
        # puts "First response: #{response}"
        result = response.body[:abr_search_by_asic_response][:abr_payload_search_results][:response][:business_entity]
        # puts "Filtered result: #{result}"
        # puts "ABN: #{(result[:abn][:identifier_value] rescue "")}"
        # puts "Entity Type: #{(result[:entity_type][:entity_description] rescue "")}"
        # puts "Status: #{(result[:entity_status][:entity_status_code] rescue "")}"
        # puts "Main name: #{(result[:main_name][:organisation_name] rescue "")}"
        # puts "Trading name: #{(result[:main_trading_name][:organisation_name] rescue "")}"
        # puts "Legal name: #{(result[:legal_name][:full_name] rescue "")}"
        # puts "Other Trading name: #{(result[:other_trading_name][:organisation_name] rescue "")}"
        # puts "Active from date: #{(result[:entity_status][:effective_from] rescue "")}"
        # puts "Address state code: #{(result[:main_business_physical_address][:state_code] rescue "")}"
        # puts "Address post code: #{(result[:main_business_physical_address][:postcode] rescue "")}"
        # puts "Address from date: #{(result[:main_business_physical_address][:effective_from] rescue "")}"

        return parse_search_result(result)
      rescue => ex
        @@errors << ex.to_s
      end
    end

    # Performs an ABR search for the ABN setup upon initialization
    #
    # @param [String] abn - the abn you wish to search for
    # @return [ABNSearch] search results in class instance
    def self.search(abn)
      raise ArgumentError, "ABN #{abn} is invalid" unless ABNSearch::ABN.valid?(abn)
      raise ArgumentError, 'No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx' if @@guid.nil?

      begin
        client = Savon.client(@@client_options)

        response = client.call(:abr_search_by_abn, message: { authenticationGuid: @@guid, searchString: abn.gsub(/\s+/, ""), includeHistoricalDetails: "N" })
        response.body[:abr_search_by_abn_response][:abr_payload_search_results][:response][:business_entity]
      rescue => e
        raise "ABNSearch::ABN#search raised #{e.class}: #{e.message}"
      end
    end

    # Searches the ABR registry by name. Simply pass in the search term and which state(s) to search in.
    #
    # @param [String] name - the search term
    # @param [Hash] options hash - :states, :postcode and :parse_results
    # @param [String] postcode - the postcode you wish to filter by
    # TODO: clean up this method
    def search_by_name(name, options={})

      @@errors << "No search phrase provided." && return if name.nil?
      @@errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if @@guid.nil?

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

  end

end
