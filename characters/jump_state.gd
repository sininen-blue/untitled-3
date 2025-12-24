extends State

@export var jump: float = 10.0
@export var stamina_cost: float = 2.0
@export var landing_cost: float = 5.0
@export var friction: float = 0.01
@export var control_strength: float = 0.05

var player: CharacterBody3D = null

@onready var stamina_regen_timer: Timer = $"../../StaminaRegenTimer"
@onready var hide_regen_timer: Timer = $"../../HideRegenTimer"
@onready var floor_cast: RayCast3D = $"../../FloorCast"

@onready var jump_offset_timer: Timer = $JumpOffsetTimer


func enter() -> void:
	floor_cast.enabled = false
	jump_offset_timer.start()

	player = state_machine.get_parent()
	player.stamina -= stamina_cost
	player.velocity.y += jump


func exit() -> void:
	player.current_speed = clamp(player.current_speed - landing_cost, 0, 10)


func update(_delta: float) -> void:
	if player.is_grounded:
		state_machine.change_state("walkstate")


func physics_update(_delta: float) -> void:
	player.current_speed = move_toward(player.current_speed, 0, friction)

	player.velocity.x = move_toward(player.velocity.x, player.direction.x * player.current_speed, control_strength)
	player.velocity.z = move_toward(player.velocity.z, player.direction.z * player.current_speed, control_strength)

	player.move_and_slide()


func handle_input(_event: InputEvent) -> void:
	pass


func _on_jump_offset_timer_timeout() -> void:
	floor_cast.enabled = true
