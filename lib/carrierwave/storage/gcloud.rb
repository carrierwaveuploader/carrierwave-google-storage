module CarrierWave
  module Storage
    class Gcloud < Abstract
    
      def self.connection_cache
        @connection_cache ||= {}
      end

      def self.clear_connection_cache!
        @connection_cache = {}
      end
      
      def store!(file)
        CarrierWave::Storage::GcloudFile.new(uploader, connection, uploader.store_path).tap do |gcloud_file|
          gcloud_file.store(file)
        end
      end

      def retrieve!(identifier)
        CarrierWave::Storage::GcloudFile.new(uploader, connection, uploader.store_path(identifier)).retrieve
      end

      def connection
        @connection ||= begin
          cert_path = Gem.loaded_specs['google-api-client'].full_gem_path+'/lib/cacerts.pem'
          ENV['SSL_CERT_FILE'] = cert_path
          self.class.connection_cache[credentials] ||= ::Gcloud.new(credentials[:gcloud_project] || ENV["GCLOUD_PROJECT"], credentials[:gcloud_keyfile] || ENV["GCLOUD_KEYFILE"]).storage
        end
      end

      def credentials
        uploader.gcloud_credentials
      end
    end
  end
end