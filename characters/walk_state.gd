extends State

@export var speed: float = 5.0
@export var accel: float = 0.2

@export var stamina_regen: float = 0.5
@export var hide_regen: float = 1.0

var player: CharacterBody3D = null

@onready var stamina_regen_timer: Timer = $"../../StaminaRegenTimer"
@onready var hide_regen_timer: Timer = $"../../HideRegenTimer"


func enter() -> void:
	print("player IN walk")
	player = state_machine.get_parent()


func exit() -> void:
	print("player OUT walk")


func update(delta: float) -> void:
	if stamina_regen_timer.is_stopped():
		player.stamina += stamina_regen * delta
	if hide_regen_timer.is_stopped():
		player.hide_stamina += hide_regen * delta
		
	if player.input_dir == Vector2.ZERO:
		state_machine.change_state("idlestate")


func physics_update(_delta: float) -> void:
	player.current_speed = move_toward(player.current_speed, speed, accel)
	player.velocity.x = player.direction.x * player.current_speed
	player.velocity.z = player.direction.z * player.current_speed
	
	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_run"):
		state_machine.change_state("runstate")
	if event.is_action_pressed("move_jump") and player.stamina > player.jump_threshold:
		state_machine.change_state("jumpstate")
