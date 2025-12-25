extends Node3D

@export var dialogue: Array[String] = ["You want to buy something", "Here's what I got"]
@export var inventory: Array[String] = []

var player: Node3D = null
var dialogue_box: Label = null
var dialogue_index: int = 0
var letter_index: int = 0
var selected_item_index: int = 0

var is_talking: bool = false
var can_buy: bool = false

@onready var buy_sound: AudioStreamPlayer3D = $BuySound
@onready var letter_delay: Timer = $LetterDelay
@onready var dialogue_delay: Timer = $DialogueDelay


func _unhandled_input(event: InputEvent) -> void:
	if not player:
		return
	if not can_buy:
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
	pass


func _on_player_detect_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	player = body
	dialogue_box = player.dialogue
	dialogue_box.text = ""
	is_talking = true
	can_buy = false
	dialogue_index = 0
	letter_index = 0
	selected_item_index = 0
	letter_delay.start()


func _on_player_detect_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return
	player = null
	dialogue_box.text = ""
	dialogue_box = null
	is_talking = false
	can_buy = false
	dialogue_index = 0
	letter_index = 0
	selected_item_index = 0
	letter_delay.stop()


func _on_letter_delay_timeout() -> void:
	if dialogue_delay.is_stopped() == false:
		return

	if dialogue_index == len(dialogue):
		can_buy = true
		dialogue_box.text = str(inventory)
		return

	if letter_index < len(dialogue[dialogue_index]):
		dialogue_box.text = dialogue_box.text + dialogue[dialogue_index][letter_index]
		letter_index += 1
	elif letter_index == len(dialogue[dialogue_index]):
		dialogue_delay.start()


func _on_dialogue_delay_timeout() -> void:
	dialogue_box.text = ""
	dialogue_index += 1
	letter_index = 0
