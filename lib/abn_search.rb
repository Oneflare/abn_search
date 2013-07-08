require 'nokogiri'
require 'open-uri'

class ABNSearch

  module Version
    VERSION = "0.0.3"
  end

  # The Entity Name
  attr_accessor :name
  # The Entity ABN
  attr_accessor :abn
  # The Entity Type
  attr_accessor :entity_type
  # Any errors returned from the search
  attr_accessor :errors

  # @private
  attr_accessor :guid, :proxy, :proxy_username, :proxy_password

  # Setup a new instance of the ABN search class. This performs a search on the ABN entered
  #
  # @param [String] abn - the abn to search
  # @param [String] guid - the ABR GUID for Web Services access
  # @param [Hash] options - options detailed below
  # @option options [String] :proxy Proxy URL if required
  # @option options [String] :proxy_username Username for proxy authentication
  # @option options [String] :proxy_password Password for proxy authentication
  # @return [ABNSearch]
  def initialize(abn=nil, guid=nil, options = {})
    self.errors = []
    self.abn = abn unless abn.nil?
    self.guid = guid unless guid.nil?
    self.name = "n/a"
    
    self.proxy = options.delete(:proxy)
    self.proxy_username = options.delete(:proxy_username)
    self.proxy_password = options.delete(:proxy_password)
    self.search
  end

  # Performs an ABR search for the ABN setup upon initialization
  #
  # @return [ABNSearch] search results in class instance
  def search
    self.errors << "No ABN provided." && return if self.abn.nil?
    self.errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if self.guid.nil?

    @WS_URL = "https://abr.business.gov.au/ABRXMLSearch/AbrXmlSearch.asmx/ABRSearchByABN?searchString=#{self.abn}&includeHistoricalDetails=n&authenticationGuid=#{self.guid}"
    
    open_options = {}
    if self.proxy_username && self.proxy_password && self.proxy
      open_options[:proxy_http_basic_authentication] = [self.proxy, self.proxy_username, self.proxy_password]
    elsif self.proxy
      open_options[:proxy] = self.proxy if self.proxy
    end

    doc = Nokogiri::HTML(open(@WS_URL, open_options))

    # Fetch attributes we require
    base_path = '//html/body/abrpayloadsearchresults/response/businessentity'
    entity_type = doc.xpath(base_path + '/entitytype')
    abn = doc.xpath(base_path + '/abn/identifiervalue')
    trading_name = doc.xpath(base_path + '/maintradingname/organisationname')
    main_name = doc.xpath(base_path + '/mainname/organisationname')
    legal_name = doc.xpath(base_path + '/legalname')
    expires = doc.xpath(base_path + '/entitystatus/entitystatuscode')

    # Did we find a valid ABN?
    if abn[0].nil?
      self.errors << "Invalid ABN number."
      return
    end

    # Is the business still valid?
    if expires && expires[0].content.include?("Cancelled")
      self.errors << "Business ABN #{self.abn} has expired."
      return
    end

    # Set ABN business attributes
    self.entity_type = entity_type[0].content unless entity_type[0].nil?

    # Set the business name. Sometimes there's no trading name .. but a "main name".
    if !trading_name[0].nil?
      self.name = trading_name[0].content
    elsif !main_name.empty?
      self.name = main_name[0].content
    elsif !legal_name.empty?
      self.name = legal_name[0].children.first.content
    end

    self
  end

  # Indicates if the results are valid or not (e.g. are there any errors such as Cancelled records)
  # @return [Boolean]
  def valid?
    self.errors.size == 0
  end
end