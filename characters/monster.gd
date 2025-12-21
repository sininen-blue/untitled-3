extends CharacterBody3D

@export var target : CharacterBody3D
@export var jog_speed : float = 4.0
@export var run_speed : float = 7.0
@export var walk_speed : float = 2.0
@export var intensity : float = 100.0
@export var intensity_gain : float = 5.0

@export var run_distance_threshold : float = 10.0
@export var jog_threshold : float = 50.0

@export var mode_switch_min_time : float = 10.0
@export var mode_switch_max_time : float = 15.0

enum State {WALK, LURK, JOG, RUN}
var current_state : int = State.WALK

var current_intensity : float = 0
var current_speed : float = 0


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mode_switch_timer: Timer = $ModeSwitchTimer


func _ready() -> void:
	mode_switch_timer.wait_time = mode_switch_min_time


func _physics_process(delta: float) -> void:
	if not target:
		return
	
	current_intensity += intensity_gain * delta
	
	var distance : float = nav_agent.distance_to_target()
	match current_state:
		State.WALK:
			current_speed = walk_speed
			
			if distance < run_distance_threshold:
				current_state = State.RUN
			if intensity > jog_threshold:
				current_state = State.JOG
		State.LURK:
			# no sound
			if distance < run_distance_threshold:
				current_state = State.RUN
		State.JOG:
			current_speed = jog_speed
			
			if distance < run_distance_threshold:
				current_state = State.RUN
		State.RUN:
			current_speed = run_speed
			
			if distance > run_distance_threshold and intensity < jog_threshold:
				current_state = State.WALK
			if distance > run_distance_threshold and intensity > jog_threshold:
				current_state = State.JOG
	
	
	
	$Label3D.text = str(current_intensity) + "    " + str(distance) + "\n" + State.keys()[current_state]
	
	
	var target_pos : Vector3 = target.global_position
	nav_agent.target_position = target_pos
	var next_path_pos : Vector3 = nav_agent.get_next_path_position()
	var direction : Vector3 = global_position.direction_to(next_path_pos)
	velocity = direction * current_speed
		
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		
	move_and_slide()


func _on_mode_switch_timer_timeout() -> void:
	if current_state == State.RUN:
		return
	
	var time : float = randf_range(mode_switch_min_time, mode_switch_max_time)
	if current_state == State.LURK:
		mode_switch_timer.start(time)
		
		if intensity > jog_threshold:
			current_state = State.JOG
		else:
			current_state = State.WALK
	else:
		current_state = State.LURK
		mode_switch_timer.start(time)
