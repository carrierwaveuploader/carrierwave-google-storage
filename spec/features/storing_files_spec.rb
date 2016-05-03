require 'spec_helper'
require 'uri/query_params'

describe 'Storing Files', type: :feature do
  let(:image)    { File.open('spec/fixtures/image.png', 'r') }
  let(:uploader) { FeatureUploader.new }
  
  context "public storage" do
    before(:each) do
        uploader.store!(image)
        uploader.retrieve_from_store!('image.png')
    end

    it 'uploads the file to the configured bucket' do
        expect(uploader.file.size).to eq(image.size)
        expect(uploader.file.read).to eq(image.read)

        image.close
        uploader.file.delete
    end

    it 'retrieves the attributes for a stored file' do
        expect(uploader.file.attributes).to include(
        :content_type,
        :etag,
        :updated_at
        )

        expect(uploader.file.content_type).to eq('image/png')
        expect(uploader.file.filename).to eq('image.png')

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
  
  context "secured storage" do
    
    before(:each) do
      uploader.gcloud_bucket_is_public = false
      uploader.store!(image)
      uploader.retrieve_from_store!('image.png')
    end
    
    it 'uploads the file to the configured bucket' do
      expect(uploader.file.size).to eq(image.size)
      expect(uploader.file.read).to eq(image.read)

      image.close
      uploader.file.delete
    end

    it 'retrieves the attributes for a stored file' do
      expect(uploader.file.attributes).to include(
      :content_type,
      :etag,
      :updated_at
      )

      expect(uploader.file.content_type).to eq('image/png')
      expect(uploader.file.filename).to eq('image.png')

      image.close
      uploader.file.delete
    end

    it 'checks if a remote file exists' do
      expect(uploader.file.exists?).to be_truthy

      uploader.file.delete
      expect(uploader.file.exists?).to be_falsy

      image.close
    end
    
    it 'gets an authenticated url for remote file' do
      uri = URI(uploader.url)
      
      expect(uri.query_params).to include('Signature')
      expect(uri.query_params).to include('Expires')
      expect(uri.query_params).to include('GoogleAccessId')

      expect(uploader.file.read).to eq(image.read)
      
      image.close
      uploader.file.delete
    end
  
  end
  
end