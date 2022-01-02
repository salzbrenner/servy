defmodule Servy.Parser do
  # alias Servy.Conv, as: Conv
  # shortcut for above, uses name after .
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    # the cons | operator splits the list into heads and tails,
    # to give first item before | and all items after in own list
    # you can also access head and tail of list using hd(list) and tl(list)
    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})
    # headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2`
  into a map with corresponding keys and values

  ## Examples
      iex> params_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex> Servy.Parser.parse_params("multipart/form-data", params_string)
      %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params("application/json", params_string) do
    Poison.Parser.parse!(params_string, %{})
  end

  def parse_params(_, _), do: %{}

  # def parse_headers(header_lines) do
  #     Enum.reduce(header_lines, %{}, fn(x, acc) -> 
  #         [key, value] = String.split(x, ": ")
  #         Map.put(acc, key, value)
  #     end)
  # end

  def parse_headers([], headers), do: headers

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end
end
