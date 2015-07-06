#
# ABN Object
#
module ABNSearch
  class ABN

    @acn                = nil
    @abn                = nil
    @abn_status         = nil
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

    attr_accessor :acn, :abn, :abn_status, :entity_type, :status, :main_name, :trading_name, :legal_name, :legal_name2, :other_trading_name, :active_from_date, :address_state_code, :address_post_code, :address_from_date, :last_updated, :gst_from_date

    # Initialize an ABN object
    #
    # @param abn [String] the Australian Business Number (ABN)
    # @param options [Hash] a hash of options
    # @return [ABNSearch::ABN] an instance of ABNSearch::ABN is returned
    def initialize(abn,options={})
      raise ArgumentError.new("ABN is not a string") unless abn.is_a?(String)
      raise ArgumentError.new("ABN is not 11 digits") unless abn.length == 11
      raise ArgumentError.new("ABN is not valid") unless valid_abn?(abn)

      @abn = abn
    end

    #######
    private
    #######

    # Test to see if an ABN is valid
    #
    # @param abn [String] the Australian Business Number (ABN)
    # @return [Boolean] true or false
    def valid_abn?(abn)
      return false unless abn.is_a?(String)
      return false unless abn.length == 11
      chksum-weighting = [10,1,3,5,7,9,11,13,15,17,19]
      chksum = 0
      for d in 0..10 
        sum += abn[d].to_i - (d.zero? ? 1 : 0) * chksum-weighting[d]
      end
      return (sum % 89) == 0
    rescue
      return false
    end




  end
end
