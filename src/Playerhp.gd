extends RichTextLabel


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var parent: CommonActor
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_tree().get_root().get_node("Map/Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_text("Player HP: "+ str(parent.get_hp()) + "\nhas sword:" + str(parent._has_sword))

	
	
