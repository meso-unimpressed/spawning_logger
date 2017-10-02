$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.after do
    SpawningLogger.send(:remove_const, :Backends)
    SpawningLogger.send(:remove_const, :ArgumentError)
    Object.send(:remove_const, :SpawningLogger)
    $".reject! { |file| file =~ %r{/spawning_logger/lib/} }
    require 'spawning_logger'
  end
end
