class EmrScript
  #
  # You need to edit the following things:
  #
  EMR_OPTS = {
    # # Path to the runner.
    :emr_runner    => "#{::ROOT_DIR}/vendor/elastic-mapreduce/elastic-mapreduce",
    # # Temp storage for the keypair file (elastic-mapreduce script demands it be a static file).
    :keypair_file  => ::ROOT_DIR+'/tmp/emr_keypair.pem',
    # # If you're debugging:
    # # first run with alive set to true, and launch the job.
    :alive => nil,
    # # After the job has been created and run for the first time, fill your
    # # jobflow into the following and set alive back to nil.
    # :jobflow       => "j-18OUFBXJ0Z01W",
  }
  # Path to the input files. Note the 's3n' prefix.
  EMR_INPUT  = "s3n://s3n.infinitemonkeys.info/data/examples/links-simple-sorted-10k.txt"
  # Path to the output files. This directory must not exist. Note the 's3n' prefix.
  EMR_OUTPUT = "s3n://s3n.infinitemonkeys.info/data/examples/wp-link-degree-4"

  def self.list_steps_command
    %Q{ ruby #{EMR_OPTS[:emr_runner]} -a "$AWS_ACCESS_KEY_ID" -p "$AWS_SECRET_ACCESS_KEY" --list  2>&1 }
  end

  def self.run_step_command
    %Q{ ruby #{::ROOT_DIR}/tasks/adjlist_degree.rb --dry_run --run=emr #{emr_opts} #{EMR_INPUT} #{EMR_OUTPUT} 2>&1  }
  end

private
  # Ditch the emr keypair into a file in the tmp dir. Since the contents never
  # change this is safe to do even in the virtual environment.
  def self.munge_emr_keypair_file
    File.open(EMR_OPTS[:keypair_file], 'w'){|f| f << ENV['EMR_KEYPAIR'] }
  end

  def self.emr_opts
    EMR_OPTS.map{|opt,val| "--#{opt}=#{val}" }.join(" ")
  end

end
