extends KinematicBody2D

const UP = Vector2(0, -1);
const GRAVITY = 15;
const MAX_FALL_SPEED = 1200;
const ACCELERATION = 20;
const BACKWARDS_ACCELERATION = 40;
const AIR_ACCELERATION = 10;
const INITIAL_JUMP_FORCE = -400;
const ADDED_JUMP_FORCE = -40;
const MAX_SPEED = 800;
const WALL_SLIDE_FRICTION = 0.6;
const WALL_JUMP_FORCE = 200;
const EDGE_HOLD_JUMP_FORCE = 300;
const MAX_WALL_SLIDE_SPEED = 500;
const IMMOBILTIY_AFTER_FALL_DURATION = 1.6;
const SAFE_LANDING_AFTER_ROLL_TIME_WINDOW = 0.5;

# TODO -- Fix edge hold issue
# Give edge hold stop frame and extra jump strengh
# think about double jump
# PRETTIFY!!!!

var time_since_break_fall = 0.0;
var time_since_roll_click = 0.0;
var time_since_dash = 0.0;
var air_time = 0.0;
var motion = Vector2();
var lastFrameFallSpeed = 0;
var shake_precentage = 1;
func _physics_process(delta):
	var right = Input.is_action_pressed("ui_right");
	var left =  Input.is_action_pressed("ui_left");
	var jump = Input.is_action_just_pressed("ui_jump");
	var down = Input.is_action_pressed("ui_down");
	var dash = Input.is_action_just_pressed("ui_dash");
	var roll = Input.is_action_just_pressed("ui_roll");
	var hold = Input.is_action_pressed("ui_hold");
	
	var animation = "Idle";
	var isIdle = false;
	motion.y = min(motion.y + GRAVITY, MAX_FALL_SPEED);
	if time_since_dash < 0:
		if right:
			if is_on_floor():
				if motion.x < -ACCELERATION: 
					motion.x = min(motion.x + BACKWARDS_ACCELERATION, MAX_SPEED);	
				else:
					motion.x = min(motion.x + ACCELERATION, MAX_SPEED);	
					animation = "Run";
			else:
				motion.x = min(motion.x + AIR_ACCELERATION, MAX_SPEED);	
			$Sprite.flip_h = false;
		elif left:
			if is_on_floor():
				if motion.x > ACCELERATION:
					motion.x = max(motion.x - BACKWARDS_ACCELERATION, -MAX_SPEED);
				else:
					motion.x = max(motion.x - ACCELERATION, -MAX_SPEED);
					animation = "Run";
			else:
				motion.x = max(motion.x - AIR_ACCELERATION, -MAX_SPEED);
			$Sprite.flip_h = true;
		else:
			isIdle = true

	if (hold && $RayCastRightEdgeGrab.is_colliding() && !$RayCastRightEdgeGrab2.is_colliding()):
		motion.y = 0;
		wall_collision(-EDGE_HOLD_JUMP_FORCE, jump);
	elif (hold && $RayCastLeftEdgeGrab.is_colliding() && !$RayCastLeftEdgeGrab2.is_colliding()):
		motion.y = 0;
		wall_collision(WALL_JUMP_FORCE, jump);
	else: 	
		if is_on_wall() && motion.x > 0:
			air_time = 0;
			wall_collision(-WALL_JUMP_FORCE, jump && !is_on_floor())
		elif is_on_wall() && motion.x < 0:
			air_time = 0;
			wall_collision(WALL_JUMP_FORCE, jump && !is_on_floor());
	
	if is_on_floor():
		air_time = 0;
		if lastFrameFallSpeed > MAX_FALL_SPEED / 3 && time_since_roll_click > SAFE_LANDING_AFTER_ROLL_TIME_WINDOW:
			shake_precentage = lastFrameFallSpeed / MAX_FALL_SPEED;
			$Camera2D.shake(0.7 * shake_precentage, 300 * shake_precentage, 8 * shake_precentage);
			time_since_break_fall = shake_precentage * IMMOBILTIY_AFTER_FALL_DURATION;
		if isIdle:
			motion.x = lerp(motion.x, 0, 0.05);
	else:
		air_time += delta;
		if motion.y < 0:
			animation = "Jump";
		else:
			animation = "Fall";
	if jump && air_time <= 0.15 && motion.y >= 0:
		motion.y = INITIAL_JUMP_FORCE;
	
	if dash && time_since_dash < -0.5:
		time_since_dash = 0.3;
	if time_since_dash > 0.1 && time_since_dash < 0.3:
		motion.x = 0;
		motion.y = 0;
	if time_since_dash <= 0.1 && time_since_dash >= 0:
		animation = "Dash";
		motion.y = 0;
		if !$Sprite.flip_h:
			motion.x = lerp(motion.x, MAX_SPEED, 0.116);
		else:
			motion.x = lerp(motion.x, -MAX_SPEED, 0.116);
	time_since_dash -= delta;	
	time_since_roll_click += delta;

	$Sprite.flip_v = false;
	if roll && air_time <= time_since_roll_click: 
		time_since_roll_click = 0.0;
		
	
	if time_since_roll_click < SAFE_LANDING_AFTER_ROLL_TIME_WINDOW:
		$Sprite.flip_v = true;
		
	if time_since_break_fall > 0:
		motion.x = 0;
		motion.y = 0;
		time_since_break_fall -= delta;
		
	
	lastFrameFallSpeed = motion.y;
	motion = move_and_slide(motion, UP);
	$Sprite.play(animation);

func _ready():
	print("ready");

func wall_collision(opposite_force, jump):
	if motion.y > 0:
		motion.y = min(motion.y - GRAVITY * WALL_SLIDE_FRICTION, MAX_WALL_SLIDE_SPEED);
		$Sprite.flip_h = opposite_force < 0;
	if jump:
		motion.y = INITIAL_JUMP_FORCE;
		motion.x = opposite_force;
