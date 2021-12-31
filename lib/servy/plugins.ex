defmodule Servy.Plugins do
    require Logger
    
    alias Servy.Conv

    def emojify(%Conv{ status: 200 } = conv) do
        %{ conv | resp_body: "🙂🙂🙂\n" <> conv.resp_body <> "\n🙂🙂🙂"}
    end

    def emojify(%Conv{} = conv), do: conv

    def track(%Conv{status: 404, path: path} = conv) do
        if Mix.env != :test do
            Logger.notice("Warning: #{path} is on the loose")
        end
        conv
    end

    def track(%Conv{} = conv), do: conv

    def rewrite_path(%{ path: "/wildlife" } = conv) do
        %{ conv | path: "/wildthings" }
    end

    # more geneneric rewrite_path
    def rewrite_path(%Conv{path: path} = conv) do 
        # ?<thing> captures results of \w+
        # ?<id> captures result of \d+
        regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
        # returns a map or nil
        # in this case returns %{ "id" => "7", "thing" => "lions"}
        captures = Regex.named_captures(regex, path)
        # so delegate to a new set of rewrite_path_captures function clauses
        rewrite_path_captures(conv, captures)
    end

    def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
        %{ conv | path: "/#{thing}/#{id}" }
    end
      
    def rewrite_path_captures(%Conv{} = conv, nil), do: conv

    # def rewrite_path(%{ path: "/bears?id=" <> id } = conv) do
    #     %{ conv | path: "/bears/#{id}" }
    # end

    # # default function clause that rest of paths can still run while not being matched
    # def rewrite_path(conv), do: conv

    def log(%Conv{} = conv) do
        if Mix.env == :dev do
            Logger.info(conv)
        end
        conv
    end
end
