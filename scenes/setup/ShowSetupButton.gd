extends Button

onready var popup := $SetupPopup
func _on_ShowSetupButton_pressed():
  if !popup.visible:
    popup.popup()
  else:
    popup.hide()
