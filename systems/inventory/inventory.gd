class_name Inventory extends Resource

signal slot_changed(slot_id: StringName)

const ARMOR_SLOT := &"armor"
const SHIELD_SLOT := &"shield"
const MAIN_WEAPON_SLOT := &"main_weapon"
const STORAGE_SLOT_COUNT := 5

var _items: Dictionary = {}
var _accepted_types: Dictionary = {
	ARMOR_SLOT: [InventoryItem.ItemType.ARMOR],
	SHIELD_SLOT: [InventoryItem.ItemType.SHIELD],
	MAIN_WEAPON_SLOT: [InventoryItem.ItemType.MAIN_WEAPON],
}
var _storage_slots: Array[StringName] = []

func _init() -> void:
	for index in range(STORAGE_SLOT_COUNT):
		var slot_id := get_storage_slot_id(index)
		_storage_slots.push_back(slot_id)
		_accepted_types[slot_id] = []
		_items[slot_id] = null

	_items[ARMOR_SLOT] = null
	_items[SHIELD_SLOT] = null
	_items[MAIN_WEAPON_SLOT] = null

func get_equipment_slots() -> Array[StringName]:
	return [ARMOR_SLOT, SHIELD_SLOT, MAIN_WEAPON_SLOT]

func get_storage_slots() -> Array[StringName]:
	return _storage_slots.duplicate()

func get_storage_slot_id(index: int) -> StringName:
	return StringName("storage_%d" % index)

func get_slot_item(slot_id: StringName) -> InventoryItem:
	if not _items.has(slot_id):
		return null

	return _items[slot_id]

func set_slot_item(slot_id: StringName, item: InventoryItem) -> bool:
	if not can_place_item(slot_id, item):
		return false

	_items[slot_id] = item
	slot_changed.emit(slot_id)
	return true

func clear_slot(slot_id: StringName) -> InventoryItem:
	if not _items.has(slot_id):
		return null

	var item: InventoryItem = _items[slot_id]
	if item == null:
		return null

	_items[slot_id] = null
	slot_changed.emit(slot_id)
	return item

func add_to_storage(item: InventoryItem) -> bool:
	for slot_id in _storage_slots:
		if get_slot_item(slot_id) == null and set_slot_item(slot_id, item):
			return true

	return false

func remove_item(item: InventoryItem) -> bool:
	for slot_id in _items:
		if _items[slot_id] == item:
			clear_slot(slot_id)
			return true

	return false

func equip_item(item: InventoryItem) -> bool:
	var slot_id := get_equipment_slot_for_type(item.item_type)
	if slot_id == &"":
		return false

	return set_slot_item(slot_id, item)

func equip_from_slot(source_slot_id: StringName) -> bool:
	var item := get_slot_item(source_slot_id)
	if item == null:
		return false

	var target_slot_id := get_equipment_slot_for_type(item.item_type)
	if target_slot_id == &"":
		return false

	return move_or_swap(source_slot_id, target_slot_id)

func unequip_item(item_type: int) -> bool:
	var slot_id := get_equipment_slot_for_type(item_type)
	if slot_id == &"":
		return false

	var item := clear_slot(slot_id)
	if item == null:
		return false

	if add_to_storage(item):
		return true

	set_slot_item(slot_id, item)
	return false

func can_place_item(slot_id: StringName, item: InventoryItem) -> bool:
	if not _items.has(slot_id):
		return false

	if item == null:
		return true

	var accepted_types: Array = _accepted_types.get(slot_id, [])
	return accepted_types.is_empty() or accepted_types.has(item.item_type)

func can_move_or_swap(from_slot_id: StringName, to_slot_id: StringName) -> bool:
	if from_slot_id == to_slot_id:
		return false

	if not _items.has(from_slot_id) or not _items.has(to_slot_id):
		return false

	var from_item := get_slot_item(from_slot_id)
	if from_item == null:
		return false

	var to_item := get_slot_item(to_slot_id)
	return can_place_item(to_slot_id, from_item) and can_place_item(from_slot_id, to_item)

func move_or_swap(from_slot_id: StringName, to_slot_id: StringName) -> bool:
	if not can_move_or_swap(from_slot_id, to_slot_id):
		return false

	var from_item := get_slot_item(from_slot_id)
	var to_item := get_slot_item(to_slot_id)
	_items[from_slot_id] = to_item
	_items[to_slot_id] = from_item
	slot_changed.emit(from_slot_id)
	slot_changed.emit(to_slot_id)
	return true

func get_equipment_slot_for_type(item_type: int) -> StringName:
	match item_type:
		InventoryItem.ItemType.ARMOR:
			return ARMOR_SLOT
		InventoryItem.ItemType.SHIELD:
			return SHIELD_SLOT
		InventoryItem.ItemType.MAIN_WEAPON:
			return MAIN_WEAPON_SLOT

	return &""
