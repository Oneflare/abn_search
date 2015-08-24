#
# ABN Object
#
module ABNSearch
  class ABN

    @acn                = nil
    @abn                = nil
    @abn_current        = nil
    @entity_type        = nil
    @status             = nil
    @main_name          = nil
    @trading_name       = nil
    @legal_name         = nil
    @legal_name2        = nil
    @other_trading_name = nil
    @active_from_date   = nil
    @address_state_code = nil
    @address_post_code  = nil
    @address_from_date  = nil
    @last_updated       = nil
    @gst_from_date      = nil

    attr_accessor :acn, :abn, :abn_current, :entity_type, :status, :main_name, :trading_name, :legal_name, :legal_name2, :other_trading_name, :active_from_date, :address_state_code, :address_post_code, :address_from_date, :last_updated, :gst_from_date

    # Initialize an ABN object
    #
    # @param abn [String or Integer] the Australian Business Number (ABN)
    # @return [ABNSearch::ABN] an instance of ABNSearch::ABN is returned
    def initialize(abn)
      # try to mash the input into something usable
      abn = abn.to_s.gsub(/\s+/,"")
      raise ArgumentError.new("ABN is not 11 numberical digits") if (abn =~ /^[0-9]{11}$/).nil?
      @abn = abn
    end

    # Test to see if an ABN is valid
    #
    # @return [Boolean] true or false
    def valid?
      return false unless @abn.is_a?(String)
      return false unless @abn.length == 11
      weighting = [10,1,3,5,7,9,11,13,15,17,19]
      chksum = 0
      (0..10).each do |d|
        chksum += ( @abn[d].to_i - (d.zero? ? 1 : 0) ) * weighting[d]
      end
      return (chksum % 89) == 0
    rescue => e
      puts "Error: #{e.class}\n#{e.backtrace.join("\n")}"
      return false
    end

    # Return a nicely formatted string for valid abns, or
    # an empty string for invalid abns
    #
    # @return [String]
    def to_s
      valid? ? "%s%s %s%s%s %s%s%s %s%s%s" % @abn.split('') : ""
    end

    # Just check if an ABN is valid
    # @param abn [String or Integer] the Australian Business Number
    # @return [Boolean]
    def self.valid?(abn)
       new(abn).valid?
    end

    # Update the ABN object with information from the ABR
    #
    # @return [self]
    def update_from_abr!
      # local cache
      abr_detail = ABNSearch::ABR.search(@abn)
      # parse this stuff
      @acn                = abr_detail[:asic_number] rescue nil
      @abn                = abr_detail[:abn][:identifier_value] rescue nil
      @abn_current        = abr_detail[:abn][:is_current_indicator] rescue nil
      @entity_type        = abr_detail[:entity_type][:entity_description] rescue nil
      @status             = abr_detail[:entity_status][:entity_status_code] rescue nil
      @main_name          = abr_detail[:main_name][:organisation_name] rescue nil
      @trading_name       = abr_detail[:main_trading_name][:organisation_name] rescue nil
      @legal_name         = "#{abr_detail[:legal_name][:given_name]} #{abr_detail[:legal_name][:family_name]}" rescue nil
      @legal_name2        = abr_detail[:full_name] rescue nil
      @other_trading_name = abr_detail[:other_trading_name][:organisation_name] rescue nil
      @active_from_date   = abr_detail[:entity_status][:effective_from] rescue nil
      @address_state_code = abr_detail[:main_business_physical_address][:state_code] rescue nil
      @address_post_code  = abr_detail[:main_business_physical_address][:postcode] rescue nil
      @address_from_date  = abr_detail[:main_business_physical_address][:effective_from] rescue nil
      @last_updated       = abr_detail[:record_last_updated_date] rescue nil
      @gst_from_date      = abr_detail[:goods_and_services_tax][:effective_from] rescue nil

      self
    end

    # Choose the most relevant business name
    #
    # @return [String] business name
    def name
      @trading_name || @other_trading_name || @main_name || @legal_name || @legal_name2 || 'Name unknown'
    end

  end
end
