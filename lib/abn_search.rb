#
# ABN Search
#
# Request examples;
#
# Search by ABN number
# > a = ABNSearch.new("your-guid")
# > result = a.search("56206894472")
#
# Search by name and return an array of results
# > a = ABNSearch.new("your-guid")
# > result = a.search_by_name("Sony", ['NSW', 'VIC'])
#

require 'savon'

class ABNSearch

  module Version
    VERSION = "0.0.5"
  end

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
  # @param [String] abn - the abn you wish to search for
  # @return [ABNSearch] search results in class instance
  def search(abn)
    self.errors << "No ABN provided." && return if abn.nil?
    self.errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if self.guid.nil?

    begin
      client = Savon.client(self.client_options)

      response = client.call(:abr_search_by_abn, message: { authenticationGuid: self.guid, searchString: abn.gsub(" ", ""), includeHistoricalDetails: "N" })
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
  def search_by_name(name, states=['NSW'], postcode='ALL')

    begin
      client = Savon.client(self.client_options)
      request = {
        externalNameSearch: {
          authenticationGuid: self.guid, name: name,
          filters: {
            nameType: {
              tradingName: 'Y', legalName: 'Y'
            },
            postcode: postcode,
            "stateCode" => {
              'QLD' => states.include?('QLD') ? "Y" : "N",
              'NT' => states.include?('NT') ? "Y" : "N",
              'SA' => states.include?('SA') ? "Y" : "N",
              'WA' => states.include?('WA') ? "Y" : "N",
              'VIC' => states.include?('VIC') ? "Y" : "N",
              'ACT' => states.include?('ACT') ? "Y" : "N",
              'TAS' => states.include?('TAS') ? "Y" : "N",
              'NSW' => states.include?('NSW') ? "Y" : "N"
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
      abn:            result[:abn][:identifier_value],
      entity_type:    result[:entity_type].blank? ? "" : result[:entity_type][:entity_description],
      status:         result[:entity_status].blank? ? "" : result[:entity_status][:entity_status_code],
      main_name:      result[:main_name].blank? ? "" : result[:main_name][:organisation_name],
      trading_name:   result[:main_trading_name].blank? ? "" : result[:main_trading_name][:organisation_name],
      legal_name:     result[:legal_name].blank? ? "" : "#{result[:legal_name][:given_name]} #{result[:legal_name][:family_name]}",
      legal_name2:     result[:legal_name].blank? ? "" : result[:legal_name][:full_name],
      other_trading_name: result[:other_trading_name].blank? ? "" : result[:other_trading_name][:organisation_name]
    }

    # Work out what we should return as a name
    if !result[:trading_name].blank?
      result[:name] = result[:trading_name]
    elsif !result[:main_name].blank?
      result[:name] = result[:main_name]
    elsif !result[:other_trading_name].blank?
      result[:name] = result[:other_trading_name]
    else
      if !result[:legal_name].blank? && result[:legal_name].length > 2
        result[:name] = result[:legal_name]
      elsif !result[:legal_name].blank?
        result[:name] = result[:legal_name2]
      end
    end

    return result
  end

  def valid?
    self.errors.size == 0
  end
end