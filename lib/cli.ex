defmodule UeTools.CLI do

  def main(["new", class_type, class_name]) do
    UeTools.New.new(class_type, class_name)
    |> out()
  end

  def main(_) do
    """
    Usage:
      new {class_type} {class_name}
    """
    |> out()
  end

  defp out(:ok) do
    IO.puts("OK")
  end

  defp out({:ok, result}) do
    IO.puts("OK: #{result}")
  end

  defp out({:error, reason}) do
    IO.puts("ERROR: #{reason}")
  end

  defp out(output) do
    IO.puts(output)
  end
end
