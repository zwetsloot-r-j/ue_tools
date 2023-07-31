defmodule UeTools.HeaderParser do

  defstruct methods: [],
            class_name: ""

  def parse(header) do
    methods = Regex.scan(~r/\n[^\n]+ [^\n]+\([^;]*\)[^;]*;/s, header)
              |> IO.inspect
              |> Enum.map(fn
                [match | _] -> match
                [] -> ""
              end)
              |> Enum.filter(fn method -> method != "" end)
              |> Enum.map(fn method -> String.trim(method, "\n") end)
              |> Enum.map(fn method -> String.trim(method, "\t") end)
              |> Enum.map(&parse_method/1)
              |> IO.inspect
              |> Enum.filter(fn
                {:ok, _} -> true
                _ -> false
              end)
              |> Enum.map(fn {:ok, method} -> method end)

    with {:ok, class_name} <- parse_class_name(header) do
      IO.inspect({:ok, %__MODULE__{methods: methods, class_name: class_name}})
    end
  end

  defp parse_method(method) do
    with [match | _] <- Regex.run(~r/.+\(/, method),
         main_def when length(main_def) < 5 <- match
                                               |> String.replace("(", "")
                                               |> String.trim("\t")
                                               |> String.split(" ")
                                               |> Enum.filter(fn item -> item != "" end),
         main_def when not is_nil(main_def) <- apply(__MODULE__, :parse_method_main, main_def)
    do
      args = parse_args(method)
      {:ok, Map.put(main_def, :args, args)}
    else
      _ ->
        {:error, :failed_to_parse}
    end
  end

  def parse_method_main("virtual", "class", return_type, method_name) do
    %{
      return_type: return_type,
      method_name: method_name
    }
  end

  def parse_method_main(_, _, "=", _), do: nil

  def parse_method_main("virtual", return_type, method_name) do
    %{
      return_type: return_type,
      method_name: method_name
    }
  end

  def parse_method_main("class", return_type, method_name) do
    %{
      return_type: "class #{return_type}",
      method_name: method_name
    }
  end

  def parse_method_main(return_type, method_name) do
    %{
      return_type: return_type,
      method_name: method_name
    }
  end

  defp parse_class_name(header) do
    with ["class" | [_ | [class_name | _]]] <- Regex.scan(~r/class .+\n/, header)
                                               |> Enum.filter(fn
                                                 [_ | _] -> true
                                                 _ -> false
                                               end)
                                               |> Enum.map(fn [class_text | _] ->
                                                 String.split(class_text, " ")
                                               end)
                                               |> Enum.find(fn
                                                 parts when length(parts) > 2 -> true
                                                 _ -> false
                                               end)
    do
      {:ok, class_name}
    else
      _ ->
        {:error, :could_not_parse_class_name}
    end
  end

  defp parse_args(method) do
    method = method
             |> String.replace("\n", "")
             |> String.replace("\r", "")

    with [args | _] <- Regex.run(~r/\(.*\)/, method) do
      args
      |> String.trim("(")
      |> String.trim(")")
      |> String.split(",")
      |> Enum.map(fn arg -> String.trim(arg, " ") end)
      |> Enum.map(fn arg -> String.trim(arg, "\t") end)
      |> Enum.map(fn arg -> String.split(arg, " ") end)
    end
  end

end
