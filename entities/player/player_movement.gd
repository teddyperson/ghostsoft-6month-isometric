class_name Movement extends PlayerComponent

@export var anim: AnimatedSprite3D
@export var speed := 1.0

const DIR_TABLE = [["nw", "n", "ne"], ["w", "x", "e"], ["sw", "s", "se"]]
var prev_dir = "s"

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

	var movement_vector := Vector3(input_direction.x, 0.0, input_direction.y * 1.5).rotated(Vector3.UP, deg_to_rad(-45.0))

	player.velocity = movement_vector * speed
	
	_play_anim(input_direction)
	player.move_and_slide()

func _play_anim(dir: Vector2) -> void:
	# [NW][N][NE]
	# [W] [ ] [E]
	# [SW][S][SE]
	
	
	var row := 1
	var col := 1
	
	if dir.x > 0:
		col += 1
	elif dir.x < 0:
		col -= 1
	
	if dir.y > 0:
		row += 1
	elif dir.y < 0:
		row -= 1
	
	var dir_str = DIR_TABLE[row][col]
	
	if dir_str == "x":
		anim.play("idle_%s" % prev_dir)
		return
	else:
		prev_dir = dir_str
	
	var frame = anim.frame
	var progress = anim.frame_progress
	
	anim.play("run_%s" % dir_str)
	anim.set_frame_and_progress(frame, progress)
