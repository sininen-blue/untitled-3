extends Node3D

var player : Node3D = null
var requirements : Array[String] = ["box", "circle"]



func _on_entrance_area_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	player = body
	
	if player.requirements.is_empty():
		player.requirements = requirements
		return
	
	if player.inventory == requirements:
		print("Level complete")

func _on_entrance_area_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return
	player = null
