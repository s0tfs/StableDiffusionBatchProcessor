class_name Settings
extends Resource

export var save_path := "user://settings.json"

var dict := {
  "weights_path"  : "",
  "outdir" : "",
  "device" : 0} setget _set_dict

func _init():
  var config_file := File.new()
  if config_file.open(save_path,File.READ) == OK:
    var json_dict = JSON.parse(config_file.get_as_text()).result
    for key in json_dict:
      dict[key] = json_dict[key]
  else:
    print_debug("Could not load from " + save_path)
    
func _set_dict(new_dict):
  dict = new_dict
  var config_file := File.new()
  if(config_file.open(save_path,File.WRITE) == OK):
    config_file.store_string(JSON.print(dict))
    config_file.close()
  else:
    print_debug("Could not save to " + save_path)
  
  
