extends CommonActor


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_state_machine = $AnimationTree.get('parameters/playback')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

# child class will run first 
func _physics_process(delta: float) -> void:
	get_input('attack', 'interact', 'move_right', 'move_left', 'move_up')



func _on_SwordHit_body_entered(body: Node) -> void:
	if body.is_in_group('enemy'):
		body.hurt()


func _on_Interact_body_entered(body: Node) -> void:
	if body.is_in_group('healing_item'):
		heal()
	if body.is_in_group('attack_item') and !_has_sword:
		pickup_sword()
	


func _on_Interact_area_entered(area: Area2D) -> void:
	if area.is_in_group('door_area'):
		area.switch_state()

func get_object_type(): # used for goap 
	return "player"
	
func action(character): # this action is ruled by goap 
	if character._has_sword:
		character.attack()
		yield(get_tree().create_timer(1.0), "timeout")
		return true
	else:
		return false 
	
