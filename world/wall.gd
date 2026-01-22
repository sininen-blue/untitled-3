extends Node3D

@export var wall: PackedScene
@export var wall_size: float = 5.0

@onready var end_marker: Marker3D = $End


func _ready() -> void:
	var start: Vector3 = self.global_position
	var end: Vector3 = end_marker.global_position

	var wall_count: int = floor(start.distance_to(end) / 5.0)
	for i in range(wall_count):
		var wall_instance: Node3D = wall.instantiate()
		var offset: float = i * wall_size
		var wall_location: Vector3 = Vector3(start.x + offset, start.y, start.z)

		add_child(wall_instance)
		wall_instance.global_position = wall_location
