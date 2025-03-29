require 'spec_helper'

describe CarrierWave::Storage::GcloudFile do
  subject(:gcloud_file) { described_class.new(uploader, connection, path) }

  let(:path) { 'files/1/file.txt' }
  let(:file) { instance_double(Google::Cloud::Storage::File, content_type: 'content/type', name: path) }
  let(:bucket) { instance_double(Google::Cloud::Storage::Bucket, file: file) }
  let(:connection) { instance_double(Google::Cloud::Storage::Project, bucket: bucket) }
  let(:uploader) { FeatureUploader.new }

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
      expect(gcloud_file.send(:bucket)).to be(bucket)
    end
  end

  describe '#url' do
    let(:options) { {} }

    context 'when gcloud_bucket_is_public is false' do
      before { allow(uploader).to receive(:gcloud_bucket_is_public).and_return(false) }

      it 'calls authenticated_url method' do
        gcloud_file.url(options)

        expect(gcloud_file).to have_received(:authenticated_url).with(options) # rubocop:disable RSpec/SubjectStub
      end
    end

    context 'when gcloud_bucket_is_public is true' do
      before { allow(uploader).to receive(:gcloud_bucket_is_public).and_return(true) }

      it 'calls public_url method' do
        gcloud_file.url

        expect(gcloud_file).to have_received(:public_url) # rubocop:disable RSpec/SubjectStub
      end
    end
  end

  describe '#authenticated_url' do
    before { allow(uploader).to receive(:gcloud_authenticated_url_expiration).and_return(60) }

    it 'calls #signed_url with the expires option' do
      gcloud_file.authenticated_url

      expect(bucket).to have_received(:signed_url).with(path, expires: 60)
    end
  end
end
