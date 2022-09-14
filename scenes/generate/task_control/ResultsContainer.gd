extends Panel

signal result_added

export var texture_rect_target_size_x = 512
onready var flow_container = $ScrollContainer/FlowContainer

func add_result(image:Image):
  var result_tile = preload("res://scenes/generate/task_control/result_tile.tscn").instance()
  result_tile.image = image
  var image_texture = ImageTexture.new()
  image_texture.create_from_image(image)  
  result_tile.texture = image_texture
  var scale = float(texture_rect_target_size_x) / float(image_texture.get_size().x)
  if scale <= 1.0:
    image_texture.set_size_override(scale * image_texture.get_size())
  flow_container.add_child(result_tile)
  emit_signal("result_added")
  
func get_result_count():
  return flow_container.get_child_count()

func clear():
  for child in flow_container.get_children():
    child.queue_free()
