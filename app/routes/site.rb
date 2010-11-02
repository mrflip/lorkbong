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
      %x{ ruby #{::ROOT_DIR}/vendor/elastic-mapreduce/elastic-mapreduce -a $AWS_ACCESS_KEY_ID  -p $AWS_SECRET_ACCESS_KEY --list },
      '</pre>',
    ].join("\n")
  end

  get '/emr/run' do
    [ '<pre>',
      %x{
          ruby #{::ROOT_DIR}/tasks/adjlist_degree.rb --run=emr --jobflow=j-18OUFBXJ0Z01W s3n://s3n.infinitemonkeys.info/data/examples/links-simple-sorted-10k.txt s3n://s3n.infinitemonkeys.info/data/examples/wp-link-degree-3
      },
      '</pre>',
    ].join("\n")
  end
end
