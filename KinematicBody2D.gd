extends KinematicBody2D

const UP = Vector2(0, -1);
const GRAVITY = 20;
const ACCELERATION = 50;
const JUMP_HEIGHT = -400;
const MAX_SPEED = 400;

var motion = Vector2();
func _physics_process(delta):
	var right = Input.is_action_pressed("ui_right");
	var left =  Input.is_action_pressed("ui_left");
	var jump = Input.is_action_just_pressed("ui_up");
	
	var animation = "Idle";
	var isIdle = false;
	motion.y += GRAVITY;
	if right:
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED);
		$Sprite.flip_h = false;
		animation = "Run";
	elif left:
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED);
		$Sprite.flip_h = true;
		animation = "Run";
	else:
		isIdle = true
	
	if $RayCastRight.is_colliding() && (motion.x > 0 || !$RayCastDown.is_colliding()):
		motion.x = 0;
		if jump:
			motion.y = JUMP_HEIGHT / 1.5;
			motion.x = -MAX_SPEED / 1.5;
			$Sprite.flip_h = true;
	
	if $RayCastDown.is_colliding():
		motion.y = 0;
		if jump:
			motion.y = JUMP_HEIGHT;
		if isIdle:
			motion.x = lerp(motion.x, 0, 0.1);
	else:
		if motion.y < 0:
			animation = "Jump";
		else:
			animation = "Fall";
	motion = move_and_slide(motion, UP);
	$Sprite.play(animation);

func _ready():
	print("ready");

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
