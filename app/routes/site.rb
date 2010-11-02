
#
# ===========================================================================
#

class Main
  get "/" do
    haml :root
  end

  # ---------------------------------------------------------------------------
  #
  # EMR
  #

  get '/emr/list' do
    block_of_code(%x{ #{EmrScript.list_steps_command} })
  end

  get '/emr/run' do
    block_of_code(%x{ #{EmrScript.run_step_command} })
  end

  # ---------------------------------------------------------------------------

  # a little testing route: posts a gist with the current timestamp when you
  # load the page.
  get '/gist' do
    require 'gist'
    Gist.write(["Hello from #{request.path_info} on", `hostname`.chomp, 'at', Time.now].join("\t"))
  end

  private

  # Surrounds the given text strings in pre blocks, separated with newlines
  def block_of_code *args
    [ '<pre>',
      args,
      '</pre>',
    ].flatten.join("\n").gsub(/(access-id|private-key[ =])(\S+)/, '\1XXXXX' )
  end
end
