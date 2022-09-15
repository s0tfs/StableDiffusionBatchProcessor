extends ScrollContainer

export var task_control_packed_scene :PackedScene

onready var tasks_container := $TasksContainer
var inference_thread := Thread.new()
var current_task :TaskControl = null 
var args : Dictionary

export var settings :Resource = preload("res://resources/settings.tres")

func _ready():
  randomize()
  StableDiffusion.connect("model_init_progressed",self,"_on_model_init_progressed")
  StableDiffusion.connect("inference_finished",self,"_on_inference_finished")
  StableDiffusion.connect("image_data_ready",self,"_on_image_data_ready")
  Signals.connect("task_queued",self,"_try_to_start_new_task")
  Signals.connect("task_removed",self,"_on_task_removed")
  Signals.connect("task_add_button_pressed",self,"_on_task_add_button_pressed")

func _on_task_add_button_pressed(task:TaskControl):
  var new_task:TaskControl = task_control_packed_scene.instance()
  tasks_container.add_child_below_node(task,new_task)
  new_task.prompt_edit.text = task.prompt_edit.text
  new_task.w_spin_box.value = task.w_spin_box.value
  new_task.h_spin_box.value = task.h_spin_box.value
  new_task.samples_spin_box.value = task.samples_spin_box.value
  new_task.steps_spin_box.value = task.steps_spin_box.value
  new_task.seed_line_edit.text = ""#task.seed_line_edit.text 
  new_task.iterations_spin_box.value = task.iterations_spin_box.value
  new_task.scale_spin_box.value =task.scale_spin_box.value
  new_task.grab_focus()

func _on_task_removed():
  yield(get_tree().create_timer(0.3),"timeout")
  if tasks_container.get_child_count() == 0:
    tasks_container.add_child(task_control_packed_scene.instance())

func _try_to_start_new_task():
  print_debug("try to start new task")
  if StableDiffusion.model_ready:
    if inference_thread.is_active():
      if not inference_thread.is_alive():
        inference_thread.wait_to_finish()
    if not inference_thread.is_active():
      for child in tasks_container.get_children():
        assert(child is TaskControl)
        if child.state == TaskControl.STATE.QUEUED:
          current_task = child
          current_task.state = TaskControl.STATE.SAMPLING
          if inference_thread.start(StableDiffusion,"inference_gd",current_task.get_args()) != OK:
            print_debug("Failed to start thread.")
            current_task.state = TaskControl.STATE.FAILED
          return
        
func _on_model_init_progressed(message):
  if message == "success":
    _try_to_start_new_task()
  
func _on_image_data_ready(p_W:int,p_H:int,p_seed:int,data:PoolByteArray):
  var image := Image.new()
  image.create_from_data(p_W,p_H,false,Image.FORMAT_RGB8,data)
  if settings.dict.outdir != "":
    var dir := Directory.new()
    var save_path = settings.dict.outdir.plus_file(current_task.get_args()["prompt"].substr(0,100))
    if not dir.dir_exists(save_path):
      dir.make_dir_recursive(save_path)
    image.save_png(save_path.plus_file("seed_" + str(p_seed).pad_zeros(9) + ".png"))
  current_task.results_container.call_deferred("add_result",image)
  
func _on_inference_finished():
  current_task.state = TaskControl.STATE.FINISHED
  inference_thread.call_deferred("wait_to_finish")
  call_deferred("_try_to_start_new_task")
