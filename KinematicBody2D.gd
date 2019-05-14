extends KinematicBody2D

const UP = Vector2(0, -1);
const GRAVITY = 15;
const MAX_FALL_SPEED = 1200;
const ACCELERATION = 20;
const BACKWARDS_ACCELERATION = 40;
const AIR_ACCELERATION = 10;
const INITIAL_JUMP_FORCE = -300;
const MAX_SPEED = 800;
const WALL_SLIDE_FRICTION = 0.6;
const WALL_JUMP_FORCE = 200;
const EDGE_HOLD_JUMP_FORCE = 300;
const MAX_WALL_SLIDE_SPEED = 500;
const IMMOBILTIY_AFTER_FALL_DURATION = 1.6;
const SAFE_LANDING_AFTER_ROLL_TIME_WINDOW = 0.5;

# TODO -- Fix edge hold issue
# Give edge hold stop frame and extra jump strengh
# maybe change wall hang to every wall
# make it clear when it is possible to dash (one time per jump)
# think about double jump
# PRETTIFY!!!!

var time_since_break_fall = 1.0;
var time_since_roll_click = 1.0;
var time_since_dash = 1.0;
var time_since_jump = 1.0;
var air_time = 0.0;
var motion = Vector2();
var lastFrameFallSpeed = 0;
var shake_precentage = 1;
func _physics_process(delta):
	var right = Input.is_action_pressed("ui_right");
	var left =  Input.is_action_pressed("ui_left");
	var down = Input.is_action_pressed("ui_down");
	var dash = Input.is_action_just_pressed("ui_dash");
	var roll = Input.is_action_just_pressed("ui_roll");
	
	var animation = "Idle";
	var isIdle = false;
	motion.y = min(motion.y + GRAVITY, MAX_FALL_SPEED);
	if time_since_dash > 0:
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
	if is_on_floor():
		air_time = 0;
		if lastFrameFallSpeed > MAX_FALL_SPEED / 3:
			if time_since_roll_click > SAFE_LANDING_AFTER_ROLL_TIME_WINDOW:
				shake_precentage = lastFrameFallSpeed / MAX_FALL_SPEED;
				time_since_break_fall = -(shake_precentage * IMMOBILTIY_AFTER_FALL_DURATION);
				$Camera2D.shake(abs(time_since_break_fall), 300 * shake_precentage, 10 * shake_precentage);
				Input.start_joy_vibration(0, 1 * shake_precentage, 1 * shake_precentage, abs(time_since_break_fall))
		if isIdle:
			motion.x = lerp(motion.x, 0, 0.08);
	else:
		air_time += delta;
		if motion.y < 0:
			animation = "Jump";
		else:
			animation = "Fall";
	
	if is_wall_sliding():
		wall_collision();
	if is_edge_holding_right() || is_edge_holding_left():
		motion.y = 0;
		wall_collision();
	jump();
	
	if dash && time_since_dash > air_time && air_time > 0:
		time_since_dash = -0.3;
	if time_since_dash < -0.2 && time_since_dash >= -0.3:
		motion.x = 0;
		motion.y = 0;
		Input.start_joy_vibration(0, 0.4 + time_since_dash, 0.4 + time_since_dash, delta)
	if time_since_dash >= -0.2 && time_since_dash <= 0:
		animation = "Dash";
		motion.y = 0;
		$Camera2D.offset_for_dash(!$Sprite.flip_h);
		if !$Sprite.flip_h:
			motion.x = lerp(motion.x, MAX_SPEED, 0.2);
		else:
			motion.x = lerp(motion.x, -MAX_SPEED, 0.2);
	$Sprite.flip_v = false;
	
	# Ignore 2nd roll in air
	if roll && air_time <= time_since_roll_click: 
		time_since_roll_click = 0.0;
	
	if time_since_roll_click < SAFE_LANDING_AFTER_ROLL_TIME_WINDOW:
		$Sprite.flip_v = true;
	
	# TODO maybe have a staate???
	if time_since_break_fall < 0:
		motion.x = 0;
		motion.y = 0;
		time_since_break_fall += delta;
		animation = "Dash";
	
	$Camera2D.set_zoom_from_motion(motion);
	$Camera2D.offset_for_motion(motion);
		
	lastFrameFallSpeed = motion.y;
	motion = move_and_slide(motion, UP);
	time_since_dash += delta;	
	time_since_roll_click += delta;
	time_since_jump += delta;
	$Sprite.play(animation);

func _ready():
	print("ready");

func wall_collision():
	air_time = 0;
	if motion.y > 0:
		motion.y = min(motion.y - GRAVITY * WALL_SLIDE_FRICTION, MAX_WALL_SLIDE_SPEED);

func jump():
	var jump_just_pressed = Input.is_action_just_pressed("ui_jump");
	var jump_pressed = Input.is_action_pressed("ui_jump");
	if jump_just_pressed:
		if is_edge_holding_right():
			time_since_jump = 0;
			motion.x = -EDGE_HOLD_JUMP_FORCE;
			motion.y = INITIAL_JUMP_FORCE;
		elif is_edge_holding_left():
			time_since_jump = 0;
			motion.x = EDGE_HOLD_JUMP_FORCE;
			motion.y = INITIAL_JUMP_FORCE;
		elif is_wall_sliding():
			if motion.x > 0:
				motion.x = -WALL_JUMP_FORCE;
			elif motion.x < 0:
				motion.x = WALL_JUMP_FORCE;
			time_since_jump = 0;
			motion.y = INITIAL_JUMP_FORCE;
		elif air_time <= 0.15 && motion.y >= 0:
			time_since_jump = 0;
			motion.y = INITIAL_JUMP_FORCE;
	
	if jump_pressed && time_since_jump >= 0.1 && time_since_jump <= 0.3 && motion.y < 0:
		motion.y -= GRAVITY;
			
func is_edge_holding_right():
	var hold = Input.is_action_pressed("ui_hold");
	return hold && $RayCastRightEdgeGrab.is_colliding() && !$RayCastRightEdgeGrab2.is_colliding();

func is_edge_holding_left():
	var hold = Input.is_action_pressed("ui_hold");
	return hold && $RayCastLeftEdgeGrab.is_colliding() && !$RayCastLeftEdgeGrab2.is_colliding();
			
func is_wall_sliding():
	return is_on_wall() && !is_on_floor();
			
			