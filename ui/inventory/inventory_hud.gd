class_name InventoryHUD extends Control

const INVENTORY_SLOT_SCENE := preload("res://ui/inventory/inventory_slot.tscn")
const PLACEHOLDER_ICON := preload("res://godot.svg")

@onready var equipment_slots: HBoxContainer = %EquipmentSlots
@onready var storage_slots: HBoxContainer = %StorageSlots

var inventory := Inventory.new()

func _ready() -> void:
	visible = false
	_build_slots()
	_populate_starting_items()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_toggle"):
		visible = not visible
		get_viewport().set_input_as_handled()

func _build_slots() -> void:
	_add_slot(equipment_slots, Inventory.ARMOR_SLOT, "Armor")
	_add_slot(equipment_slots, Inventory.SHIELD_SLOT, "Shield")
	_add_slot(equipment_slots, Inventory.MAIN_WEAPON_SLOT, "Main Weapon")

	for index in range(Inventory.STORAGE_SLOT_COUNT):
		_add_slot(storage_slots, inventory.get_storage_slot_id(index), "Storage %d" % (index + 1))

func _populate_starting_items() -> void:
	var axe := InventoryItem.new()
	axe.display_name = "Axe"
	axe.icon = PLACEHOLDER_ICON
	axe.item_type = InventoryItem.ItemType.MAIN_WEAPON

	var shield := InventoryItem.new()
	shield.display_name = "Shield"
	shield.icon = PLACEHOLDER_ICON
	shield.item_type = InventoryItem.ItemType.SHIELD

	inventory.set_slot_item(inventory.get_storage_slot_id(0), axe)
	inventory.set_slot_item(inventory.get_storage_slot_id(1), shield)

func _add_slot(parent: BoxContainer, slot_id: StringName, label_text: String) -> void:
	var wrapper := VBoxContainer.new()
	wrapper.alignment = BoxContainer.ALIGNMENT_CENTER
	wrapper.add_theme_constant_override("separation", 4)

	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var slot: InventorySlot = INVENTORY_SLOT_SCENE.instantiate()
	slot.setup(inventory, slot_id)

	wrapper.add_child(label)
	wrapper.add_child(slot)
	parent.add_child(wrapper)
