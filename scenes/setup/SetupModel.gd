extends Control

onready var weights_line_edit := $Weights/LineEdit
onready var outdir_line_edit := $Outdir/LineEdit
onready var init_button = $Weights/init_button

export var settings :Resource = preload("res://resources/settings.tres")
var model_init_thread:Thread

func _ready():
  weights_line_edit.text = settings.dict["weights_path"]
  outdir_line_edit.text = settings.dict["outdir"]
  StableDiffusion.connect("model_init_progressed",self,"_on_model_init_progressed")

func _on_init_button_pressed():
  init_button.disabled = true
  model_init_thread = Thread.new()
  model_init_thread.start(StableDiffusion,"init_model",weights_line_edit.text)

func _on_model_init_progressed(message:String):
  if message == "success":
    init_button.disabled = false
    model_init_thread.call_deferred("wait_to_finish")
  if message == "failed":
    init_button.disabled = false
    model_init_thread.call_deferred("wait_to_finish")


func _on_Setup_Model_hide():
  if weights_line_edit!= null:
    settings.dict["weights_path"] = weights_line_edit.text 
    settings.dict["outdir"] = outdir_line_edit.text
