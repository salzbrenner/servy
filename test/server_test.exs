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

    ["wildthings", "api/bears", "hibernate/1000", "bears", "about"]
    |> Enum.map(
      &Task.async(fn ->
        HTTPoison.get("http://localhost:4000/#{&1}")
      end)
    )
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_successful_response/1)
  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
  end
end
