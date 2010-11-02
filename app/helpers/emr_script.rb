class EmrScript
  EMR_OPTS = {
    :emr_runner    => "#{::ROOT_DIR}/vendor/elastic-mapreduce/elastic-mapreduce",
    :jobflow       => "j-18OUFBXJ0Z01W",
    :key_pair_file => emr_keypair_file,
  }
  EMR_INPUT  = "s3n://s3n.infinitemonkeys.info/data/examples/links-simple-sorted-10k.txt"
  EMR_OUTPUT = "s3n://s3n.infinitemonkeys.info/data/examples/wp-link-degree-4"

  def self.list_steps_command
    %Q{ ruby #{EMR_OPTS[:emr_runner]} -a "$AWS_ACCESS_KEY_ID" -p "$AWS_SECRET_ACCESS_KEY" --list  2>&1 }
  end

  def self.run_step_command
    %Q{ ruby #{::ROOT_DIR}/tasks/adjlist_degree.rb --run=emr #{emr_opts} #{EMR_INPUT} #{EMR_OUTPUT} 2>&1  }
  end

private
  # Temp storage for the keypair file (elastic-mapreduce script demands it be a
  # static file).
  def self.emr_keypair_file
    ::ROOT_DIR+'/tmp/emr_keypair.pem'
  end

  # Ditch the emr keypair into a file in the tmp dir. Since the contents never
  # change this is safe to do even in the virtual environment.
  def self.munge_emr_keypair_file
    File.open(emr_keypair_file,'w'){|f| f << ENV['EMR_KEYPAIR'] }
  end

  def self.emr_opts
    EMR_OPTS.map{|opt,val| "--#{opt}=#{val}" }.join(" ")
  end

end
