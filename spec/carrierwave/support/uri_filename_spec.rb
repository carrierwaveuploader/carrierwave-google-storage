require 'spec_helper'

describe CarrierWave::Support::UriFilename do
  UriFilename = CarrierWave::Support::UriFilename

  describe '.filename' do
    it 'extracts a decoded filename from file uri' do
      samples = {
        'uploads/file.txt' => 'file.txt',
        'uploads/files/samples/file%201.txt?foo=bar/baz.txt' => 'file 1.txt',
      }

      samples.each do |uri, name|
        expect(UriFilename.filename(uri)).to eq(name)
      end
    end
  end
end 