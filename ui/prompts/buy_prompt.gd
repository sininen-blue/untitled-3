extends Node3D

# TODO: proper billboarding?
# ideally this would show up on the position of where the raycast is hitting

@onready var prompt: Node3D = $Prompt

func show_prompt(hit_location: Vector3) -> void:
	prompt.global_position = hit_location
	self.visible = true
	$FadeTimer.start()

func _on_fade_timer_timeout() -> void:
	self.visible = false
# TODO: tween this shit
