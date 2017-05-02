# frozen_string_literal: true

require "simplecov"

if ENV["CI"]
  unless ENV["RUN_SPEC_LOCALLY"]
    require "coveralls"
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  end
end

SimpleCov.start do
  add_filter "/spec/"

  add_group "Core", "lib"
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end

require "abn_search"
