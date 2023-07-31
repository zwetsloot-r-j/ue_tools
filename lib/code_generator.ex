defmodule UeTools.CodeGenerator do

  def implement_methods(cpp, methods) do
    Enum.reduce(methods.methods, cpp, fn method, acc ->
      write_method_to_cpp(acc, method, methods.class_name)
    end)
  end

  defp write_method_to_cpp(cpp, method, class_name) do
    head = "#{method.return_type} #{class_name}::#{method.method_name}("
    {:ok, exists_checker} = Regex.compile("#{method.return_type} #{class_name}::#{method.method_name}")

    if Regex.match?(exists_checker, cpp) do
      cpp
    else
      append_method(cpp, head, method.args)
    end
  end

  defp append_method(cpp, head, [arg]) do
    "#{cpp}\n#{head}#{Enum.join(arg, " ")})\n{\n\n}\n"
  end

  defp append_method(cpp, head, args) do
    args = Enum.map(args, fn arg -> Enum.join(arg, " ") end)
    "#{cpp}\n#{head}\n\t#{Enum.join(args, ",\n\t")}\n)\n{\n\n}\n"
  end

end
