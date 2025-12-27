extends State

@export var friction: float = 0.4
@export var stamina_regen: float = 1.0
@export var hide_regen: float = 1.0

@export var breath_time: float = 9.0

var player: CharacterBody3D = null

@onready var stamina_regen_timer: Timer = $"../../StaminaRegenTimer"
@onready var hide_regen_timer: Timer = $"../../HideRegenTimer"
@onready var floor_cast: RayCast3D = $"../../FloorCast"
@onready var breath_timer: Timer = $"../../SoundTimers/BreathTimer"


func enter() -> void:
	breath_timer.start(breath_time)
	player = state_machine.get_parent()


func exit() -> void:
	breath_timer.stop()


func update(delta: float) -> void:
	if stamina_regen_timer.is_stopped():
		player.stamina += stamina_regen * delta
	if hide_regen_timer.is_stopped():
		player.hide_stamina += hide_regen * delta

	if player.direction != Vector3.ZERO:
		state_machine.change_state("walkstate")


func physics_update(_delta: float) -> void:
	player.current_speed = move_toward(player.current_speed, 0, friction)

	player.velocity.x = player.prev_dir.x * player.current_speed
	player.velocity.z = player.prev_dir.z * player.current_speed

	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump") and player.stamina > player.jump_threshold:
		state_machine.change_state("jumpstate")
	if event.is_action_pressed("move_hide") and player.can_hide:
		state_machine.change_state("hidestate")
