extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var _parent
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_parent = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func switch_state():
	_parent.switch_state()
	
