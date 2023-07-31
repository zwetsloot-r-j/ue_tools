defmodule UeTools.PathFinder do

  def search_h_and_cpp(file_name, project) do
    with {:ok, h_pattern} <- Regex.compile("^#{file_name}\.h"),
         {:ok, cpp_pattern} <- Regex.compile("^#{file_name}\.cpp"),
         {:ok, h_matches} <- search(h_pattern, project),
         {:ok, cpp_matches} <- search(cpp_pattern, project)
    do
      case {cpp_matches, h_matches} do
        {[], []} ->
          {:error, :no_h_and_cpp}
        {[], _} ->
          {:error, :no_cpp}
        {_, []} ->
          {:error, :no_h}
        {[cpp | _], [h | _]} ->
          {:ok, %{cpp: cpp, h: h}}
      end
    end
  end

  def search(pattern, project) do
    with {:ok, path} <- File.cwd() do
      search(path, pattern, project)
    end
  end

  def search(dir, pattern, project) do
    search_down(dir, pattern, "", project)
  end

  defp search_up(dir, pattern, ignore_dir) do
    with {:ok, files} <- File.ls(dir),
         {:ok, ignore_dir_pattern} = Regex.compile(ignore_dir)
    do
      stats = Enum.map(files, fn file -> {file, File.lstat("#{dir}/#{file}")} end)

      file_stat = Enum.flat_map(stats, fn
                    {file, {:ok, %{type: :regular} = file_stat}} -> [{file, file_stat}]
                    _ -> []
                  end)

      dir_stat = Enum.flat_map(stats, fn
                   {file, {:ok, %{type: :directory} = dir_stat}} -> [{file, dir_stat}]
                   _ -> []
                 end)
                 |> Enum.filter(fn {file, _} -> ignore_dir == "" || !String.match?(file, ignore_dir_pattern) end)

      matches = Enum.filter(file_stat, fn {file, _} -> String.match?(file, pattern) end)

      case matches do
        [_ | _] = matches -> Enum.map(matches, fn {file, _} -> "#{dir}/#{file}" end)
        [] ->
          Enum.reduce_while(dir_stat, [], fn
            {up_dir, _}, acc ->
              with [_ | _] = matches <- search_up("#{dir}/#{up_dir}", pattern, "") do
                {:halt, matches}
              else
                _ ->
                  {:cont, acc}
              end
          end)
      end
    end
  end

  defp search_down(dir, pattern, ignore_dir, project) do
    if !String.starts_with?(dir, project.directory) do
      IO.inspect({:error, :not_in_project})
    else
      case search_up(dir, pattern, ignore_dir) do
        [] ->
          search_down(
            Path.join(dir, "..") |> Path.expand(),
            pattern, Path.basename(dir),
            project
          )
        matches ->
          {:ok, matches}
      end
    end
  end
end
