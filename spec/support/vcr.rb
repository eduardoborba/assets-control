VCR.configure do |config|
  config.cassette_library_dir = "#{Rails.root}/spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
