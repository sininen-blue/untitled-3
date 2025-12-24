extends Node3D


@onready var in_location: Node3D = $InLocation
@onready var out_location: Node3D = $OutLocation


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.can_hide = true
		body.hide_location = in_location.global_position
		body.out_location = out_location.global_position


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		body.can_hide = false
		body.hide_location = Vector3.ZERO
		body.out_location = Vector3.ZERO
