#
# ABN Object
#
module ABNSearch
  class Entity

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
    # @param options [Hash] hash of options
    #
    # @return [ABNSearch::Entity] an instance of ABNSearch::Entity is returned
    def initialize(options={})
      # try to mash the input into something usable
      @abn        = options[:abn].to_s.gsub(/\s+/,"").rjust(11,"0") unless options[:abn] == nil
      @acn        = options[:acn].to_s.gsub(/\s+/,"").rjust(9,"0") unless options[:acn] == nil

    end

    # Update the ABN object with information from the ABR via ABN search
    #
    # @return [self]
    def update_from_abr!
      # local cache
      abr_detail = ABNSearch::ABR.search(@abn)
      # parse this stuff
      process_raw_abr_detail(abr_detail)
      self
    end

    # Update the ABN object with information from the ABR via ASIC search
    #
    # @return [self]
    def update_from_abr_using_acn!
      # local cache
      abr_detail = ABNSearch::ABR.search_by_acn(@acn)
      # parse this stuff
      process_raw_abr_detail(abr_detail)
      self
    end

    # Choose the most relevant business name
    #
    # @return [String] business name
    def name
      @trading_name || @other_trading_name || @main_name || @legal_name || @legal_name2 || 'Name unknown'
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

    # Just check if an ABN is valid
    # @param abn [String or Integer] the Australian Business Number
    # @return [Boolean]
    def self.valid?(abn)
       new({abn: abn}).valid?
    end

    # Test to see if the ABN has a valid ACN
    #
    # return [Boolean]
    def valid_acn?
      return false unless @acn.is_a?(String)
      return false unless @acn.length == 9
      weighting = [8,7,6,5,4,3,2,1]
      chksum = 0
      (0..7).each do |d|
        chksum += @acn[d].to_i * weighting[d]
      end
      return (10 - chksum % 10) % 10 == @acn[8].to_i
    rescue => e
      puts "Error: #{e.class}\n#{e.backtrace.join("\n")}"
      return false
    end

    # Just check if an ACN is valid
    # @param acn [String or Integer] the Australian Company Number
    # @return [Boolean]
    def self.valid_acn?(acn)
       new({acn: acn}).valid_acn?
    end

    # Return a nicely formatted string for valid abns, or
    # an empty string for invalid abns
    #
    # @return [String]
    def to_s
      valid? ? "%s%s %s%s%s %s%s%s %s%s%s" % @abn.split('') : ""
    end

    # Return a nicely formatted string for valid acns, or
    # an empty string for invalid acns
    #
    # @return [String]
    def acn_to_s
      valid_acn? ? "%s%s%s %s%s%s %s%s%s" % @acn.split('') : ""
    end

    #######
    private
    #######

    # Parse the ABR detail
    #
    # @return [self]
    def process_raw_abr_detail(abr_detail)

      if abr_detail[:result] == :success
        body = abr_detail[:payload]
      else
        raise "The ABR returned an exception: #{abr_detail[:payload]}"
      end

      @acn                = body[:asic_number] rescue nil
      @abn                = body[:abn][:identifier_value] rescue nil
      @abn_current        = body[:abn][:is_current_indicator] rescue nil
      @entity_type        = body[:entity_type][:entity_description] rescue nil
      @status             = body[:entity_status][:entity_status_code] rescue nil
      @main_name          = body[:main_name][:organisation_name] rescue nil
      @trading_name       = body[:main_trading_name][:organisation_name] rescue nil
      @legal_name         = "#{body[:legal_name][:given_name]} #{body[:legal_name][:family_name]}" rescue nil
      @legal_name2        = body[:full_name] rescue nil
      @other_trading_name = body[:other_trading_name][:organisation_name] rescue nil
      @active_from_date   = body[:entity_status][:effective_from] rescue nil
      @address_state_code = body[:main_business_physical_address][:state_code] rescue nil
      @address_post_code  = body[:main_business_physical_address][:postcode] rescue nil
      @address_from_date  = body[:main_business_physical_address][:effective_from] rescue nil
      @last_updated       = body[:record_last_updated_date] rescue nil
      @gst_from_date      = body[:goods_and_services_tax][:effective_from] rescue nil
      0
    end

  end
end
