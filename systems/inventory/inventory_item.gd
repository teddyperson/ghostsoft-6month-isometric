class_name InventoryItem extends Resource

enum ItemType {
	ARMOR,
	SHIELD,
	MAIN_WEAPON,
}

@export var display_name := ""
@export var icon: Texture2D
@export var item_type := ItemType.ARMOR
