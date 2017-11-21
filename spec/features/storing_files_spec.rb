require 'spec_helper'
require 'uri/query_params'

describe 'Storing Files', type: :feature do
  let(:image)    { File.open('spec/fixtures/image.png', 'r') }
  let(:uploader) { FeatureUploader.new }

  context "common cases" do

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

    it 'returns url even if its not available' do
      uploader.file.delete
      expect(uploader.file.exists?).to be_falsey
      expect(uploader.file.url).to be_present
    end

    it 'is not able to retrieve attributes if file does not exists' do
      uploader.file.delete
      expect(uploader.file.attributes).to be_nil
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

  context "remote uploads" do

    after(:each) do
      expect(uploader.url).to include(ENV['GCLOUD_BUCKET'])
      expect(uploader.url).to include(uploader.path)
      uploader.file.delete
    end

    it "can upload from remote urls" do
      uploader.download!("http://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
      uploader.store!
      uploader.retrieve_from_store!(uploader.send(:original_filename))
    end

    it "file names can be renamed when loading from remote urls" do
      uploader.class_eval do
        def filename
          "filename.png"
        end
      end
      uploader.download!("http://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
      uploader.store!
      uploader.retrieve_from_store!(uploader.filename)
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
