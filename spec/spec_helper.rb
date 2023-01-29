$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'carrierwave'
require 'carrierwave-google-storage'
# require 'carrierwave/google/storage'

FeatureUploader = Class.new(CarrierWave::Uploader::Base) do
  # def filename; 'image.png'; end
end

def source_environment_file!
  if File.exist?('.env')
    File.readlines('.env').each do |line|
      key, value = line.split('=')
      ENV[key] = value.chomp
    end
  end
end

RSpec.configure do |config|
  source_environment_file!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random
  config.default_formatter = 'doc' if config.files_to_run.one?

  Kernel.srand config.seed

  config.before(:all, type: :feature) do
    CarrierWave.configure do |config|
      config.cache_storage                       = :gcloud
      config.storage                             = :gcloud
      config.gcloud_bucket                       = ENV['GCLOUD_BUCKET']
      config.gcloud_bucket_is_public             = true
      config.gcloud_authenticated_url_expiration = 600
      config.store_dir                           = ['uploaded_files', ENV['BUILD_ID'].presence].compact.join('_')

      config.gcloud_attributes = {
        expires: 600
      }
    end
  end

end
