extends CharacterBody2D

var components: Array[PlayerComponent]

var last_dir := "s"

func _ready() -> void:
	for child in get_children():
		if child is PlayerComponent:
			child.player = self
			components.push_back(child)
	
	for component in components:
		component._setup()

func _physics_process(delta: float) -> void:
	for component in components:
		component._physics_update(delta)

func _process(delta: float) -> void:
	for component in components:
		component._update(delta)
