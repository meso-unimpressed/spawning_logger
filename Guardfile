guard :rspec, cmd: 'bundle exec rspec' do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # shared examples
  watch(
    %r{^(#{Regexp.escape(rspec.spec_dir)}/.+)/shared_examples/.+\.rb$}
  ) do |m|
    m[1]
  end

  # Ruby files
  ruby = dsl.ruby
  watch(ruby.lib_files) do |m|
    spec_path = m[1][%r{(?<=lib/).*}]
    rspec.spec.call(spec_path)
  end
end

