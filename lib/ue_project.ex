defmodule UeTools.UeProject do

  defstruct file: "",
            directory: "",
            contents: %{}

  def find_project_file() do
    with {:ok, cwd} <- File.cwd(),
         {:ok, project_file} <- find_project_file(cwd),
         {:ok, project_file_contents} <- File.read(project_file),
         {:ok, parsed_project_file} <- Jason.decode(project_file_contents)
    do
      dir = Path.join(project_file, "..")
            |> Path.expand()
      {:ok, %__MODULE__{file: project_file, directory: dir, contents: parsed_project_file}}
    else
      error -> error
    end
  end

  defp find_project_file(dir) do
    with {:ok, files} <- File.ls(dir) do
      project_files = files
                      |> Enum.filter(fn file -> String.match?(file, ~r/\.uproject$/) end)

      case {project_files, dir} do
        {[project_file | _], _} -> {:ok, "#{dir}/#{project_file}"}
        {[], "/"} -> {:error, :project_file_not_found}
        {[], _} -> find_project_file(Path.join(dir, "../") |> Path.expand)
      end
    else
      error -> error
    end
  end

end
