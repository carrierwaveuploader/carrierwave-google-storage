require 'spec_helper'

describe 'Caching Files', type: :feature do
  let(:image)    { File.open('spec/fixtures/image1.png', 'r') }
  let(:uploader) { FeatureUploader.new }

  context 'common cases' do
    before(:each) do
      sleep 1 # Prevent Google::Cloud::ResourceExhaustedError: rateLimitExceeded
      uploader.cache!(image)
      uploader.retrieve_from_cache!(uploader.cache_name)
    end

    it 'uploads the file to the configured bucket' do
      expect(uploader.file.size).to eq(image.size)
      expect(uploader.file.read).to eq(image.read)
      image.close
      uploader.file.delete
    end

    it 'returns url even if its not available' do
      uploader.file.delete
      expect(uploader.file.exists?).to be_falsey
      expect(uploader.file.url).to be_present
    end

    it 'is not able to retrieve attributes if file does not exists' do
      uploader.file.delete
      expect(uploader.file.attributes).to be_nil
    end

    it 'retrieves content-type for a cached file' do
      expect(uploader.file.attributes).to include(
        :content_type,
        :etag,
        :updated_at
      )

      expect(uploader.file.content_type).to eq('image/png')

      image.close
      uploader.file.delete
    end

    it 'retrieves the filename for a cached file' do
      expect(uploader.file.attributes).to include(
        :content_type,
        :etag,
        :updated_at
      )

      expect(uploader.file.filename).to eq('image1.png')

      image.close
      uploader.file.delete
    end

    it 'checks if a remote file exists' do
      expect(uploader.file.exists?).to be_truthy

      uploader.file.delete
      expect(uploader.file.exists?).to be_falsy

      image.close
    end

    it 'gets a url for remote files' do
      expect(uploader.url).to include(ENV['GCLOUD_BUCKET'])
      expect(uploader.url).to include(uploader.path)

      image.close
      uploader.file.delete
    end
  end
end
