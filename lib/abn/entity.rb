module Abn

  class Entity
    attr_accessor :acn, :abn, :name, :entity_type, :status, :main_name, :trading_name, :legal_name, :legal_name2, :other_trading_name, :active_from_date, :address_state_code, :address_post_code, :address_from_date, :last_updated, :gst_from_date

    @acn                = nil
    @abn                = nil
    @name               = nil
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

    # Choose the most relevant business name
    #
    # @return [String] business name
    def best_name
      @trading_name || @other_trading_name || @main_name || @legal_name || @legal_name2 || 'Name unknown'
    end

    # Return the values in a hash. Stolen from ActiveSupport
    #
    # @return [Hash] object attributes
    def instance_values
      Hash[instance_variables.map { |name| [name[1..-1].to_sym, instance_variable_get(name)] }]
    end
  end

end