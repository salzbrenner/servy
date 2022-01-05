defmodule ServerTest do
  use ExUnit.Case
  doctest Servy.HttpServer

  alias Servy.HttpServer
  alias Servy.HttpClient

  test "accepts request and returns response" do
    _pid = spawn(HttpServer, :start, [4000])

    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 20\r
           \r
           Bears, Lions, Tigers
           """
  end

  test "accepts request and returns response using HTTPoison" do
    _pid = spawn(HttpServer, :start, [4000])

    caller = self()

    max_concurrent_requests = 5

    for _ <- 1..max_concurrent_requests do
      spawn(fn -> send(caller, HTTPoison.get("http://localhost:4000/wildthings")) end)
    end

    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "Bears, Lions, Tigers"
      end
    end
  end
end
