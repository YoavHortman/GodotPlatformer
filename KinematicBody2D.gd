extends KinematicBody2D

const UP = Vector2(0, -1);
const GRAVITY = 20;
const MAX_FALL_SPEED = 800;
const ACCELERATION = 30;
const INITIAL_JUMP_FORCE = -400;
const ADDED_JUMP_FORCE = -40;
const MAX_SPEED = 400;
const WALL_SLIDE_FRICTION = 0.6;
const WALL_JUMP_FORCE = 200;
const EDGE_HOLD_JUMP_FORCE = 300;
const MAX_WALL_SLIDE_SPEED = 500;
const IMMOBILTIY_AFTER_FALL_DURATION = 0.8;


var time_since_break_fall = 0.0;
var motion = Vector2();
var lastFrameFallSpeed = 0;
var break_fall = false;
func _physics_process(delta):
	var right = Input.is_action_pressed("ui_right");
	var left =  Input.is_action_pressed("ui_left");
	var jump = Input.is_action_just_pressed("ui_up");
	var down = Input.is_action_pressed("ui_down");

	var animation = "Idle";
	var isIdle = false;
	motion.y = min(motion.y + GRAVITY, MAX_FALL_SPEED);
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

	if (!$RayCastRightEdgeGrab.is_colliding() && $RayCastRightEdgeGrab2.is_colliding()):
		motion.y = 0;
		wall_collision(-EDGE_HOLD_JUMP_FORCE, jump);
	elif (!$RayCastLeftEdgeGrab.is_colliding() && $RayCastLeftEdgeGrab2.is_colliding()):
		motion.y = 0;
		wall_collision(WALL_JUMP_FORCE, jump);
	else: 	
		if is_on_wall() && motion.x > 0:
			wall_collision(-WALL_JUMP_FORCE, jump);
		elif is_on_wall() && motion.x < 0:
			wall_collision(WALL_JUMP_FORCE, jump);
	
	if is_on_floor():
		if lastFrameFallSpeed > 400:
			var shake_precentage = lastFrameFallSpeed / MAX_FALL_SPEED;
			$Camera2D.shake(0.7 * shake_precentage, 300 * shake_precentage, 8 * shake_precentage)
			time_since_break_fall = shake_precentage * IMMOBILTIY_AFTER_FALL_DURATION;
		if jump:
			motion.y = INITIAL_JUMP_FORCE;
		if isIdle:
			motion.x = lerp(motion.x, 0, 0.1);
	else:
		if motion.y < 0:
			animation = "Jump";
		else:
			animation = "Fall";
			
	lastFrameFallSpeed = motion.y;
	
	if time_since_break_fall > 0:
		motion.x = 0;
		motion.y = 0;
	
	time_since_break_fall -= delta;
	
	motion = move_and_slide(motion, UP);
	$Sprite.play(animation);

func _ready():
	print("ready");

func wall_collision(opposite_force, jump):
	if motion.y > 0:
		motion.y = min(motion.y - GRAVITY * WALL_SLIDE_FRICTION, MAX_WALL_SLIDE_SPEED);
		$Sprite.flip_h = opposite_force < 0;
	if jump && !is_on_floor():
		motion.y = INITIAL_JUMP_FORCE;
		motion.x = opposite_force;