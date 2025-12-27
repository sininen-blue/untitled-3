extends Node

@onready var breath_sound: AudioStreamPlayer3D = $BreathSound
@onready var breath_heavy_sound: AudioStreamPlayer3D = $BreathHeavySound
@onready var footstep_sound: AudioStreamPlayer3D = $FootstepSound
@onready var heart_beat_sound: AudioStreamPlayer3D = $HeartBeatSound
@onready var hide_breath_in_sound: AudioStreamPlayer3D = $HideBreathInSound
@onready var hide_breath_out_sound: AudioStreamPlayer3D = $HideBreathOutSound


func _on_footstep_timer_timeout() -> void:
	footstep_sound.play()


func _on_breath_timer_timeout() -> void:
	breath_sound.play()


func _on_breath_heavy_timer_timeout() -> void:
	breath_heavy_sound.play()


func _on_heart_beat_timer_timeout() -> void:
	heart_beat_sound.play()
