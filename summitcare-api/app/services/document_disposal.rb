class DocumentDisposal
  BUCKETS = { "summitcare-phi-documents" => "us-east-1", "summitcare-phi-documents-dr" => "us-west-2" }.freeze

  def self.call(document)
    key = document.file.blob.key
    document.file.purge # removes the blob and attachment rows
    BUCKETS.each { |bucket, region| delete_all_versions(Aws::S3::Client.new(region:), bucket, key) }
  end

  def self.delete_all_versions(s3, bucket, key)
    listing = s3.list_object_versions(bucket:, prefix: key)
    objects = (listing.versions + listing.delete_markers)
              .select { |v| v.key == key }.map { |v| { key: v.key, version_id: v.version_id } }
    s3.delete_objects(bucket:, delete: { objects:, quiet: true }) if objects.any?
  end
end
