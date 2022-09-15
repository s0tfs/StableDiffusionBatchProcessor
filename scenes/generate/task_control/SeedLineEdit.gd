extends LineEdit

func _on_SeedLineEdit_text_changed(new_text):
  var old_len = text.length()
  var old_pos = caret_position
  text = str(text.to_int())
  var new_len = text.length()
  caret_position = old_pos + new_len - old_len
