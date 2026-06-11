# frozen_string_literal: true

require 'googleauth'
require 'google/apis/iamcredentials_v1'
require 'google-cloud-env'

module CarrierWave
  module Storage
    # Signs GCS URLs via the IAM Credentials API (signBlob) instead of a
    # local service-account private key, so signed URLs work under
    # Workload Identity / Compute metadata credentials.
    module IamSigner
      IAM_SCOPE = ['https://www.googleapis.com/auth/iam'].freeze

      def self.service_account_email
        @service_account_email ||=
          Google::Cloud.env.lookup_metadata('instance', 'service-accounts/default/email')
      end

      def self.iam_client
        @iam_client ||= Google::Apis::IamcredentialsV1::IAMCredentialsService.new.tap do |client|
          client.authorization = Google::Auth.get_application_default(IAM_SCOPE)
        end
      end

      def self.signer
        lambda do |string_to_sign|
          request = Google::Apis::IamcredentialsV1::SignBlobRequest.new(payload: string_to_sign)
          resource = "projects/-/serviceAccounts/#{service_account_email}"
          iam_client.sign_service_account_blob(resource, request).signed_blob
        end
      end
    end
  end
end
