class_name TaskControl
extends Control

enum STATE{
  IDLE,
  QUEUED,
  SAMPLING,
  FINISHED,
  FAILED
 }

var state = STATE.IDLE setget _set_state
const idle_text =     "   Go!  "
const queued_text =   " queued "
const sampling_text = "sampling"
const finished_text = "finished"
const failed_text =   " failed "

func _set_state(new_state):
  state =  new_state
  match new_state:
    STATE.IDLE:
      remove_button.disabled = false
      queue_button.disabled = false
      queue_button.text = idle_text
      _set_editable(true)
    STATE.QUEUED:
      remove_button.disabled = false
      queue_button.disabled = false
      queue_button.text = queued_text
      _set_editable(false)
      Signals.emit_signal("task_queued")
    STATE.SAMPLING:
      remove_button.hide()
      cancel_button.show()
      if seed_line_edit.text == "":
        seed_line_edit.text = str(randi())
        print_debug("use random seed ",seed_line_edit.text)
      remove_button.disabled = true
      queue_button.text = sampling_text
      queue_button.modulate = Color.yellow
      queue_button.disabled = true
      _set_editable(false)
    STATE.FINISHED:
      remove_button.show()
      cancel_button.hide()
      remove_button.disabled = false
      queue_button.text = finished_text
      queue_button.disabled = true
      queue_button.modulate = Color.green
      _set_editable(false)
    STATE.FAILED:
      remove_button.show()
      cancel_button.hide()
      remove_button.disabled = false
      queue_button.text = failed_text
      queue_button.disabled = true
      queue_button.modulate = Color.red
      _set_editable(false)

signal copy_created

onready var queue_button = $VBoxContainer/SettingsContainer/HBoxContainer2/QueueButton
onready var prompt_edit = $VBoxContainer/SettingsContainer/HBoxContainer1/PromptEdit
onready var w_spin_box = $VBoxContainer/SettingsContainer/HBoxContainer2/WSpinBox
onready var h_spin_box = $VBoxContainer/SettingsContainer/HBoxContainer2/HSpinBox
onready var samples_spin_box = $VBoxContainer/SettingsContainer/HBoxContainer2/SampleSpinBox
onready var results_container = $VBoxContainer/ResultsContainer
onready var drop_down_button = $VBoxContainer/SettingsContainer/HBoxContainer2/DropDownButton
onready var steps_spin_box = $VBoxContainer/SettingsContainer/HBoxContainer2/StepsSpinBox
onready var iterations_spin_box = $VBoxContainer/SettingsContainer/HBoxContainer2/IterationsSpinBox
onready var scale_spin_box = $VBoxContainer/SettingsContainer/HBoxContainer2/ScaleSpinBox
onready var seed_line_edit = $VBoxContainer/SettingsContainer/HBoxContainer2/SeedLineEdit
onready var remove_button = $VBoxContainer/SettingsContainer/HBoxContainer2/RemoveButton
onready var cancel_button = $VBoxContainer/SettingsContainer/HBoxContainer2/CancelButton

func _ready():
  _set_state(STATE.IDLE)
  update_drop_down_button()
  results_container.connect("result_added",self,"_on_results_container_result_added")

func _on_results_container_result_added():
  drop_down_button.disabled = false
  update_drop_down_button()

func get_args() -> Dictionary:
  return {
  "prompt":prompt_edit.text,
  "W":int(w_spin_box.value),
  "H":int(h_spin_box.value),
  "samples":int(samples_spin_box.value),
  "ddim_steps":int(steps_spin_box.value),
  "n_iter":int(iterations_spin_box.value),
  "scale":scale_spin_box.value,
  "seed": seed_line_edit.text
  }

func _on_QueueButton_pressed():
  match state:
    STATE.QUEUED:
      _set_state(STATE.IDLE)
    STATE.IDLE:
      _set_state(STATE.QUEUED)
    _:assert(0) #this should never happen

func _set_editable(value:bool):
  prompt_edit.editable = value
  w_spin_box.editable = value
  h_spin_box.editable = value
  samples_spin_box.editable = value
  steps_spin_box.editable = value
  scale_spin_box.editable = value
  seed_line_edit.editable = value
  iterations_spin_box.editable = value

func _on_AddButton_pressed():
  Signals.emit_signal("task_add_button_pressed",self)

func _on_RemoveButton_pressed():
  Signals.emit_signal("task_removed")
  queue_free()
  
func _on_DropDownButton_pressed():
  results_container.visible = !results_container.visible
  update_drop_down_button()

func update_drop_down_button():
  var result_count = results_container.get_result_count()
  drop_down_button.disabled = result_count == 0
  var text := ""
  if results_container.visible:
    text = "hide "
    drop_down_button.icon = preload("res://icons/GuiDropup.svg")
  else:
    text = "show "
    drop_down_button.icon =  preload("res://icons/GuiDropdown.svg")
  text += str(result_count)
  text += " results"
  drop_down_button.text = text

func _on_CancelButton_pressed():
  StableDiffusion.canceled = true
  cancel_button.disabled = true
  queue_button.text = "canceled"
