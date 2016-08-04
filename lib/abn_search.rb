require "savon"
require "abn/client"
require "abn/entity"

# Backwards compatibility funtimes.
class ABNSearch
  @fowarder = nil

  def initialize(guid=nil, options = {})
    @fowarder = Abn::Client.new(guid, options)
  end

  def search_by_acn(acn)
    @fowarder.search_by_acn(acn)
  end

  def search_by_name(name, states=["NSW"], postcode="ALL")
    @fowarder.search_by_name(name, states, postcode)
  end

  def search(abn)
    @fowarder.search(abn)
  end
end