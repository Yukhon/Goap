extends StaticBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var _state_machine = $AnimationTree.get('parameters/playback')

var _is_open = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_state_machine.travel('close')


func switch_state():
	print('switch')
	if _is_open:
		_is_open = false
		_state_machine.travel('close')
	else:
		_is_open = true
		_state_machine.travel('open')

# ---------- GOAP ---------------
func get_object_type():
	if _is_open:
		return "open_door"
	else:
		return "close_door"
		
func action(character):
	character.interact()
	yield(get_tree().create_timer(1.0), "timeout")
	return true

