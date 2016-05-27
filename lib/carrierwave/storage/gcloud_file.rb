module CarrierWave
  module Storage
    class GcloudFile
    
      attr_writer :file
      attr_accessor :uploader, :connection, :path, 
        :gcloud_options, :file_exists

      delegate :content_type, :size, to: :file

      def initialize(uploader, connection, path)
        @uploader, @connection, @path = uploader, connection, path
      end

      def file
        by_verifying_existence { @file ||= bucket.file(path) }
        @file
      end
      alias_method :to_file, :file
      
      def retrieve
        by_verifying_existence { @file ||= bucket.file(path) }
        self
      end
      
      def by_verifying_existence(&block)
        begin
          self.file_exists = true
          yield
        rescue Exception => exception
          self.file_exists = false if (exception.class == ::Gcloud::Storage::ApiError) && (exception.message == "Not Found")
        end
      end

      def attributes
        return unless file_exists
        {
          content_type: file.content_type,
          size: file.size,
          updated_at: file.updated_at.to_s,
          etag: file.etag
        }
      end
      
      def delete
        deleted = file.delete
        self.file_exists = false if deleted
        deleted
      end
      
      def exists?
        self.file_exists
      end

      def extension
        elements = path.split('.')
        elements.last if elements.size > 1
      end

      def filename(options = {})
        CarrierWave::Support::UriFilename.filename(file.url)
      end

      def read
        tmp_file = Tempfile.new(CarrierWave::Support::UriFilename.filename(file.name))
        (file.download tmp_file.path, verify: :all).read
      end

      def store(new_file)
        new_file_path = uploader.filename ?  uploader.filename : new_file.filename
        bucket.create_file new_file.path, "#{uploader.store_dir}/#{new_file_path}" 
        self
      end

      def copy_to(new_path)
        file.copy("#{uploader.store_dir}/#{new_path}")
      end

      def url(options = {})
        return unless file_exists
        uploader.gcloud_bucket_is_public ? public_url : authenticated_url
      end
      
      def authenticated_url(options = {})
        file.signed_url
      end

      def public_url
        if uploader.asset_host
          "#{uploader.asset_host}/#{path}"
        else
          file.public_url.to_s
        end
      end

      private

      def bucket
        bucket ||= connection.bucket(uploader.gcloud_bucket)
      end

    end
  end
end