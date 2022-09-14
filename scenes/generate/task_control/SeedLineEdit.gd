extends LineEdit

func _on_SeedLineEdit_text_changed(new_text):
  if text != "":
    text = str(new_text.to_int())

