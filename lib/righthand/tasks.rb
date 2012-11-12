desc "generate and deploy website via rsync"
task :deploy do
  system "middleman build -c --verbose"

  puts ">>> DEPLOYING SITE <<<"

  configs   = YAML::load_file(".fog.yml")

  src       = File.expand_path("build")
  s3_bucket = configs.delete(:bucket) || configs.delete(:bucket_name)

  # Upload all the files in the output folder to the clouds
  puts "Uploading local files"
  FileUtils.cd(src) do
    published_files = FileList['**/*'].inject({}) do |hsh, path|
      hsh ||= {}

      # puts "path: #{path}"
      # puts "dir: #{File.directory? path}"

      if File.directory? path
        hsh.update("#{path}/" => :directory)
      else
        hsh.update(path => OpenSSL::Digest::MD5.hexdigest(File.read(path)))
      end

      # puts "hash: #{hsh}"
      # puts "============================="

      hsh
    end
    raise "#{src} is empty: aborting" if published_files.size <= 1

    puts "Connecting"
    connection = ::Fog::Storage.new(configs)

    # Get bucket
    puts "Getting bucket"
    begin
      bucket = connection.directories.get(s3_bucket)
    rescue ::Excon::Errors::NotFound
      should_create_bucket = true
    end
    should_create_bucket = true if bucket.nil?
    puts "Got bucket"

    # Create bucket if necessary
    if should_create_bucket
      bucket = connection.directories.create(key: s3_bucket)
    end

    published_files.each do |file, etag|
      case etag
      when :directory
        puts "Creating directory #{file}"
        bucket.files.create(:key => file, :public => true)
      else
        if f = bucket.files.head(file)
          # if f.etag == etag
          #   puts "Skipping #{file} (identical)"
          # else
            puts "Updating #{file}"
            bucket.files.create(configure_file_opts(file))
          # end
        else
          puts "Uploading #{file}"
          bucket.files.create(configure_file_opts(file))
        end
      end
    end

    ## Clean up removed files
    bucket.files.each do |object|
      unless published_files.has_key? object.key
        puts "Removing #{object.key} (no longer exists)"
        object.destroy
      end
    end
  end

  puts "Done!"
end

def configure_file_opts(file)
  cache_time = 28800
  cache_control = "max-age=28800, public"

  if file.match(".(flv|ico|pdf|avi|mov|ppt|doc|mp3|wmv|wav)$")
    cache_time = 29030400
    cache_control = "max-age=29030400, public"
  elsif file.match(".(jpg|jpeg|png|gif|swf)$")
    cache_time = 6048000
    cache_control = "max-age=6048000, public"
  elsif file.match(".(txt|xml|js|css)$")
    cache_time = 28800
    cache_control = "max-age=28800, public"
  elsif file.match(".(html|htm.gz)$")
    cache_time = 28800
    cache_control = "max-age=28800, public"
  elsif file.match(".(php|cgi|pl)$")
    cache_time = 0
    cache_control = "max-age=0, private, no-store, no-cache, must-revalidate"
  end

  file_opts = {
    key: file,
    body: File.open(file),
    public: true,
    cache_control: cache_control,
    expires: CGI.rfc1123_date(Time.now + cache_time)
  }

  if file.match(".gz$")
    file_opts.merge!(:content_encoding => "gzip")
  elsif file.match(".appcache$")
    file_opts.merge!(:content_type => "text/cache-manifest")
  end

  file_opts
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
