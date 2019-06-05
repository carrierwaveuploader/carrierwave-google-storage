require 'spec_helper'

describe CarrierWave::Storage::GcloudFile do
  let(:path)       { 'files/1/file.txt' }
  let(:file)       { double(:file, content_type: 'content/type', path: '/file/path') }
  let(:bucket)     { double(:bucket, object: file) }
  let(:connection) { double(:connection, bucket: bucket) }

  let(:uploader)   { FeatureUploader.new }

  subject(:gcloud_file) do
    CarrierWave::Storage::GcloudFile.new(uploader, connection, path)
  end

  describe '#to_file' do
    it 'returns the internal file instance' do
      file = Object.new
      gcloud_file.file = file

      expect(gcloud_file.to_file).to be(file)
    end
  end

  describe '#extension' do
    it 'extracts the file extension from the path' do
      gcloud_file.path = 'file.txt'

      expect(gcloud_file.extension).to eq('txt')
    end

    it 'is nil if the file has no extension' do
      gcloud_file.path = 'filetxt'

      expect(gcloud_file.extension).to be_nil
    end
  end

  describe '#bucket' do
    it 'returns the internal bucket instance' do
      expect(gcloud_file.send :bucket).to be(bucket)
    end
  end

end
