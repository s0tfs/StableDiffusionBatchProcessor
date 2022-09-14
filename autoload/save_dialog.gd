extends FileDialog


var image_to_save:Image

func _ready():
  mode = FileDialog.MODE_SAVE_FILE
  access = FileDialog.ACCESS_FILESYSTEM
  filters = PoolStringArray(["*.png;PNG Images"])
  resizable = true
  window_title = "Save as ..."
  connect("file_selected",self,"_on_file_selected")
  Signals.connect("image_save_requested",self,"_on_image_save_requested")
  
func _on_image_save_requested(image:Image):
  image_to_save = image
  popup()

func _on_file_selected(path):
  assert(image_to_save)
  image_to_save.save_png(path)
