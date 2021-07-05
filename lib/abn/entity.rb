# frozen_string_literal: true

module Abn

  class Entity

    ATTRIBUTES = %i[
      abn
      acn
      active_from_date
      address_from_date
      address_post_code
      address_state_code
      entity_type
      gst_from_date
      last_updated
      legal_name
      legal_name2
      main_name
      name
      other_trading_name
      status
      trading_name
      business_name
    ].freeze

    attr_accessor(*ATTRIBUTES)

    def initialize(attributes = {})
      return if attributes.empty?

      attributes.each do |k, v|
        unless ATTRIBUTES.include?(k.to_sym)
          raise(ArgumentError, "Invalid attribute name: #{k}")
        end

        instance_variable_set("@#{k}", v)
      end
    end

    # Choose the most relevant business name
    #
    # @return [String] business name
    def best_name
      trading_name ||
        other_trading_name ||
        main_name ||
        legal_name ||
        legal_name2 ||
        "Name unknown"
    end

    # Convert self into a hash
    #
    # @return [Hash] object attributes as a hash
    def to_h
      ATTRIBUTES.each_with_object({}) do |name, result|
        result[name] = send(name)
      end
    end

    # Alias for Rails users
    alias as_json to_h

    # Alias for Backwards compatibility
    alias instance_values to_h

  end

end
