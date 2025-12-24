extends CharacterBody3D

@export_category("Camera")
@export var sensitivity: float = 0.1
@export var view_bobbing: bool = true

@export_category("Stamina")
@export var max_stamina: float = 5.0
@export var jump_threshold: float = 1.0

@export_category("Properties")
@export var debug: bool = true
@export var mass: float = 3.0

@export_category("Hide")
@export var max_hide_stamina: float = 15.0

enum State { IDLE, WALK, RUN, JUMP, HIDE }
var previous_state: int = State.IDLE
var current_state: int = State.IDLE

var input_dir: Vector2 = Vector2.ZERO
var prev_dir: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO

var stamina: float = max_stamina
var proxy_stamina: float = max_stamina
var stamina_normalized: float = 1.0
var current_speed: float = 0

var hide_stamina: float = max_hide_stamina
var is_hidden: bool = false
var can_hide: bool = false
var hide_location: Vector3 = Vector3.ZERO
var out_location: Vector3 = Vector3.ZERO

var is_grounded: bool = true

var inventory: Array[String] = []
var requirements: Array[String] = []

var debug_info: Dictionary = { }

@onready var head: Node3D = $Head
@onready var debug_label: Label = $Hud/Control/DebugLabel

@onready var ui_ray_cast: RayCast3D = $Head/UIRayCast
@onready var buy_prompt: Control = $Hud/Control/Center/BuyPrompt

@onready var floor_cast: RayCast3D = $FloorCast

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var retro: ColorRect = $Hud/Control/Retro


func _ready() -> void:
	stamina = max_stamina


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
	proxy_stamina = move_toward(proxy_stamina, stamina, 0.002)
	stamina_normalized = (proxy_stamina - 0) / (max_stamina - 0)

	var inner_radius: float = 0.0 + stamina_normalized * (1.2 - 0.0)
	var outer_radius: float = 0.7 + stamina_normalized * (1.5 - 0.7)
	var darkness: float = 1.0 + stamina_normalized * (0.2 - 1.0)
	var chroma: float = 0.01 + stamina_normalized * (0.0 - 0.01)
	var warble: float = 0.002 + stamina_normalized * (0.0001 - 0.002)

	retro.material.set("shader_parameter/vignette_inner_radius", inner_radius)
	retro.material.set("shader_parameter/vignette_outer_radius", outer_radius)
	retro.material.set("shader_parameter/vignett_darkness", darkness)
	retro.material.set("shader_parameter/chromatic_aberration", chroma)
	retro.material.set("shader_parameter/warble_amount", warble)

	if debug:
		debug_info = {
			"inner_radius": inner_radius,
			"outer_radius": outer_radius,
			"darkness": darkness,
			"chroma": chroma,
			"current_state": $StateMachine.current_state.name,
			"current_speed": current_speed,
			"stamina": stamina,
			"proxy_stamina": proxy_stamina,
			"stamina_normalized": stamina_normalized,
			"hide_stamina": hide_stamina,
			"can_hide": can_hide,
			"is_hidden": is_hidden,
			"is_grounded": is_grounded,
		}
		var debug_text: String = ""
		for key in debug_info.keys():
			debug_text += key + ": " + str(debug_info[key]) + "\n"
		debug_label.text = debug_text

	is_grounded = floor_cast.is_colliding()
	stamina = clamp(stamina, 0, max_stamina)
	hide_stamina = clamp(hide_stamina, 0, max_hide_stamina)

	if ui_ray_cast.is_colliding():
		buy_prompt.visible = true
	else:
		buy_prompt.visible = false


func _physics_process(delta: float) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if input_dir != Vector2.ZERO:
		prev_dir = direction

	if is_grounded == false:
		velocity += get_gravity() * delta * mass
