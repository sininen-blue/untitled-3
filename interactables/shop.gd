extends Node3D

var player : Node3D = null

@onready var text_box: Label3D = $TextBox

func _process(_delta: float) -> void:
	if player:
		# TODO: wrapping issue
		var direction : Vector3 = text_box.global_position.direction_to(player.global_position)
		var angle : float = atan2(direction.x, direction.z)
		angle = wrapf(angle + 0.1, -PI, PI)
		text_box.rotation.y = angle



func _on_player_detect_body_entered(body: Node3D) -> void:
	text_box.visible = true
	player = body

func _on_player_detect_body_exited(_body: Node3D) -> void:
	text_box.visible = false
	player = null
