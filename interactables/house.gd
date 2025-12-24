extends Node3D

@export var requirements: Array[String] = ["box", "circle"]

var player: Node3D = null


func _on_entrance_area_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	player = body

	if player.requirements.is_empty():
		player.requirements = requirements
		return

	# NOTE: make sure this is forgiving, extra items, etc, maybe money req to make it possible
	# to fail the level
	if player.inventory == requirements:
		print("Level complete")


func _on_entrance_area_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return
	player = null
