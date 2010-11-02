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
    block_of_code(
      %x{ ruby #{::ROOT_DIR}/vendor/elastic-mapreduce/elastic-mapreduce -a $AWS_ACCESS_KEY_ID  -p $AWS_SECRET_ACCESS_KEY --list }
      )
  end

  get '/emr/run' do
    input  = "s3n://s3n.infinitemonkeys.info/data/examples/links-simple-sorted-10k.txt"
    output = "s3n://s3n.infinitemonkeys.info/data/examples/wp-link-degree-4"
    block_of_code(
      %x{
          ruby #{::ROOT_DIR}/tasks/adjlist_degree.rb --run=emr #{emr_opts} #{input} #{output}
      }
      )
  end

  private

  def block_of_code *args
    [ '<pre>',
      args,
      '</pre>',
    ].flatten.join("\n")
  end

  # Temp storage for the keypair file (elastic-mapreduce script demands it be a
  # static file).
  def emr_keypair_file
    ::ROOT_DIR+'/tmp/emr_keypair.pem'
  end

  # Ditch the emr keypair into a file in the tmp dir. Since the contents never
  # change this is safe to do even in the virtual environment.
  def munge_emr_keypair_file
    File.open(emr_keypair_file,'w'){|f| f << ENV['EMR_KEYPAIR'] }
  end

  def emr_opts
    {
      :emr_runner    => "#{::ROOT_DIR}/vendor/elastic-mapreduce/elastic-mapreduce",
      :jobflow       => "j-18OUFBXJ0Z01W",
      :key_pair_file => emr_keypair_file,
    }.map{|opt,val| "--#{opt}=#{val}" }.join(" ")
  end
end
