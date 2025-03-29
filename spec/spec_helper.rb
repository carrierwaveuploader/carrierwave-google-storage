$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'pry'
require 'carrierwave'
require 'carrierwave-google-storage'
# require 'carrierwave/google/storage'

FeatureUploader = Class.new(CarrierWave::Uploader::Base) do
  # def filename; 'image.png'; end
end

def source_environment_file!
  return unless File.exist?('.env')

  File.readlines('.env').each do |line|
    key, value = line.split('=')
    ENV[key] = value.chomp
  end
end

RSpec.configure do |rs_config|
  source_environment_file!

  rs_config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # config.filter_run :focus
  rs_config.run_all_when_everything_filtered = true
  rs_config.order = :random
  rs_config.default_formatter = 'doc' if rs_config.files_to_run.one?

  Kernel.srand rs_config.seed

  rs_config.before(:all, type: :feature) do
    CarrierWave.configure do |cw_config|
      cw_config.cache_storage                       = :gcloud
      cw_config.storage                             = :gcloud
      cw_config.gcloud_bucket                       = ENV['GCLOUD_BUCKET']
      cw_config.gcloud_bucket_is_public             = true
      cw_config.gcloud_authenticated_url_expiration = 600
      cw_config.store_dir                           = ['uploaded_files', ENV['BUILD_ID'].presence].compact.join('_')
      cw_config.gcloud_attributes =                 { expires: 600 }
    end
  end
end
