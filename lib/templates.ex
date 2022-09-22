defmodule UeTools.Templates do
  def class_cpp_4, do: unquote(File.read!("templates/v4/MyClass.cpp"))
  def class_h_4, do: unquote(File.read!("templates/v4/MyClass.h"))
  def actor_component_cpp_4, do: unquote(File.read!("templates/v4/MyActorComponent.cpp"))
  def actor_component_h_4, do: unquote(File.read!("templates/v4/MyActorComponent.h"))
  def actor_cpp_4, do: unquote(File.read!("templates/v4/MyActor.cpp"))
  def actor_h_4, do: unquote(File.read!("templates/v4/MyActor.h"))
  def blueprint_function_library_cpp_4, do: unquote(File.read!("templates/v4/MyBlueprintFunctionLibrary.cpp"))
  def blueprint_function_library_h_4, do: unquote(File.read!("templates/v4/MyBlueprintFunctionLibrary.h"))
  def character_cpp_4, do: unquote(File.read!("templates/v4/MyCharacter.cpp"))
  def character_h_4, do: unquote(File.read!("templates/v4/MyCharacter.h"))
  def game_mode_base_cpp_4, do: unquote(File.read!("templates/v4/MyGameModeBase.cpp"))
  def game_mode_base_h_4, do: unquote(File.read!("templates/v4/MyGameModeBase.h"))
  def game_state_base_cpp_4, do: unquote(File.read!("templates/v4/MyGameStateBase.cpp"))
  def game_state_base_h_4, do: unquote(File.read!("templates/v4/MyGameStateBase.h"))
  def hud_cpp_4, do: unquote(File.read!("templates/v4/MyHUD.cpp"))
  def hud_h_4, do: unquote(File.read!("templates/v4/MyHUD.h"))
  def interface_cpp_4, do: unquote(File.read!("templates/v4/MyInterface.cpp"))
  def interface_h_4, do: unquote(File.read!("templates/v4/MyInterface.h"))
  def pawn_cpp_4, do: unquote(File.read!("templates/v4/MyPawn.cpp"))
  def pawn_h_4, do: unquote(File.read!("templates/v4/MyPawn.h"))
  def player_camera_manager_cpp_4, do: unquote(File.read!("templates/v4/MyPlayerCameraManager.cpp"))
  def player_camera_manager_h_4, do: unquote(File.read!("templates/v4/MyPlayerCameraManager.h"))
  def player_controller_cpp_4, do: unquote(File.read!("templates/v4/MyPlayerController.cpp"))
  def player_controller_h_4, do: unquote(File.read!("templates/v4/MyPlayerController.h"))
  def player_state_cpp_4, do: unquote(File.read!("templates/v4/MyPlayerState.cpp"))
  def player_state_h_4, do: unquote(File.read!("templates/v4/MyPlayerState.h"))
  def scene_component_cpp_4, do: unquote(File.read!("templates/v4/MySceneComponent.cpp"))
  def scene_component_h_4, do: unquote(File.read!("templates/v4/MySceneComponent.h"))
  def slate_widget_style_cpp_4, do: unquote(File.read!("templates/v4/MySlateWidgetStyle.cpp"))
  def slate_widget_style_h_4, do: unquote(File.read!("templates/v4/MySlateWidgetStyle.h"))
  def world_settings_cpp_4, do: unquote(File.read!("templates/v4/MyWorldSettings.cpp"))
  def world_settings_h_4, do: unquote(File.read!("templates/v4/MyWorldSettings.h"))
  def s_compound_widget_cpp_4, do: unquote(File.read!("templates/v4/SMyCompoundWidget.cpp"))
  def s_compound_widget_h_4, do: unquote(File.read!("templates/v4/SMyCompoundWidget.h"))

  def generate(class_name, class_type, project_file) do
    {version, _} = Integer.parse(project_file["EngineAssociation"])
    cpp_file_name = "#{class_name}.cpp"
    h_file_name = "#{class_name}.h"

    with {:ok, project_name} <-
           project_file["Modules"] |> hd |> Map.fetch("Name"),
         {:ok, cpp_template_function} <-
           generate_template_function(class_type, "cpp", version),
         {:ok, h_template_function} <-
           generate_template_function(class_type, "h", version),
         {:ok, cpp_content} <-
           generate_content(cpp_template_function, project_name, class_name, class_type),
         {:ok, h_content} <-
           generate_content(h_template_function, project_name, class_name, class_type),
         :ok <-
           File.write(cpp_file_name, cpp_content),
         :ok <-
           File.write(h_file_name, h_content)
    do
      msg = """
            generated files:
              #{h_file_name}
              #{cpp_file_name}
            """
      {:ok, msg}
    else
      :error ->
        {:error, :no_project_name}
      error ->
        error
    end
  end

  defp generate_content(generate_template_function, project_name, class_name, class_type) do
    with {:ok, template} <- generate_template(generate_template_function) do
      template = template
                 |> String.replace(~r/PROJECT_NAME/, String.upcase(project_name))
                 |> String.replace("My#{Macro.camelize(class_type)}", class_name)

      {:ok, template}
    else
      error ->
        error
    end
  end

  defp generate_template_function(class_type, extension, major_version) do
    try do
      {
        :ok,
        String.to_existing_atom("#{class_type}_#{extension}_#{major_version}")
      }
    rescue
      _ -> {:error, :invalid_template}
    end
  end

  defp generate_template(generate_template_function) do
    try do
      {:ok, apply(__MODULE__, generate_template_function, [])}
    rescue
      _ -> {:error, :invalid_template}
    end
  end
end
