class Main
  get "/" do
    @dump = request.path_info
    haml :root
  end

  get '/gist' do
    require 'gist'
    Gist.write(["Hello at", `hostname`, Time.now].join("\t"))
  end
end
