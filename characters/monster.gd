extends CharacterBody3D

@export var target : CharacterBody3D
@export var speed : float = 10.0


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D


func _physics_process(delta: float) -> void:
	var target_pos : Vector3 = target.global_position
	if target:
		nav_agent.target_position = target_pos
		var next_path_pos : Vector3 = nav_agent.get_next_path_position()
		var direction : Vector3 = global_position.direction_to(next_path_pos)
		velocity = direction * speed
		
		if nav_agent.is_navigation_finished():
			velocity = Vector3.ZERO
		
	move_and_slide()
