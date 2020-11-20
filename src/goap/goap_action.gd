tool
extends Node
class_name GOAPAction

export(String) var action = null setget set_action, get_action
export(String) var preconditions = ""
export(String) var effect = ""
export(float) var cost = 1

func get_action():
	if action == null || action == "":
		return name 
	else:
		return action

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
func set_action(a):
	action = a

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
