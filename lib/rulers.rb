# rulers/lib/rulers.rb

require "rulers/array"
require "rulers/controller"
require "rulers/dependencies"
require "rulers/routing"
require "rulers/util"
require "rulers/version"

module Rulers
  class Application
    def call(env)
      if env['PATH_INFO'] == '/'
        return [302, {'Location' => 'http://localhost:3001/quotes/a_quote'}, []]
      end
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
      begin
        klass, act = get_controller_and_action(env)
        controller = klass.new(env)
        text = controller.send(act)
        return [200, {'Content-Type' => 'text/html'},
         [text]]
      rescue StandardError => err
        return [500, {'Content-Type' => 'text/html'},
         ["Something went wrong on the page" +
         "\n<pre>\n#{err.inspect}\n</pre>"]]
      end
    end
  end


end
