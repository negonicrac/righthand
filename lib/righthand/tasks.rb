desc "generate and deploy website via rsync"
task :deploy do
  system "middleman build -c --verbose"

  puts ">>> DEPLOYING SITE <<<"

  configs = YAML::load_file(".fog.yml")

  src    = File.expand_path("build")
  bucket = configs.delete(:bucket) || configs.delete(:bucket_name)
  path   = nil

  puts "Connecting"
  connection = ::Fog::Storage.new(configs)

  # Get bucket
  puts "Getting bucket"
  begin
    directory = connection.directories.get(bucket)
  rescue ::Excon::Errors::NotFound
    should_create_bucket = true
  end
  should_create_bucket = true if directory.nil?

  # Create bucket if necessary
  if should_create_bucket
    directory = connection.directories.create(key: bucket)
  end

  # Get list of remote files
  files = directory.files
  truncated = files.respond_to?(:is_truncated) && files.is_truncated
  while truncated
    set = directory.files.all(marker: files.last.key)
    truncated = set.is_truncated
    files = files + set
  end

  # Delete all the files in the bucket
  puts "Removing remote files"
  files.all.each do |file|
    file.destroy
  end

  # Upload all the files in the output folder to the clouds
  puts "Uploading local files"
  FileUtils.cd(src) do
    files = Dir["**/*"].select { |f| File.file?(f) }
    files.each do |file_path|
      puts "uploading: #{file_path}"
      cache_time = 28800
      cache_control = "max-age=28800, public"

      if file_path.match(".(flv|ico|pdf|avi|mov|ppt|doc|mp3|wmv|wav)$")
        cache_time = 29030400
        cache_control = "max-age=29030400, public"
      elsif file_path.match(".(jpg|jpeg|png|gif|swf)$")
        cache_time = 6048000
        cache_control = "max-age=6048000, public"
      elsif file_path.match(".(txt|xml|js|css)$")
        cache_time = 28800
        cache_control = "max-age=28800, public"
      elsif file_path.match(".(html|htm.gz)$")
        cache_time = 28800
        cache_control = "max-age=28800, public"
      elsif file_path.match(".(php|cgi|pl)$")
        cache_time = 0
        cache_control = "max-age=0, private, no-store, no-cache, must-revalidate"
      end

      file = { key: "#{path}#{file_path}",
               body: File.open(file_path),
               public: true,
               cache_control: cache_control,
               expires: CGI.rfc1123_date(Time.now + cache_time) }

      if file_path.match(".gz$")
        file.merge!(:content_encoding => "gzip")
      elsif file_path.match(".appcache$")
        file.merge!(:content_type => "text/cache-manifest")
      end

      directory.files.create(file)
    end
  end

  puts "Done!"
end

desc "generate favicons"
task :favicons do
  src = Dir.pwd
  puts src

  options = {
    versions: [:apple_114, :apple_57, :apple, :fav_ico],
    custom_versions: {
      apple_extreme_retina: {
        filename: "apple-touch-icon-228x228-precomposed.png",
        dimensions: "228x228",
        format: "png"
      }
    },
    root_dir: Dir.pwd,
    input_dir: "source",
    base_image: "images/logo.png",
    output_dir: "source",
    copy: true
  }

  FaviconMaker::Generator.create_versions(options) do |filepath|
    puts "Created favicon: #{filepath}"
  end
end
