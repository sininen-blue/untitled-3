extends State

@export var stamina_drain: float = 1.0
@export var heart_beat_time: float = 3.0

var player: CharacterBody3D = null

@onready var hide_regen_timer: Timer = $"../../HideRegenTimer"
@onready var hide_breath_in_sound: AudioStreamPlayer3D = $"../../Sounds/HideBreathInSound"
@onready var hide_breath_out_sound: AudioStreamPlayer3D = $"../../Sounds/HideBreathOutSound"
@onready var heart_beat_timer: Timer = $"../../SoundTimers/HeartBeatTimer"
@onready var heart_beat_sound: AudioStreamPlayer3D = $"../../Sounds/HeartBeatSound"


func enter() -> void:
	hide_breath_in_sound.play()
	player = state_machine.get_parent()
	player.is_hidden = true
	player.global_position = player.hide_location

	heart_beat_sound.play()
	heart_beat_timer.start(heart_beat_time)


func exit() -> void:
	# TEMP fix for player hide stamina
	if player.hide_stamina < 10:
		player.hide_stamina = 10

	hide_breath_out_sound.play()
	player.is_hidden = false
	player.global_position = player.out_location
	hide_regen_timer.start()

	heart_beat_timer.stop()


func update(delta: float) -> void:
	player.hide_stamina -= stamina_drain * delta

	heart_beat_time = 0.4 + player.hide_stamina_normalized * (3.0 - 0.4)

	if player.direction != Vector3.ZERO:
		state_machine.change_state("walkstate")
	if player.hide_stamina <= 0:
		state_machine.change_state("idlestate")


func physics_update(_delta: float) -> void:
	pass


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_hide"):
		state_machine.change_state("idlestate")


func _on_heart_beat_timer_timeout() -> void:
	heart_beat_timer.start(heart_beat_time)
