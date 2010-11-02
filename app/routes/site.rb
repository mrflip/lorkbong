class Main
  get "/" do
    @dump = request.path_info
    haml :root
  end

  get '/gist' do
    require 'gist'
    Gist.write(["Hello from #{request.path_info} on", `hostname`.chomp, 'at', Time.now].join("\t"))
  end

  get '/emr/list' do
    [ '<pre>',
      %x{ #{::ROOT_DIR}/vendor/elastic-mapreduce/elastic-mapreduce -a $AWS_ACCESS_KEY_ID  -p $AWS_SECRET_ACCESS_KEY --list },
      ENV['AWS_ACCESS_KEY_ID'],
      '</pre>',
    ]
  end
end
