module CarrierWave
  module Support
    module UriFilename
      def self.filename(url)
        path = url.split('?').first

        URI.decode_www_form_component(path).gsub(/.*\/(.*?$)/, '\1')
      end
    end
  end
end
