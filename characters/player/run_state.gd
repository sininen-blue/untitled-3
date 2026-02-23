extends State

@export var speed: float = 10.0
@export var accel: float = 0.2

@export var footstep_time: float = 0.3
@export var breath_time: float = 3.14

@export var stamina_drain: float = 1.0

var player: CharacterBody3D = null

@onready var stamina_regen_timer: Timer = $"../../StaminaRegenTimer"
@onready var camera: Camera3D = $"../../Head/Camera3D"
@onready var footstep_sound: AudioStreamPlayer3D = $"../../Sounds/FootstepSound"
@onready var footstep_timer: Timer = $"../../SoundTimers/FootstepTimer"
@onready var breath_heavy_sound: AudioStreamPlayer3D = $"../../Sounds/BreathHeavySound"
@onready var breath_heavy_timer: Timer = $"../../SoundTimers/BreathHeavyTimer"


func enter() -> void:
	player = state_machine.get_parent()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", player.fov + 10, 0.2)
	tween.set_ease(Tween.EASE_IN)

	footstep_sound.play()
	footstep_timer.start(footstep_time)
	breath_heavy_sound.play()
	breath_heavy_timer.start(breath_time)


func exit() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", player.fov - 10, 0.2)
	tween.set_ease(Tween.EASE_OUT)
	stamina_regen_timer.start()

	var sound_tween: Tween = get_tree().create_tween()
	sound_tween.set_ease(Tween.EASE_OUT)
	sound_tween.tween_property(breath_heavy_sound, "volume_db", -40, 1)
	sound_tween.tween_property(breath_heavy_sound, "playing", false, 0.1)
	sound_tween.tween_property(breath_heavy_sound, "volume_db", 0, 0.1)

	footstep_timer.stop()
	breath_heavy_timer.stop()


func update(delta: float) -> void:
	player.stamina -= stamina_drain * delta
	if player.input_dir == Vector2.ZERO:
		state_machine.change_state("idlestate")
	if player.stamina <= 0:
		state_machine.change_state(state_machine.previous_state.name.to_lower())


func physics_update(_delta: float) -> void:
	player.current_speed = move_toward(player.current_speed, speed, accel)
	player.velocity.x = player.direction.x * player.current_speed
	player.velocity.z = player.direction.z * player.current_speed

	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("move_run"):
		state_machine.change_state("walkstate")
	if event.is_action_pressed("move_jump") and player.stamina > player.jump_threshold:
		state_machine.change_state("jumpstate")
