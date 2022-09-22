defmodule UeTools.New do

  def new(class_type, class_name) do
    with {:ok, project_file} <- UeTools.UeProject.find_project_file(),
         :ok <- UeTools.Templates.generate(class_name, class_type, project_file)
    do
      :ok
    else
      error ->
        error
    end
  end

end
