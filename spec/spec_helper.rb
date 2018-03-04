require 'bundler/setup'
require 'scaffold_parser'
require 'saharspec'

module Helpers
  def parser_for(schema_path, parser_name)
    Hash[ScaffoldParser.scaffold_to_string(schema_path)][parser_name].strip
  end

  def builder_for(schema_path, builder_name)
    Hash[ScaffoldParser.scaffold_to_string(schema_path)][builder_name].strip
  end
end

RSpec.configure do |config|
  config.include Helpers
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
