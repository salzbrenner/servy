
defmodule Servy.Handler do

    @moduledoc """
    Handles HTTP requests.
    """
    
    alias Servy.Conv

    @pages_path Path.expand("../../pages", __DIR__)

    import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
    import Servy.Parser, only: [parse: 1]
    import Servy.FileHandler, only: [handle_file: 2]

    @doc """
    Transforms request into response
    """
    def handle(request) do
        request 
        |> parse
        |> rewrite_path
        |> log
        |> route
        |> track
        # |> emojify
        |> format_response
    end

    def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
        %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
    end

    def route(%Conv{ method: "GET", path: "/bears" } = conv) do
        %{conv | status: 200, resp_body: "Teddy, Smoky, Paddington"}
    end

    def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
        @pages_path
          |> Path.join("form.html")
          |> File.read
          |> handle_file(conv)
    end

    def route(%Conv{ method: "GET", path: "/bears" <> id } = conv) do
        %{conv | status: 200, resp_body: "Bear #{id}"}
    end
        
    # name=Baloo&type=Brown
    def route(%Conv{ method: "POST", path: "/bears" } = conv) do
        %{conv | status: 201, resp_body: "Created a #{conv.params["type"]} bear named #{conv.params["name"]}"}
    end

    def route(%Conv{ method: "GET", path: "/about" } = conv) do
        @pages_path
        |> Path.join("about.html")
        |> File.read
        |> handle_file(conv)
    end

    def route(%Conv{ method: "GET", path: "/pages/" <> slug } = conv) do
        @pages_path
        |> Path.join(slug <> ".html")
        |> File.read
        |> handle_file(conv)
    end
      
    def route( %Conv{ method: "DELETE", path: "/bears/" <> _id } = conv) do
        %{ conv | status: 403, resp_body: "You can't delete a bear"}
    end


    # example of using a case clause, which would replace the route() function clauses
    # 
    # def route(%{ method: "GET", path: "/about" } = conv) do
    #     file = 
    #         Path.expand("../../pages", __DIR__)
    #         |> Path.join("about.html")

    #     case File.read(file) do
    #         {:ok, content} -> 
    #             %{conv | status: 200, resp_body: content}

    #         # catch 404 errors
    #         {:error, :enoent} -> 
    #             %{conv | status: 404, resp_body: "File not found"}
            
    #         # catch all errors
    #         {:error, reason} -> 
    #             %{conv | status: 500, resp_body: "File error: #{reason}"}
    #     end
    # end

    # put catch all after other defs so that they are matched first
    def route(%Conv{ path: path } = conv) do
        %{ conv | status: 404, resp_body: "No #{path} here!" }
    end

    def format_response(%Conv{} = conv) do
        # using String.length/1 to set the value of the Content-Length header in the response won't be correct for all possible UTF-8 encoded strings. 
        # The Content-Length header must indicate the size of the body in bytes. Therefore, it's better to use the byte_size/1 function to get the number of bytes:
        """
        HTTP/1.1 #{Conv.full_status(conv)}
        Content-Type: text/html
        Content-Length: #{byte_size(conv.resp_body)}

        #{conv.resp_body}
        """
    end


    

end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts response