require 'sitemap_generator'
require 'google/cloud/storage'


# Your website's host name
SitemapGenerator::Sitemap.default_host = "http://www.algorini.com"

# The remote host where your sitemaps will be hosted
SitemapGenerator::Sitemap.sitemaps_host = "https://console.cloud.google.com/storage/browser/test_bucket_one"

# The directory to write sitemaps to locally
SitemapGenerator::Sitemap.public_path = 'tmp/'

# Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'


SitemapGenerator::Sitemap.adapter = SitemapGenerator::GoogleStorageAdapter.new(
  credentials: './keys/google_cloud_storage_bhargav_r_raut@gmail.com_service_account_dark-edge-264914-3c2e40ad386e.json',
  project_id: ENV["GOOGLE_CLOUD_PROJECT"],
  bucket: ENV["GOOGLE_CLOUD_SITEMAP_BUCKET"]
)



## so now we can have this as a rake task, but i prefer a background job
## so we can have this inside a seperate sitemap class
## to be triggered as a background job.

=begin
storage = Google::Cloud::Storage.new(
  project_id: ENV["GOOGLE_CLOUD_PROJECT"],
  credentials: "./keys/google_cloud_storage_bhargav_r_raut@gmail.com_service_account_dark-edge-264914-3c2e40ad386e.json"
)

bucket = storage.create_bucket "test_bucket_one"
=end