#
# ABR Search
#
# Request examples;
#
# Search by ABN
# > a = ABNSearch::Client.new("your-guid")
# > result = a.search("56206894472")
#
# Search by name and return an array of results
# > a = ABNSearch::Client.new("your-guid")
# > result = a.search_by_name("Sony", {states:['NSW', 'VIC']})
# > another_result = a.search_by_name("Sony", {postcode:2040})
#

require 'savon'

module ABNSearch

  class Client

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
      self
    end

    # Performs an ABR search by ASIC
    #
    # @param [String] acn - the acn you wish to search for
    # @return [Hash] a hash containing result status (:result) and payload (:payload)
    def self.search_by_acn(acn)
      raise ArgumentError, "ACN #{acn} is invalid" unless ABNSearch::Entity.valid_acn?(acn)
      check_guid

      client = Savon.client(@@client_options)

      response = client.call(:abr_search_by_asic, message: { authenticationGuid: @@guid, searchString: acn.gsub(" ", ""), includeHistoricalDetails: "N" })

      validate_response(response,:abr_search_by_asic_response)
    end

    # Performs an ABR search by ABN
    #
    # @param [String] abn - the abn you wish to search for
    # @return [Hash] a hash containing result status (:result) and payload (:payload)
    def self.search(abn)
      raise ArgumentError, "ABN #{abn} is invalid" unless ABNSearch::Entity.valid?(abn)
      check_guid

      client = Savon.client(@@client_options)

      response = client.call(:abr_search_by_abn, message: { authenticationGuid: @@guid, searchString: abn.gsub(/\s+/, ""), includeHistoricalDetails: "N" })

      validate_response(response,:abr_search_by_abn_response)
    end

    # Performs an ABR search by name
    #
    # @param [String] name - the search term
    # @param [Hash] options hash - :states, :postcode
    # @option options [Array] :states - a list of states you which to include
    # @option options [String] :postcode - a postcode to which to confine your Search
    # @param [String] postcode - the postcode you wish to filter by
    # TODO: clean up this method
    def self.search_by_name(name, options={})
      raise ArgumentError, "No search string provided" unless name.is_a?(String)
      check_guid

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

      results = response.body[:abr_search_by_name_response][:abr_payload_search_results][:response][:search_results_list]
      raise "ABR exception: #{response.body[:abr_search_by_name_response][:abr_payload_search_results][:response][:exception][:exception_description]}" if results.nil?

      abns = []

      results[:search_results_record].each do |r|
        abns << ABNSearch::Entity.new(abr_detail: r)
      end

      return abns

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
