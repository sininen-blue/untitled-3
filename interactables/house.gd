extends Node3D

@export var dialogue: Dictionary = {
	"start": ["I forgot to buy something", "Can you go out and buy some from tita"],
	"return": ["Remember, what you need to buy is"],
	"finish": ["Thank you for buying everything"],
}
@export var selected_dialogue: String = "start"
@export var requirements: Dictionary = { "box": 0, "circle": 0 }

var player: Node3D = null
var dialogue_box: Label = null
var dialogue_index: int = 0
var letter_index: int = 0
var selected_item_index: int = 0
var is_talking: bool = false

var first_enter: bool = true

@onready var letter_delay: Timer = $LetterDelay
@onready var dialogue_delay: Timer = $DialogueDelay

@onready var door: CSGBox3D = $Door


func _ready() -> void:
	dialogue["start"].append("I'll need you to buy")
	for i in range(len(requirements.keys())):
		if i == len(requirements.keys()) - 1:
			dialogue["start"].append("And a " + requirements.keys()[i])
		else:
			dialogue["start"].append("A " + requirements.keys()[i])

	for i in range(len(requirements)):
		if i == len(requirements) - 1:
			dialogue["return"].append("And a " + requirements.keys()[i])
		else:
			dialogue["return"].append("A " + requirements.keys()[i])


func _on_entrance_area_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	player = body
	player.in_house = true
	dialogue_box = player.dialogue
	dialogue_box.text = ""
	is_talking = true
	dialogue_index = 0
	letter_index = 0
	selected_item_index = 0
	letter_delay.start()

	if first_enter == false:
		selected_dialogue = "return"

	first_enter = false
	if player.requirements.is_empty():
		player.requirements = requirements.keys()
		return

	# NOTE: make sure this is forgiving, extra items, etc, maybe money req to make it possible
	# to fail the level
	# temp, extra items are fine
	for submit: String in player.inventory:
		if requirements.has(submit):
			requirements[submit] += 1

	var finish: bool = true
	for keys: String in requirements.keys():
		if requirements[keys] == 0:
			finish = false

	if finish:
		player.global_position = Vector3(100, 100, 100)


func _on_entrance_area_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return
	player.in_house = false
	player = null
	dialogue_box.text = ""
	dialogue_box = null
	is_talking = false
	dialogue_index = 0
	letter_index = 0
	selected_item_index = 0
	letter_delay.stop()
	dialogue_delay.stop()


func _on_letter_delay_timeout() -> void:
	if dialogue_delay.is_stopped() == false:
		return

	if dialogue_index == len(dialogue[selected_dialogue]):
		door.visible = false
		door.use_collision = false
		return

	if letter_index < len(dialogue[selected_dialogue][dialogue_index]):
		dialogue_box.text = dialogue_box.text + dialogue[selected_dialogue][dialogue_index][letter_index]
		letter_index += 1
	elif letter_index == len(dialogue[selected_dialogue][dialogue_index]):
		dialogue_delay.start()


func _on_dialogue_delay_timeout() -> void:
	dialogue_box.text = ""
	dialogue_index += 1
	letter_index = 0
