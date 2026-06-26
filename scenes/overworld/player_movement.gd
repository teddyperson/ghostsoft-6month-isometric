extends CharacterBody2D

@export var anim: AnimatedSprite2D
const SPEED = 300.0

var prev_dir := "s"

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

	velocity = input_direction * SPEED
	
	_play_anim(input_direction)
	move_and_slide()

func _play_anim(dir: Vector2) -> void:
	# [NW][N][NE]
	# [W] [ ] [E]
	# [SW][S][SE]
	var dir_table = [["nw", "n", "ne"], ["w", "x", "e"], ["sw", "s", "se"]]
	
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
	
	var dir_str = dir_table[row][col]
	
	if dir_str == "x":
		anim.play("idle_%s" % prev_dir)
		return
	else:
		prev_dir = dir_str
	
	var frame = anim.frame
	var progress = anim.frame_progress
	
	anim.play("run_%s" % dir_str)
	anim.set_frame_and_progress(frame, progress)
