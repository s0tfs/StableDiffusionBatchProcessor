class_name ResultTile
extends TextureRect

var image: Image

func _on_SaveButton_pressed():
  Signals.emit_signal("image_save_requested",image)



