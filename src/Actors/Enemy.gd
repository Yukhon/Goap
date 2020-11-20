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




func _on_SwordHit_body_entered(body: Node) -> void:
	if body.is_in_group('player'):
		body.hurt()


func _on_Interact_body_entered(body: Node) -> void:
	if body.is_in_group('healing_item'):
		heal()
	if body.is_in_group('attack_item') and !_has_sword:
		pickup_sword()



func _on_Interact_area_entered(area: Area2D) -> void:
	if area.is_in_group('door_area'):
		area.switch_state()


# ------------ GOAP -----------------
# list all the available interactable object 
onready var apple = get_tree().get_root().get_node("Map/Apple")
onready var player = get_tree().get_root().get_node("Map/Player")
onready var door = get_tree().get_root().get_node("Map/Door")
onready var sword = get_tree().get_root().get_node("Map/Sword")
onready var actionqueue = get_tree().get_root().get_node("Map/CanvasLayer/ActionQueue")
onready var statequeue = get_tree().get_root().get_node("Map/CanvasLayer/State")
onready var notification = get_tree().get_root().get_node("Map/Notification")


var motion = Vector2(0, 0)
var previous_position = Vector2(0, 0)
var blocked_time = 0.0 # sometimes we cannot control the movement very well, thus we check whether we get stucked
#onready var target = player.get_position()
var target = null 
var target_pos = Vector2.ZERO

signal run_end # signal that we reach the target 
var blocked = false



func _physics_process(delta):
	# and we are not going to handle whether the enermy is dead here 
	if target == null:
		get_input('enemy_attack', 'enemy_interact', 'enemy_move_right', 'enemy_move_left', 'enemy_move_up')	 # this will analyse the manual input 
	else:
		target_pos = target.get_position()
		var direction = Vector2(0, 0)
		var remaining = Vector2(target_pos.x, target_pos.y) - get_position()
		if remaining.length() < 35.0:
			target = null
			target_pos = Vector2.ZERO
			emit_signal("run_end", true)
			return
		else:
			direction = SPEED_VALUE*(remaining).normalized()
		if direction.x > SPEED_VALUE.x:
			direction.x = SPEED_VALUE.x # set up the direction (note that if we count y then it will fly )
		if direction.y > SPEED_VALUE.y:
			direction.y = SPEED_VALUE.y # set up the direction (note that if we count y then it will fly )

			
		var h_motion = direction.x
	
		if (previous_position-position).length()/delta > 1:
			_state_machine.travel("Run")
			blocked_time = 0.0
		else:
			_state_machine.travel("Idle")
			if (previous_position-position).length()/delta < 0.1:
				# in this game we can be blocked by the world, thus we usually jump 
				blocked_time += delta
				if blocked_time > 0.2:
					print('movement get blocked, replan!!!')
					blocked = true
					emit_signal("run_end", false)
		previous_position = position
		run(h_motion)


func run_to(p): # setup the runing target, though we need to solve the detail, like how to jump 
	blocked_time = 0.0
	target = p
	
func _input(event):
	# other actions are taken cared by the functions in parent class 
	if event is InputEventKey and event.is_pressed():
		if event.get_scancode() == KEY_F:
			var obj = find_nearest_object()
			if obj['object'] != null:
				print("nearest interactable object", obj['object'].get_name())
			else:
				print("cannot find anything")
			if obj.distance < 35.0 and obj.object.has_method("action"):
				obj.object.action(self) # here it is more likely interaction

		elif event.get_scancode() == KEY_G:
			goap()

func find_nearest_object(object_type = null): # find the nearest object, in our cases we only have 1 item thus not really useful 
	# this distance can be set to the length of the detection area
	var nearest_distance = $Detect.get_node("Shape").get_shape().get_extents().x * self.scale.x
	var nearest_object = null
	for o in $Detect.get_overlapping_bodies(): # set the detection 
		
		if o.is_inside_tree(): # the object is in the scene tree
			var distance = (self.position - o.position).length()
#			if o != self and o.get_script() != null and (object_type == null or o.get_object_type() == object_type):
#				print(o.get_name(),": ", distance) # fyi, distance 35 is enough for interaction
			if o != self and o.get_script() != null and (object_type == null or o.get_object_type() == object_type) and distance < nearest_distance:
				nearest_distance = distance
				nearest_object = o
	return { object=nearest_object, distance=nearest_distance }

func count_visible_objects(object_type): # count all the object you can see
	var count = 0
	for o in $Detect.get_overlapping_bodies():
		if o.is_inside_tree():
			var distance = (self.position - o.position).length()
			if o != self and o.get_script() != null and o.get_object_type() == object_type:
				count += 1
	return count


# Actions for GOAP

# grow tree will try to run to that location
# then what if we want to eat or attack (run to that location too?)

func ai_attack():
	var status = player.action(self)
	if status is GDScriptFunctionState:
		status = yield(status, "completed")
	if status:
		if player._hp == 1: # check the success of attack
			return true 
	return false
	
