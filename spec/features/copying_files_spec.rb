require 'spec_helper'

describe 'Copying Files', type: :feature do
  let(:image)     { File.open('spec/fixtures/image1.png', 'r') }
  let(:original)  { FeatureUploader.new }
  let(:copy)      { FeatureUploader.new }
  let(:store_dir) { original.store_dir }

  before do
    original.store!(image)
    original.retrieve_from_store!('image1.png')
  end

  after do
    image.close
    original.file.delete
    copy.file.delete
  end

  it 'copies an existing file to the specified path' do
    original.file.copy_to("#{store_dir}/image3.png")

    copy.retrieve_from_store!('image3.png')

    original_attributes = original.file.attributes
    original_attributes.reject! { |k,v| [:updated_at, :etag].include?(k) }

    copy_attributes = copy.file.attributes
    copy_attributes.reject! { |k,v| [:updated_at, :etag].include?(k) }

    expect(copy_attributes).to eq(original_attributes)
  end

  it 'preserves content type on copy' do
    original.file.copy_to("#{store_dir}/image3.png")

    copy.retrieve_from_store!('image3.png')

    expect(copy.file.content_type).to eq 'image/png'
  end

  context 'with acl set to public' do
    let(:original) { FeatureUploader.new.tap { |uploader| uploader.gcloud_bucket_is_public = true } }

    it 'sets acl of the coped file to publicRead' do
      original.file.copy_to("#{store_dir}/image3.png")
      copy.retrieve_from_store!('image3.png')
      expect(copy.file.file.acl.readers).to eq ['allUsers']
    end
  end
end