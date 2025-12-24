extends Node3D

@export var inventory: Array[String] = []

var player: Node3D = null
var selected_item_index: int = 0

@onready var text_pivot: Node3D = $TextPivot
@onready var text_box: Label3D = $TextPivot/TextBox
@onready var item_list: Label3D = $TextPivot/ItemList
@onready var current_item: Label3D = $TextPivot/CurrentItem

@onready var buy_sound: AudioStreamPlayer3D = $BuySound


func _unhandled_input(event: InputEvent) -> void:
	if not player:
		return

	if event.is_action_pressed("ui_up"):
		selected_item_index += 1
		selected_item_index = clamp(selected_item_index, 0, len(inventory) - 1)
	if event.is_action_pressed("ui_down"):
		selected_item_index -= 1
		selected_item_index = clamp(selected_item_index, 0, len(inventory) - 1)

	if event.is_action_pressed("shop_buy"):
		buy_sound.play()
		player.inventory.append(inventory[selected_item_index])


func _process(_delta: float) -> void:
	var temp_inventory_text: String = ""
	for item in inventory:
		temp_inventory_text += item
	item_list.text = temp_inventory_text
	current_item.text = "buy " + inventory[selected_item_index] + "?"

	if player:
		var direction: Vector3 = text_pivot.global_position.direction_to(player.global_position)
		var angle: float = atan2(direction.x, direction.z)
		angle = wrapf(angle + 0.1, -PI, PI)
		text_pivot.rotation.y = angle


func _on_player_detect_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	text_pivot.visible = true
	player = body


func _on_player_detect_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return
	text_pivot.visible = false
	player = null
