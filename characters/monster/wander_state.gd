extends State

@export var speed: float = 20.0
@export var offset: float = 150
@export var step_size : float = 50

var monster: Node3D = null

@onready var wander_refresh_timer: Timer = $WanderRefreshTimer


func enter() -> void:
	randomize()
	print("entering wander")
	
	monster = state_machine.get_parent()
	monster.target = get_new_path_target()
	wander_refresh_timer.start()


func exit() -> void:
	wander_refresh_timer.stop()
	print("exiting wander")


func physics_update(_delta: float) -> void:
	if not monster.player:
		return
	
	# NOTE: instead of using direction
	# I would get the current target location
	# pick a random point, x, z, around that target, so I only target somewhere around the player
	# then check if that's reachable, if not, then I pick another one * 1000
	# once I get a point, move towards there, with a timer that  refreshes it every so often
	
	
	monster.velocity = monster.direction * speed
	monster.move_and_slide()
	
	if monster.nav_agent.is_navigation_finished():
		wander_refresh_timer.stop()
		wander_refresh_timer.start()
		monster.target = get_new_path_target()
	
	# if player not hiding and within distance, go to previous state
	# or lurk
	#if monster.distance < monster.distance_threshold:
		#state_machine.change_state("runstate")
	#if monster.intensity > monster.intensity_threshold:
		#state_machine.change_state("jogstate")


func get_new_path_target() -> Vector3:
	var current_target: Vector3 = monster.player.global_position
	var potential_target_list: Array[Vector3] = []
	var potential_target: Vector3 = Vector3()
	for row in range(-offset, offset, step_size):
		for col in range(-offset, offset, step_size):
			potential_target = Vector3(
				current_target.x + float(row)/10,
				current_target.y,
				current_target.z + float(col)/10
			)
			
			potential_target_list.append(potential_target)
	
	# NOTE: debug
	var children := get_children()
	for child in children:
		if child is Node3D:
			child.call_deferred("queue_free")
	const BOX := preload("res://resources/debug_marker.tscn")
	for point in potential_target_list:
		var new_marker := BOX.instantiate()
		add_child(new_marker)
		
		new_marker.global_position = point
	
	return potential_target_list.pick_random()


func _on_wander_refresh_timer_timeout() -> void:
	monster.target = get_new_path_target()
	wander_refresh_timer.start()
