extends KinematicBody2D
class_name CommonActor

# Environment
const GRAVITY_VALUE := 50.0
const SPEED_VALUE := Vector2(300,850)
const PUSH_FORCE := 100.0

var _velocity = Vector2.ZERO
var _state_machine
var _hp = 2
var _has_sword = false
var _prevent_idle = false
var _current
var _facing_right = true



func get_hp():
	return _hp
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(_delta: float) -> void:
	_current = _state_machine.get_current_node()
	
	apply_gravity()
	_velocity = move_and_slide(_velocity, Vector2.UP)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("kinematicbodies"):
			collision.collider.move_and_slide(-collision.normal * PUSH_FORCE)

	if _current == "Heal": # plus other possible state
		_prevent_idle = false
		
	#---------------IDLE-------------------------
	if _velocity.length() == 0 and _current != 'Idle' and not _prevent_idle:
		_state_machine.travel("Idle")
	
func apply_gravity():
	_velocity.y += GRAVITY_VALUE

	
func interact():
	_state_machine.travel("Interact")
	
func run(velox):
	if velox != 0.0:
		if velox > 0 and ! _facing_right:
			self.scale.x *= -1
			_facing_right = true
			
		elif velox < 0 and _facing_right :
			self.scale.x *= -1
			_facing_right = false
		
	if _current != 'Attack' and _current != 'Interact':
			_velocity.x = velox
	if velox != 0 and _current != 'Run':
		_state_machine.travel("Run")
	


func get_input(attack, interact, right, left, jump):

	#---------ATTACK -------------------------------
	if Input.is_action_just_pressed(attack) and _current != "Attack" and _has_sword:
		attack()
		return
	if Input.is_action_just_pressed(interact) and _current != "Interact":
		interact()
		return
	#-------------RUN ---------------------------
	if Input.is_action_just_released(right) or Input.is_action_just_released(left):
		run(0.0)
	elif Input.is_action_pressed(right) or Input.is_action_pressed(left):
		var velox = (Input.get_action_strength(right) - Input.get_action_strength(left)) * SPEED_VALUE.x
		run(velox)
		
	# ------------------- JUMP ------------------------------
	if Input.is_action_pressed(jump) and is_on_floor() and _current != 'Jump':
		jump()


func hurt():
	if is_in_group('enemy'):
		print('enemy get hurt')
	else:
		print('player get hurt')
	if _hp > 0: 
		_hp -= 1
		if _hp != 0:
			_state_machine.travel("Hurt")
		else:
			die()

func heal():
	print("heal")
	_prevent_idle = true
	_state_machine.travel('Heal')
	_hp += 1

func die():
	_state_machine.travel("Die")
	set_physics_process(false)

func pickup_sword():
	_has_sword = true
	

# ------- GOAP shared action ---------------

func attack():
	_state_machine.travel("Attack")
	
func jump():
	_velocity.y = -SPEED_VALUE.y
	_state_machine.travel('Jump')


