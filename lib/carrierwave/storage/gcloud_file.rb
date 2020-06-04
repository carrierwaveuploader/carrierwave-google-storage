# frozen_string_literal: true

module CarrierWave
  module Storage
    class GcloudFile
      GCLOUD_STORAGE_URL = 'https://storage.googleapis.com'

      attr_writer :file
      attr_accessor :uploader, :connection, :path, :gcloud_options, :file_exists

      delegate :content_disposition, :content_type, :size, to: :file, allow_nil: true

      def initialize(uploader, connection, path)
        @uploader   = uploader
        @connection = connection
        @path       = path
      end

      def file
        @file ||= bucket.file(path)
      end
      alias to_file file

      def attributes
        return unless exists?
        {
          content_type: file.content_type,
          size: file.size,
          updated_at: file.updated_at.to_s,
          etag: file.etag
        }
      end

      def delete
        deleted = file ? file.delete : true
        @file = nil if deleted
        deleted
      end

      def exists?
        !file.nil?
      end

      def extension
        elements = path.split('.')
        elements.last if elements.size > 1
      end

      def filename(options = {})
        CarrierWave::Support::UriFilename.filename(file.url)
      end

      def read
        tmp_file = Tempfile.new(
          CarrierWave::Support::UriFilename.filename(file.name)
        )
        (file.download tmp_file.path, verify: :all).read
      end

      def store(new_file)
        new_file_path = uploader.filename ? uploader.filename : new_file.filename
        bucket_file = bucket.create_file(
          new_file.path,
          path,
          content_type: new_file.content_type,
          content_disposition: uploader.gcloud_content_disposition
        )
        bucket_file.acl.public! if uploader.gcloud_bucket_is_public
        self
      end

      def copy_to(new_path)
        file.copy("#{uploader.store_dir}/#{new_path}")
      end

      def url(options = {})
        uploader.gcloud_bucket_is_public ? public_url : authenticated_url(options)
      end

      def authenticated_url(options = {})
        bucket.signed_url(path, options)
      end

      def public_url
        if uploader.asset_host
          "#{uploader.asset_host}/#{path}"
        else
          "#{GCLOUD_STORAGE_URL}/#{uploader.gcloud_bucket}/#{@path}"
        end
      end

      private

      def bucket
        @bucket ||= connection.bucket(uploader.gcloud_bucket, skip_lookup: true)
      end
    end
  end
end
