extends KinematicBody2D

const UP = Vector2(0, -1);
const GRAVITY = 20;
const ACCELERATION = 40;
const JUMP_HEIGHT = -400;
const MAX_SPEED = 400;
const WALL_SLIDE_FRICTION = 0.9;
const WALL_JUMP_FORCE = 200;


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
	
	
	if (!$RayCastRightTop.is_colliding() && $RayCastRightTop2.is_colliding()):
		motion.y = 0;
		motion.x = 0;
		if jump && !$RayCastDown.is_colliding():
			motion.y = JUMP_HEIGHT;
	elif $RayCastRightBottom.is_colliding() && motion.x >= 0:
		wall_collision(-WALL_JUMP_FORCE, jump);
	
	if $RayCastLeft.is_colliding() && motion.x <= 0:
		wall_collision(WALL_JUMP_FORCE, jump);
		
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
	move_and_slide(motion, UP);
	$Sprite.play(animation);

func _ready():
	print("ready");

func wall_collision(opposite_force, jump):
	motion.x = 0;
	if motion.y > 0:
		motion.y -= GRAVITY * WALL_SLIDE_FRICTION;
		$Sprite.flip_h = opposite_force < 0;
	if jump && !$RayCastDown.is_colliding():
		motion.y = JUMP_HEIGHT;
		motion.x = opposite_force;