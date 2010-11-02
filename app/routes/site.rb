class Main
  get "/" do
    @dump = request.path_info
    haml :root
  end
end
