extends KinematicBody2D

const UP = Vector2(0, -1);
const GRAVITY = 20;
const ACCELERATION = 32;
const JUMP_HEIGHT = -400;
const MAX_SPEED = 400;

var motion = Vector2();
func _physics_process(delta):
	var animation = "Idle";
	var isIdle = false;
	if Input.is_action_pressed("ui_right"):
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED);
		$Sprite.flip_h = false;
		animation = "Run";
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED);
		$Sprite.flip_h = true;
		animation = "Run";
	else:
		isIdle = true
	
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"): 
			motion.y = JUMP_HEIGHT;
		if isIdle:
			motion.x = lerp(motion.x, 0, 0.1);
	else:
		if motion.y < 0:
			animation = "Jump";
		elif motion.y > 0: 
			animation = "Fall";
	
	$Sprite.play(animation);
	move_and_slide(motion, UP);


func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
