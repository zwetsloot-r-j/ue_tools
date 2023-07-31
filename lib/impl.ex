defmodule UeTools.Impl do

  def impl(class_name) do
    with {:ok, project} <- UeTools.UeProject.find_project_file(),
         {:ok, %{cpp: cpp, h: h}} <- UeTools.PathFinder.search_h_and_cpp(class_name, project),
         {:ok, header} <- File.read(h),
         {:ok, implementation} <- File.read(cpp),
         {:ok, parsed_header} <- UeTools.HeaderParser.parse(header)
    do
      implementation = UeTools.CodeGenerator.implement_methods(implementation, parsed_header)
      File.write(cpp, implementation)
    else
      error ->
        error
    end
  end

end
