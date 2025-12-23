extends State

@export var speed: float = 5.0
@export var offset: float = 150
@export var detection_threshold: float = 8.0

@export var idle_min: float = 1.0
@export var idle_max: float = 3.0
@export var step_size : float = 50

@export var exit_length: float = 2.0

@export var debug: bool = false

var monster: Node3D = null
var first_reach: bool = true

@onready var wander_refresh_timer: Timer = $WanderRefreshTimer
@onready var wander_idle_timer: Timer = $WanderIdleTimer
@onready var wander_exit_timer: Timer = $WanderExitTimer


func enter() -> void:
	first_reach = true
	randomize()
	print("entering wander")
	
	monster = state_machine.get_parent()
	## NOTE: needs to change destination reach on enter to just be close
	monster.target = monster.player.global_position
	wander_refresh_timer.start()
	
	monster.nav_agent.target_desired_distance = 5.0


func exit() -> void:
	monster.nav_agent.target_desired_distance = 1.0
	wander_refresh_timer.stop()
	print("exiting wander")


func physics_update(_delta: float) -> void:
	if not monster.player:
		return
	
	monster.velocity = monster.direction * speed
	monster.move_and_slide()
	
	if monster.nav_agent.is_navigation_finished() and wander_idle_timer.is_stopped():
		print("reached")
		if first_reach:
			print("first")
			first_reach = false
			## BUG: jitters like crazy, could just be effect
			monster.target = monster.global_position
			
			wander_idle_timer.start(randf_range(idle_min, idle_max))
		
		wander_idle_timer.start(randf_range(idle_min, idle_max))
		
		wander_refresh_timer.stop()
		wander_refresh_timer.start()
	
	if monster.player.is_hidden == false:
		if monster.distance < detection_threshold:
			state_machine.change_state("walkstate")
		elif monster.distance > detection_threshold:
			wander_exit_timer.start(exit_length)
		
		if monster.distance < monster.distance_threshold:
			state_machine.change_state("runstate")


func get_new_path_target() -> Vector3:
	## TODO: change this to not generate close targets
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
	
	if debug:
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


func _on_wander_idle_timer_timeout() -> void:
	monster.target = get_new_path_target()


func _on_wander_exit_timer_timeout() -> void:
	state_machine.change_state("walkstate")
