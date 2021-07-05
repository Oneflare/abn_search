# frozen_string_literal: true

require "simplecov"
require "pry"

if ENV["CI"]
  require "coveralls"
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start do
  add_filter "/spec/"
  add_group "Core", "lib"
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end

require "abn_search"
require "./spec/support/shared_examples_for_attribute.rb"
