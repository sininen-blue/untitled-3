extends Node3D

@export var hide_prompt: PackedScene
@export var stop_prompt: PackedScene

var player: CharacterBody3D
var hide_prompt_instance: Control
var stop_prompt_instance: Control

@onready var in_location: Node3D = $InLocation
@onready var out_location: Node3D = $OutLocation


func _ready() -> void:
	hide_prompt_instance = hide_prompt.instantiate()
	stop_prompt_instance = stop_prompt.instantiate()


func _process(_delta: float) -> void:
	if player:
		if player.is_hidden:
			hide_prompt_instance.visible = false
			stop_prompt_instance.visible = false
		else:
			if player.state_machine.current_state.name.to_lower() == "idlestate":
				hide_prompt_instance.visible = true
				stop_prompt_instance.visible = false
			else:
				hide_prompt_instance.visible = false
				stop_prompt_instance.visible = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player = body
		body.can_hide = true
		body.hide_location = in_location.global_position
		body.out_location = out_location.global_position
		body.center.add_child(hide_prompt_instance)
		body.center.add_child(stop_prompt_instance)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player = null
		body.can_hide = false
		body.hide_location = Vector3.ZERO
		body.out_location = Vector3.ZERO
		body.center.remove_child(hide_prompt_instance)
		body.center.remove_child(stop_prompt_instance)
