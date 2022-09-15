extends Control

onready var file_dialog = $FileDialog
onready var line_edit = $LineEdit

func _on_FileDialog_dir_selected(dir):
  line_edit.text = dir

func _on_open_file_dialog_button_pressed():
  file_dialog.popup()

func _on_ClearButton_pressed():
  line_edit.text = ""
