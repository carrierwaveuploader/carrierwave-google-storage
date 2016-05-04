require 'spec_helper'

describe 'Copying Files', type: :feature do
  let(:image)    { File.open('spec/fixtures/image.png', 'r') }
  let(:original) { FeatureUploader.new }

  it 'copies an existing file to the specified path' do
    original.store!(image)
    original.retrieve_from_store!('image.png')
    original.file.copy_to('image2.png')

    copy = FeatureUploader.new
    copy.retrieve_from_store!('image2.png')

    original_attributes = original.file.attributes
    original_attributes.reject! { |k,v| [:updated_at, :etag].include?(k) }

    copy_attributes = copy.file.attributes
    copy_attributes.reject! { |k,v| [:updated_at, :etag].include?(k) }

    expect(copy_attributes).to eq(original_attributes)

    image.close
    expect(original.file.delete).to eq(true)
    expect(copy.file.delete).to eq(true)
  end
  
end