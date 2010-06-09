require 'haml'

Main.class_eval do
  helpers do
    # Render a haml view
    def haml(template, options = {}, locals = {})
      options[:escape_html] = true unless options.include?(:escape_html)
      super(template, options, locals)
    end

    # Render a haml partial
    def partial(template, locals = {})
      haml(template, {:layout => false}, locals)
    end
  end
end
