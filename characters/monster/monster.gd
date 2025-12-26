extends CharacterBody3D

@export var player: CharacterBody3D
@export var start_area: Area3D

@export var distance_threshold: float = 5.0
@export var intensity_threshold: float = 2.0

@export var intensity_gain: float = 1.0
@export var mode_switch_min_time: float = 5.0
@export var mode_switch_max_time: float = 5.0

# amount of meters for a player needs to be to successfully hide
@export var detection_radius: float = 1.0

var target: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var distance: float = 0.0
var intensity: float = 0.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var footstep_sound: AudioStreamPlayer3D = $FootstepSound
@onready var mode_switch_sound: AudioStreamPlayer3D = $ModeSwitchSound

@onready var start_timer: Timer = $StateMachine/IdleState/StartTimer
@onready var hitbox: Area3D = $Hitbox
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	start_area.connect("body_exited", _on_body_exited)


func _process(_delta: float) -> void:
	if state_machine.current_state.name.to_lower() == "wanderstate":
		hitbox.monitoring = false
	else:
		hitbox.monitoring = true


func _physics_process(delta: float) -> void:
	distance = nav_agent.distance_to_target()
	intensity += intensity_gain * delta

	if state_machine.current_state.name.to_lower() != "wanderstate":
		target = player.global_position

	nav_agent.target_position = target
	var next_path_pos: Vector3 = nav_agent.get_next_path_position()

	direction = global_position.direction_to(next_path_pos)

	if $FootstepTimer.is_stopped():
		if $StateMachine.current_state.name.to_lower() == "lurkstate":
			return
		if $StateMachine.current_state.name.to_lower() == "walkstate":
			$FootstepTimer.start(1.5)
		if $StateMachine.current_state.name.to_lower() == "jogstate":
			$FootstepTimer.start(1.0)
		if $StateMachine.current_state.name.to_lower() == "runstate":
			$FootstepTimer.start(0.5)


func _on_footstep_timer_timeout() -> void:
	footstep_sound.play()


func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		start_timer.start()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.kill()
