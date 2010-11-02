class Main
  get "/" do
    @dump = request.path_info
    haml :root
  end

  get '/gist' do
    require 'gist'
    Gist.write(["Hello from #{request.path_info} on", `hostname`.chomp, 'at', Time.now].join("\t"))
  end
end
