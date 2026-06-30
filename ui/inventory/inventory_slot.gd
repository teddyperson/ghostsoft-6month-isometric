class_name InventorySlot extends Control

@onready var icon: TextureRect = $Icon

var inventory: Inventory
var slot_id: StringName

func setup(source_inventory: Inventory, source_slot_id: StringName) -> void:
	inventory = source_inventory
	slot_id = source_slot_id

	if not is_node_ready():
		await ready

	if not inventory.slot_changed.is_connected(_on_inventory_slot_changed):
		inventory.slot_changed.connect(_on_inventory_slot_changed)

	refresh()

func refresh() -> void:
	var item := _get_item()
	icon.texture = item.icon if item != null else null
	tooltip_text = item.display_name if item != null else ""

func _get_drag_data(_at_position: Vector2) -> Variant:
	var item := _get_item()
	if item == null:
		return null

	var preview := TextureRect.new()
	preview.texture = item.icon
	preview.custom_minimum_size = Vector2(40.0, 40.0)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(preview)

	return {
		"inventory": inventory,
		"slot_id": slot_id,
	}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not _is_inventory_drag(data):
		return false

	var source_inventory: Inventory = data["inventory"]
	if source_inventory != inventory:
		return false

	return inventory.can_move_or_swap(data["slot_id"], slot_id)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(_at_position, data):
		inventory.move_or_swap(data["slot_id"], slot_id)

func _on_inventory_slot_changed(changed_slot_id: StringName) -> void:
	if changed_slot_id == slot_id:
		refresh()

func _get_item() -> InventoryItem:
	if inventory == null:
		return null

	return inventory.get_slot_item(slot_id)

func _is_inventory_drag(data: Variant) -> bool:
	if not data is Dictionary:
		return false

	return data.has("inventory") and data.has("slot_id")
