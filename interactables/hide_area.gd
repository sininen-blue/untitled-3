extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.can_hide = true
		body.hide_location = self.global_position


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		body.can_hide = false
		body.hide_location = Vector3.ZERO
