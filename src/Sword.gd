extends StaticBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

# ------------- GOAP --------------------
func get_object_type():
	return "sword"
	
func action(character):
	print(character.get_name(), " pick up the sword")
	character.interact() # this is the animation and this animation will trigger the detect area function
	# output signal when we
	yield(get_tree().create_timer(1.0), "timeout")
	return true

