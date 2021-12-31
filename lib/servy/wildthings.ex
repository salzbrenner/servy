defmodule Servy.Wildthings do
    alias Servy.Bear
    def list_bears do
        Path.expand("../../db", __DIR__)
            |> Path.join("bears.json")
            |> File.read!
            |> Poison.decode!(as: %{"bears" => [%Bear{}]})
            |> Map.get("bears")
    end

    # function clause will only match when id is integer
    def get_bear(id) when is_integer(id) do
        Enum.find(list_bears(), fn(b) -> b.id == id end)
    end

    # matching binary b/c strings are binaries
    def get_bear(id) when is_binary(id) do
        id |> String.to_integer |> get_bear
    end
end