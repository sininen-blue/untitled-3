extends Node3D

@export var dialogue: Array[String] = ["I forgot to buy something", "Can you go out and buy some from tita"]
@export var requirements: Array[String] = ["box", "circle"]

var player: Node3D = null
var dialogue_box: Label = null
var dialogue_index: int = 0
var letter_index: int = 0
var selected_item_index: int = 0
var is_talking: bool = false

var first_enter: bool = true

@onready var letter_delay: Timer = $LetterDelay
@onready var dialogue_delay: Timer = $DialogueDelay


func _ready() -> void:
	dialogue.append("I'll need you to buy")
	for i in range(len(requirements)):
		if i == len(requirements) - 1:
			dialogue.append("And a " + requirements[i])
		else:
			dialogue.append("A " + requirements[i])


func _on_entrance_area_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	player = body
	dialogue_box = player.dialogue
	dialogue_box.text = ""
	is_talking = true
	dialogue_index = 0
	letter_index = 0
	selected_item_index = 0
	letter_delay.start()

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
	dialogue_box.text = ""
	dialogue_box = null
	is_talking = false
	dialogue_index = 0
	letter_index = 0
	selected_item_index = 0
	letter_delay.stop()


func _on_dialogue_delay_timeout() -> void:
	dialogue_box.text = ""
	dialogue_index += 1
	letter_index = 0


func _on_letter_delay_timeout() -> void:
	if dialogue_delay.is_stopped() == false:
		return

	if dialogue_index == len(dialogue):
		# set inventory here
		return

	if letter_index < len(dialogue[dialogue_index]):
		dialogue_box.text = dialogue_box.text + dialogue[dialogue_index][letter_index]
		letter_index += 1
	elif letter_index == len(dialogue[dialogue_index]):
		dialogue_delay.start()
