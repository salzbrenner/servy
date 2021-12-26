defmodule Servy do
  def hello(name) do
    "Howdy, #{name}!"
  end
end

IO.puts Servy.hello("Elixir")
request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response