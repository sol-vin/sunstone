require "http/server"

module Sunstone
  class RedirectRootHandler
    include HTTP::Handler

    def call(context)
      if context.request.path == "/"
        context.response.status = HTTP::Status::FOUND
        context.response.headers["Location"] = "/index.html"
      else
        call_next(context)
      end
    end
  end

  class Server
    def self.run(directory : String, port : Int32 = 8000, open_browser : Bool = true)
      file_handler = HTTP::StaticFileHandler.new(directory, fallthrough: false, directory_listing: false)
      redirect_handler = RedirectRootHandler.new

      bound = false
      (port..(port + 20)).each do |candidate_port|
        server = HTTP::Server.new([redirect_handler, file_handler])
        begin
          server.bind_tcp("127.0.0.1", candidate_port)
          url = "http://localhost:#{candidate_port}/index.html"

          puts "================================================================"
          puts "  ☀️  Sunstone Presentation Server Running"
          puts "  --> #{url}"
          puts "  Serving directory: #{File.expand_path(directory)}"
          puts ""
          puts "  Keyboard Shortcuts:"
          puts "    • Next / Prev Slide: Space, Right / Left Arrow"
          puts "    • Speaker View:      S (opens synchronized dual-screen notes)"
          puts "    • Slide Overview:    ESC or O"
          puts "    • Fullscreen Mode:   F"
          puts "================================================================"
          puts "Press Ctrl+C to terminate the preview server."

          if open_browser
            spawn do
              sleep 0.4.seconds
              {% if flag?(:windows) %}
                Process.run("cmd", ["/c", "start", url])
              {% elsif flag?(:darwin) %}
                Process.run("open", [url])
              {% else %}
                Process.run("xdg-open", [url])
              {% end %}
            rescue
              # Ignore browser launch failure in headless environments
            end
          end

          bound = true
          server.listen
          break
        rescue Socket::BindError
          next
        end
      end

      raise "Could not bind to any port between #{port} and #{port + 20}" unless bound
    end
  end
end
