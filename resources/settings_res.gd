class_name Settings
extends Resource

export var save_path := "user://settings.json"

var dict := {
  "weights_path"  : "",
  "outdir" : ""} setget _set_dict

func _init():
  print_debug("load settings")
  var config_file := File.new()
  if config_file.open(save_path,File.READ) == OK:
    dict = JSON.parse(config_file.get_as_text()).result
  else:
    print_debug("Could not load from " + save_path)
    
func _set_dict(new_dict):
  dict = new_dict
  print_debug("save settings:\n " + str(dict))
  var config_file := File.new()
  if(config_file.open(save_path,File.WRITE) == OK):
    config_file.store_string(JSON.print(dict))
    config_file.close()
  else:
    print_debug("Could not save to " + save_path)
  
  
