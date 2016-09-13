# Carrierwave Google Storage

[![Build Status](https://travis-ci.org/metaware/carrierwave-google-storage.svg?branch=master)](https://travis-ci.org/metaware/carrierwave-google-storage)
[![Code Climate](https://codeclimate.com/github/metaware/carrierwave-google-storage/badges/gpa.svg)](https://codeclimate.com/github/metaware/carrierwave-google-storage)
[![Gem Version](https://badge.fury.io/rb/carrierwave-google-storage.svg)](https://badge.fury.io/rb/carrierwave-google-storage)

Use the official `google-cloud` gem by Google for Google Cloud Storage, instead of Fog. 

- No need to activate Interoperable Access on your project.
- Rely on Google's preferred authentication mechanism. ie: Service Accounts.
 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carrierwave-google-storage'
```

## Usage

```
CarrierWave.configure do |config|
  config.storage                             = :gcloud
  config.gcloud_bucket                       = 'your-bucket-name'
  config.gcloud_bucket_is_public             = true
  config.gcloud_authenticated_url_expiration = 600
  
  config.gcloud_attributes = {
    expires: 600
  }
  
  config.gcloud_credentials = {
    gcloud_project: 'gcp-project-name',
    gcloud_keyfile: 'path-to-gcp-keyfile.json'
  }
end
```

## How to get the Keyfile?

To generate a new keyfile, perform the following steps: 

- Go to [Cloud Console > API Manager > Credentials](https://console.cloud.google.com/apis/credentials)
- Click Create Credentials > Service Account Key
- Service Account > New Service Account 
- Give any name for "Service Account Name"
- Set Key type to JSON
- Click "Create"

Here's a quick GIF for those who are visual like myself:

![](http://g.recordit.co/VjsK6CAUha.gif)

## Contributing

### Environment Variables and such

You should have access to a Google Cloud Platform account, as you'll need the keyfile and a project ID in order to contribute to the development of this gem. You'll need the the following files:

- `.gcp-keyfile.json` (sample file provided: `.gcp-keyfile.sample.json`)
- `.env` (sample file provided: `.env.sample`)

If you have any questions, please feel free to open up issues and/or PR's. Contributions are welcomed.

In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality.

You get extra attention, if your PR includes specs/tests.

- Fork or clone the project.
- Create your feature branch ($ git checkout -b my-new-feature)
- Install the dependencies by doing: $ bundle install in the project directory.
- Add your bug fixes or new feature code.
- New features should include new specs/tests.
- Bug fixes should ideally include exposing specs/tests.
- Commit your changes ($ git commit -am 'Add some feature')
- Push to the branch ($ git push origin my-new-feature)
- Open your Pull Request! 

## License

Copyright (c) 2016 [Jasdeep Singh](http://jasdeep.ca) ([Metaware Labs Inc](http://metawarelabs.com/))

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).