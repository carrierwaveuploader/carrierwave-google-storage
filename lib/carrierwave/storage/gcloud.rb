# frozen_string_literal: true

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
        GcloudFile.new(uploader, connection, uploader.store_path).tap do |gcloud_file|
          gcloud_file.store(file)
        end
      end

      def retrieve!(identifier)
        GcloudFile.new(uploader, connection, uploader.store_path(identifier))
      end

      def cache!(file)
        GcloudFile.new(uploader, connection, uploader.cache_path).tap do |gcloud_file|
          gcloud_file.store(file)
        end
      end

      def retrieve_from_cache!(identifier)
        GcloudFile.new(uploader, connection, uploader.cache_path(identifier))
      end

      def clean_cache!(_seconds)
        raise 'use Object Lifecycle Management to clean the cache'
      end

      def connection
        @connection ||= begin
          conn_cache = self.class.connection_cache
          ENV['SSL_CERT_FILE'] = cert_path
          conn_cache[credentials] ||= ::Google::Cloud.new(
            credentials[:gcloud_project] || ENV['GCLOUD_PROJECT'],
            credentials[:gcloud_keyfile] || ENV['GCLOUD_KEYFILE']
          ).storage.bucket(uploader.gcloud_bucket)
        end
      end

      def credentials
        uploader.gcloud_credentials || {}
      end

      private

      def cert_path
        @cert_path ||= begin
          gem_path = Gem.loaded_specs['google-api-client'].full_gem_path
          gem_path + '/lib/cacerts.pem'
        end
      end
    end
  end
end
