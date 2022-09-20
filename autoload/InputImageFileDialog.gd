extends FileDialog

var requesting_task:InputImageButton

func _ready():
  Signals.connect("input_image_requested",self,"_on_input_image_requested")
  connect("file_selected",self,"_on_file_selected")

func _on_input_image_requested(task:InputImageButton) -> void:
  requesting_task = task
  popup()
  
func _on_file_selected(path:String):
  requesting_task.input_image_path = path
  
