extends Button


func _ready():
  StableDiffusion.connect("model_init_progressed",self,"_on_model_init_progressed")

func _on_model_init_progressed(message:String):
  if message == "Loading weights":
    disabled = true
  if message == "success":
    disabled = false
  if message == "failed":
    disabled = false