func ai_attack2():
	var status = player.action(self)
	if status is GDScriptFunctionState:
		status = yield(status, "completed")
	return status
	
	if status:
		if player._hp == 0:
			return true 
	return false
	
func eat():
	var status = apple.action(self)
	if status is GDScriptFunctionState:
		status = yield(status, "completed")
	return status
	
func open_door():
	var status = door.action(self)
	if status is GDScriptFunctionState:
		status = yield(status, "completed")
	blocked = false
	return status
	
func close_door():
	var status = door.action(self)
	if status is GDScriptFunctionState:
		status = yield(status, "completed")
	return status
	
func ai_jump():
	if is_on_floor():
		jump()
	yield(get_tree().create_timer(1.5), "timeout")
	blocked = false
	return false # always replan 
	
func idle():
	return false 
func take_sword():
	var status = sword.action(self)
	if status is GDScriptFunctionState:
		status = yield(status, "completed")
	return status
	
func run_to_player():
	run_to(player)
	return yield(self, "run_end")


func run_to_sword():
	run_to(sword)
	return yield(self, "run_end")

	
func run_to_apple():
	run_to(apple)
	return yield(self, "run_end")
	
func run_to_door():
	run_to(door)
	return yield(self, "run_end")


# GOAP stuff

func get_goap_current_state():
	var state = ""
	for o in ["sword", "apple", "player", "door"]:
		var dic =  find_nearest_object(o)
		if dic.object != null and dic.distance < 35:
			state += "near_"+o+" "
		else:
			state += "!near_"+o+" "

	if blocked: # this block is dynamic 
		var dic =  find_nearest_object()
		if dic.object.get_name() == 'Door' and dic.distance < 35:
			print("!!! Door block!")
			state += "door_block "
			state += "!road_block "
			
		else:
			print("!!! Road block!")
			state += "!door_block "
			state += "road_block "
			
	else:
		state += "!door_block "
		state += "!road_block "
	
	# now testing sword 
	if _has_sword:
		state += "has_sword "
	else:
		state += "!has_sword "
	
	# now testing player injured / die
	state += "player_injured " if (player._hp < 2) else "!player_injured "
	state += "player_die " if (player._hp == 0) else "!player_die "
	
	# now testing injured 
	state += "injured" if (_hp < 2) else "!injured"
	statequeue.text = "State: " + state
	return state

var goal

func get_goap_current_goal():
	return goal

func check_goal_finish(current_state, current_goal):
	var regex = RegEx.new()
	regex.compile("!?[\\w\\d_]+")
	var state = []
	var goal = []
	for m in regex.search_all(current_state):
		var n = m.get_string()
		state.append(n)
	for m in regex.search_all(current_goal):
		var n = m.get_string()
		goal.append(n)
	print(goal)
	print(state)
	for i in goal:
		if not (i in state):
			return false 
		else:
			return true
	
func goap():
	var start_time = OS.get_unix_time()
	var count = 0
	var action_planner = get_node("GOAPActionPlanner")
	if action_planner == null:
		return
	while true:
		count += 1
		print("%d: Planning (%d)..." % [ OS.get_unix_time() - start_time, count ])
		var current_state = get_goap_current_state()
		var current_goal = get_goap_current_goal()
		if check_goal_finish(current_state, current_goal):
			actionqueue.text = "We finished the goal"
			return
			
		var plan : Array = action_planner.plan(current_state, current_goal)
		actionqueue.text = "Ai action queue: " + PoolStringArray(plan).join(", ")
		# execute plan
		print("actionqueue is: ", PoolStringArray(plan).join(", "))
		for a in plan:
			var error = false
			# Actions are implemented as methods
			# - immediate actions return a boolean status
			# - non immediate actions (that call yield) return a GDScriptFunctionState
			if has_method(a):
				print("Calling action function "+a)
				var status = call(a)
				if status is GDScriptFunctionState:
					status = yield(status, "completed")
				if typeof(status) != TYPE_BOOL:
					print("Return value of "+a+" is not a boolean")
					status = false
				error = !status
			else:
				print("Cannot perform action "+a)
				error = true
			if error: 
				notificationshow()
				break
			$Timer.start()
			yield($Timer, "timeout")
		$Timer.start()
		yield($Timer, "timeout")




func notificationshow():
	notification.text = "plan invalid (In this game plan become invalid due to 'path block' or 'failure of action'). Therefore, we re-observe the world and re-plan. Re-observation and re-plan is the key that allows us to dynamically control the AI"
	yield(get_tree().create_timer(5.0), "timeout")
	notification.text = ""


func _on_Goal1_pressed() -> void: # goal is just get weapon
	goal = "has_sword"
	goap()

func _on_Goal2_pressed() -> void: # goal is to eat apple when injured 
	_hp = 1
	goal = "!injured"
	goap()
	
func _on_Goal3_pressed() -> void: # goal is to attack 
	goal = "player_die !injured"
	goap()

func _on_Goal4_pressed() -> void: # goal is to attack indoor player 
	player.position.x = 100
	goal = "player_die !injured"
	goap()
