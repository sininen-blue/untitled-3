extends Control

const ITEM: PackedScene = preload("res://ui/shop/item.tscn")

@export var inventory: Array[String] = ["change", "this"]

var selected_item_index: int:
	get:
		return selected_item_index
	set(value):
		for index in range(len(inventory)):
			var child: Label = shop_items.get_child(index)
			child.text = inventory[index]
			if value == index:
				child.text = "> " + child.text

@onready var shop_items: VBoxContainer = $ShopItems


func _ready() -> void:
	for index in range(len(inventory)):
		var item_instance: Label = ITEM.instantiate()
		item_instance.text = inventory[index]
		if selected_item_index == index:
			item_instance.text = "> " + item_instance.text
		shop_items.add_child(item_instance)
