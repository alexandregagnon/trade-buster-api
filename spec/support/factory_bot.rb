RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  FactoryBot::SyntaxRunner.class_eval do
    include RSpec::Mocks::ExampleMethods
  end
end
