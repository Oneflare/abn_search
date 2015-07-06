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

    attr_accessor :errors, :guid, :proxy, :client_options

    # Setup a new instance of the ABN search class.
    #
    # @param [String] guid - the ABR GUID for Web Services access
    # @param [Hash] options - options detailed below
    # @option options [String] :proxy Proxy URL string if required (Example: http://user:pass@host.example.com:443)
    # @return [ABNSearch]
    #
    def initialize(guid=nil, options = {})
      self.errors = []
      self.guid = guid unless guid.nil?
      self.proxy = options[:proxy] || nil
      self.client_options = {}
      self.client_options = { :wsdl => "http://www.abn.business.gov.au/abrxmlsearch/ABRXMLSearch.asmx?WSDL" }
      self.client_options.merge!({ :proxy => self.proxy }) unless self.proxy.nil?
    end

    # Performs an ABR search for the ABN setup upon initialization
    #
    # @param [String] acn - the acn you wish to search for
    # @return [ABNSearch] search results in class instance
    def search_by_acn(acn)
      self.errors << "No ACN provided." && return if acn.nil?
      self.errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if self.guid.nil?

      begin
        client = Savon.client(self.client_options)

        response = client.call(:abr_search_by_asic, message: { authenticationGuid: self.guid, searchString: acn.gsub(" ", ""), includeHistoricalDetails: "N" })
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
        self.errors << ex.to_s
      end
    end

    # Performs an ABR search for the ABN setup upon initialization
    #
    # @param [String] abn - the abn you wish to search for
    # @return [ABNSearch] search results in class instance
    def search(abn)
      self.errors << "No ABN provided." && return if abn.nil?
      self.errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if self.guid.nil?

      begin
        client = Savon.client(self.client_options)

        response = client.call(:abr_search_by_abn, message: { authenticationGuid: self.guid, searchString: abn.gsub(" ", ""), includeHistoricalDetails: "N" })
        # puts "First response: #{response}"
        result = response.body[:abr_search_by_abn_response][:abr_payload_search_results][:response][:business_entity]
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
        self.errors << ex.to_s
      end
    end

    # Searches the ABR registry by name. Simply pass in the search term and which state(s) to search in.
    #
    # @param [String] name - the search term
    # @param [Hash] options hash - :states, :postcode and :parse_results
    # @param [String] postcode - the postcode you wish to filter by
    def search_by_name(name, options={})

      self.errors << "No search phrase provided." && return if name.nil?
      self.errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if self.guid.nil?

      begin
        options[:states]        ||= ['NSW','QLD','VIC','SA','WA','TAS','ACT','NT']
        options[:postcode]      ||= 'ALL'
        client = Savon.client(self.client_options)
        request = {
          externalNameSearch: {
            authenticationGuid: self.guid, name: name,
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
          authenticationGuid: self.guid
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
        self.errors << ex.to_s
      end
    end

    # Parses results for a search by ABN
    def parse_search_result(result)
      result = {
        acn:                  (result[:asic_number] rescue ""),
        abn:                  (result[:abn][:identifier_value] rescue ""),
        abn_status:           (result[:abn][:identifier_status] rescue ""),
        entity_type:          result[:entity_type].blank? ? "" : (result[:entity_type][:entity_description] rescue ""),
        status:               result[:entity_status].blank? ? "" : (result[:entity_status][:entity_status_code] rescue ""),
        main_name:            result[:main_name].blank? ? "" : (result[:main_name][:organisation_name] rescue ""),
        trading_name:         result[:main_trading_name].blank? ? "" : (result[:main_trading_name][:organisation_name] rescue ""),
        legal_name:           result[:legal_name].blank? ? "" : ("#{result[:legal_name][:given_name]} #{result[:legal_name][:family_name]}" rescue ""),
        legal_name2:          result[:legal_name].blank? ? "" : (result[:legal_name][:full_name] rescue ""),
        other_trading_name:   result[:other_trading_name].blank? ? "" : (result[:other_trading_name][:organisation_name] rescue ""),
        active_from_date:     result[:entity_status].blank? ? "" : (result[:entity_status][:effective_from] rescue ""),
        address_state_code:   result[:main_business_physical_address].blank? ? "" : (result[:main_business_physical_address][:state_code] rescue ""),
        address_post_code:    result[:main_business_physical_address].blank? ? "" : (result[:main_business_physical_address][:postcode] rescue ""),
        address_from_date:    result[:main_business_physical_address].blank? ? "" : (result[:main_business_physical_address][:effective_from] rescue ""),
        last_updated:         (result[:record_last_updated_date] rescue ""),
        gst_from_date:        result[:goods_and_services_tax].blank? ? "" : (result[:goods_and_services_tax][:effective_from] rescue "")
      }

      # Work out what we should return as a name
      result[:name] = [ result[:trading_name],
        result[:other_trading_name],
        result[:main_name],
        result[:legal_name],
        result[:legal_name2],
        'Name unknown'
      ].reject{|x| x.to_s.strip.blank?}.first

      return result
    end

    def valid?
      self.errors.size == 0
    end
  end

end
