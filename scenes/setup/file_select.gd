extends Control

onready var file_dialog = $FileDialog
onready var line_edit = $LineEdit

func _on_FileDialog_file_selected(path):
  line_edit.text = path

func _on_open_file_dialog_button_pressed():
  file_dialog.popup()
