class_name InputImageButton
extends TextureButton

export var default_texture:Texture
var input_image_path:String setget _set_image_path

func _set_image_path(path:String):
  if File.new().file_exists(path):
    var image := Image.new()
    if image.load(path) == OK:
      var image_texture := ImageTexture.new()
      image_texture.create_from_image(image)
      texture_normal = image_texture
      input_image_path = path
      get_node("../StrengthLabel").show()
      get_node("../StrengthSpinBox").show()
    else:
      clear()
      
func clear():
      input_image_path = ""
      get_node("../StrengthLabel").hide()
      get_node("../StrengthSpinBox").hide()
      texture_normal = default_texture
      
func _on_InputImageButton_pressed():
  Signals.emit_signal("input_image_requested",self)

func _gui_input(event):
  if disabled:
    return
  if event is InputEventMouseButton:
    if event.is_pressed() and event.button_index == BUTTON_RIGHT:
      clear()
