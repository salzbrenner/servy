
defmodule Servy.BearController do
    alias Servy.Wildthings
    alias Servy.Bear
    
    import Servy.View, only: [render: 3]
    
    def index(conv) do
        bears = 
            Wildthings.list_bears()
            |> Enum.sort(&Bear.order_asc_by_name/2)
        Servy.View.render(conv, "index.eex", bears: bears)
    end

    def show(conv, %{"id" => id}) do
        bear = Wildthings.get_bear(id)
        Servy.View.render(conv, "show.eex", bear: bear)
    end

    def create(conv, %{"name" => name, "type" => type} = params) do
        %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}"}
    end

    def delete(conv) do
        %{ conv | status: 403, resp_body: "You can't delete a bear"}
    end
end