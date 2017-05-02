# frozen_string_literal: true

require "abn/client"
require "abn/entity"
require "forwardable"
require "savon"

# Backwards compatibility funtimes.
class ABNSearch

  extend Forwardable

  attr_reader :client

  def initialize(guid = nil, options = {})
    @client = ::Abn::Client.new(guid, options)
  end

  # setup delegation for search methods to the Abn::Client class
  def_delegators :client, :search, :search_by_acn, :search_by_name

end
