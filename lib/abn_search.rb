require 'nokogiri'
require 'open-uri'

class ABNSearch
  
  module Version
    VERSION = "0.0.1"
  end
  
  attr_accessor :name, :abn, :entity_type, :errors, :guid
  
  def initialize(abn=nil, guid=nil)
    self.errors = []
    self.abn = abn unless abn.nil?
    self.guid = guid unless guid.nil?
    self.search
  end

  def search    
    self.errors << "No ABN provided." && return if self.abn.nil?
    self.errors << "No GUID provided. Please obtain one at - http://www.abr.business.gov.au/Webservices.aspx" && return if self.guid.nil?
  
    @WSDL_URL = 'http://abr.business.gov.au/ABRXMLSearch/AbrXmlSearch.asmx/ABRSearchByABN?'    
    url = @WSDL_URL + "searchString=#{self.abn}&includeHistoricalDetails=n&authenticationGuid=#{self.guid}"
    doc = Nokogiri::HTML(open(url))
  
    # Fetch attributes we require
    base_path = '//html/body/abrpayloadsearchresults/response/businessentity'
    entity_type = doc.xpath(base_path + '/entitytype')
    abn = doc.xpath(base_path + '/abn/identifiervalue')
    trading_name = doc.xpath(base_path + '/maintradingname/organisationname')
    main_name = doc.xpath(base_path + '/mainname/organisationname')
    expires = doc.xpath(base_path + '/entitystatus/entitystatuscode')
    
    # Did we find a valid ABN?
    if abn[0].nil?
      self.errors << "Invalid ABN number."
      return
    end
  
    # Is the busines still valid?
    if expires && expires[0].content.include?("Cancelled")
      self.errors << "Business ABN #{self.abn} has expired."
      return
    end
  
    # Set ABN business attributes
    self.entity_type = entity_type[0].content unless entity_type[0].nil?
  
    # Set the business name. Sometimes there's no trading name .. but a "main name".
    if trading_name[0].nil?
      self.name = main_name[0].content
    else 
      self.name = trading_name[0].content
    end
  end
  
  def valid?
    self.errors.size == 0
  end
end