extends CharacterBody3D

@export_category("Camera")
@export var sensitivity : float = 0.1

@export_category("Stamina")
@export var max_stamina : float = 5.0
@export var stamina_drain : float = 1.0
@export var stamina_drain_jump : float = 1.0
@export var stamina_regen_walk : float = 0.5
@export var stamina_regen_idle : float = 2.0
@export var stamina_regen_delay : float = 1.0

@export_category("Speed")
@export var accel : float = 0.4
@export var run_accel : float = 0.1
@export var decel : float = 0.4
@export var speed : float = 4.0
@export var run_speed : float = 11.0
@export var air_turn : float = 0.05
@export var ground_turn : float = 0.8

@export_category("Jump")
@export var jump : float = 8.0
@export var mass : float = 3.0

@export_category("Hide")
@export var hide_duration: float = 15.0

enum State {IDLE, WALK, RUN, JUMP, HIDE}
var previous_state : int = State.IDLE
var current_state : int = State.IDLE

var previous_direction : Vector3 = Vector3.ZERO
var direction : Vector3 = Vector3.ZERO
var current_stamina : float = max_stamina
var current_speed : float = 0

var hide_stamina: float = hide_duration
var is_hidden: bool = false
var can_hide: bool = false
var hide_location: Vector3 = Vector3.ZERO
var out_location: Vector3 = Vector3.ZERO

var inventory : Array[String] = []
var requirements : Array[String] = []

@onready var head: Node3D = $Head
@onready var stamina_regen_timer: Timer = $StaminaRegenTimer
@onready var hide_regen_timer: Timer = $HideRegenTimer
@onready var debug_label: Label = $Hud/Control/DebugLabel

@onready var ui_ray_cast: RayCast3D = $Head/UIRayCast
@onready var buy_prompt: Control = $Hud/Control/Center/BuyPrompt


func _ready() -> void:
	current_stamina = max_stamina
	stamina_regen_timer.wait_time = stamina_regen_delay


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * sensitivity
		head.rotation_degrees.x -= event.relative.y * sensitivity
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -80, 80)
	
	
	if event.is_action_pressed("debug_reset"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("mouse_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta: float) -> void:
	if ui_ray_cast.is_colliding():
		buy_prompt.visible = true
	else:
		buy_prompt.visible = false


func _physics_process(delta: float) -> void:
	debug_label.text = State.keys()[current_state] + str(can_hide) + str(is_hidden)
	
	if not is_on_floor():
		velocity += get_gravity() * delta * mass
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var target_direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if !is_on_floor():
		direction = direction.move_toward(target_direction, air_turn)
	else:
		direction = direction.move_toward(target_direction, ground_turn)
		
	if direction != Vector3.ZERO:
		previous_direction = direction
	
	current_stamina = clamp(current_stamina, 0, max_stamina)
	
	
	match current_state:
		State.IDLE:
			previous_state = current_state
			
			if stamina_regen_timer.is_stopped():
				current_stamina += stamina_regen_idle * delta
			if hide_regen_timer.is_stopped():
				hide_stamina += 1 * delta
			
			current_speed = move_toward(current_speed, 0, decel)
			if current_speed != 0:
				velocity.x = previous_direction.x * current_speed
				velocity.z = previous_direction.z * current_speed
			
			if input_dir != Vector2.ZERO:
				current_state = State.WALK
			if Input.is_action_just_pressed("move_jump") and is_on_floor() and current_stamina > 1.0:
				stamina_regen_timer.start()
				current_state = State.JUMP
			if Input.is_action_just_pressed("move_hide") and hide_stamina > 1.0 and can_hide:
				is_hidden = true
				
				if hide_location != Vector3.ZERO:
					global_position = hide_location
				current_state = State.HIDE
		State.WALK:
			previous_state = current_state
			
			if stamina_regen_timer.is_stopped():
				current_stamina += stamina_regen_walk * delta
			if hide_regen_timer.is_stopped():
				hide_stamina += 1 * delta
			
			current_speed = move_toward(current_speed, speed, accel)
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
			
			if input_dir == Vector2.ZERO:
				current_state = State.IDLE
			if Input.is_action_just_pressed("move_run"):
				current_state = State.RUN
			if Input.is_action_just_pressed("move_jump") and is_on_floor() and current_stamina > 1.0:
				stamina_regen_timer.start()
				current_state = State.JUMP
		State.RUN:
			previous_state = current_state
			
			current_speed = move_toward(current_speed, run_speed, run_accel)
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
			
			current_stamina -= stamina_drain * delta
			
			if current_stamina <= 0:
				stamina_regen_timer.start()
				current_state = State.WALK
			if Input.is_action_just_released("move_run"):
				current_state = State.WALK
			if input_dir == Vector2.ZERO:
				current_state = State.IDLE
			if Input.is_action_just_pressed("move_jump") and is_on_floor() and current_stamina > 1.0:
				stamina_regen_timer.start()
				current_state = State.JUMP
		State.JUMP:
			if previous_state != State.JUMP:
				current_stamina -= stamina_drain_jump
				velocity.y = jump
			
			if is_on_floor():
				current_state = previous_state
			
			previous_state = current_state
		State.HIDE:
			hide_stamina -= 1 * delta
			hide_stamina = clampf(hide_stamina, 0, hide_duration)
			
			current_speed = move_toward(current_speed, 0, decel)
			if current_speed != 0:
				velocity.x = previous_direction.x * current_speed
				velocity.z = previous_direction.z * current_speed
			
			if Input.is_action_just_pressed("move_hide"):
				hide_regen_timer.start()
				is_hidden = false
				if out_location != Vector3.ZERO:
					global_position = out_location
				current_state = State.IDLE
			if hide_stamina <= 0:
				hide_regen_timer.start()
				is_hidden = false
				if out_location != Vector3.ZERO:
					global_position = out_location
				current_state = State.IDLE
			if direction != Vector3.ZERO:
				hide_regen_timer.start()
				is_hidden = false
				if out_location != Vector3.ZERO:
					global_position = out_location
				current_state = State.WALK
	
	move_and_slide()
