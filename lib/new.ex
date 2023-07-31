defmodule UeTools.New do

  def new(class_type, class_name) do
    with {:ok, project_file} <- UeTools.UeProject.find_project_file(),
         :ok <- UeTools.Templates.generate(class_name, class_type, project_file.contents)
    do
      :ok
    else
      error ->
        error
    end
  end

  def inherit(base_name, class_name) do
    with {:ok, project_file} <- UeTools.UeProject.find_project_file(),
         :ok <- UeTools.Templates.generate(class_alias(class_name), "inherited_class", project_file.contents, base_name)
    do
      :ok
    else
      error ->
        error
    end
  end

  defp class_alias("BTTaskNode"), do: "b_t_task_node"
  defp class_alias("bttask_node"), do: "b_t_task_node"
  defp class_alias(class), do: class

end
