require 'spec_helper'

describe CarrierWave::Uploader::Base do
  let(:uploader) { Class.new(described_class) }
  let(:derived_uploader) { Class.new(uploader) }

  it 'inserts :gcloud as a known storage engine' do
    uploader.configure do |config|
      expect(config.storage_engines).to have_key(:gcloud)
    end
  end

  it 'defines gcloud specific storage options' do
    expect(uploader).to respond_to(:gcloud_attributes)
  end

  it 'defines gcloud_credentials option on uploader' do
    expect(uploader).to respond_to(:gcloud_credentials)
  end

  it 'defines gcloud_authenticated_url_expiration option on uploader' do
    expect(uploader).to respond_to(:gcloud_authenticated_url_expiration)
  end
end
