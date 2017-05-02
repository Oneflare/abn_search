# frozen_string_literal: true

require "abn_search"

if ENV["CI"]
  require "simplecov"

  unless ENV["RUN_SPEC_LOCALLY"]
    require "coveralls"
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  end

  SimpleCov.start do
    add_group "Core", "lib"
  end
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
