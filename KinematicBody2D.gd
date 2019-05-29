extends KinematicBody2D

# Add state manager?
# Add (retractable once?) parachute instead of roll

const UP = Vector2(0, -1);
const GRAVITY = 15;
const MAX_FALL_SPEED = 1200;
const DANGER_FALL_SPEED = 600;
const ACCELERATION = 20;
const BACKWARDS_ACCELERATION = 40;
const AIR_ACCELERATION = 10;
const INITIAL_JUMP_FORCE = -300;
const MAX_SPEED = 800;
const WALL_SLIDE_FRICTION = 0.6;
const WALL_JUMP_FORCE = 200;
const EDGE_HOLD_JUMP_FORCE = 300;
const MAX_WALL_SLIDE_SPEED = 800;
const IMMOBILTIY_AFTER_FALL_DURATION = 1.6;
const SAFE_LANDING_AFTER_ROLL_TIME_WINDOW = 0.5;


var time_since_break_fall = 1.0;
var time_since_roll_click = 1.0;
var time_since_dash = 1.0;
var time_since_jump = 1.0;
var air_time = 0.0;
var motion = Vector2();
var lastFrameMotion = Vector2();
var shake_precentage = 1;
var current_friction = 0.08;
var tilemap: TileMap;
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
					$FrictionParticle.emit_for_motion(lastFrameMotion);
					animation = "Friction";
				else:
					animation = "Run";
					if motion.x < MAX_SPEED:
						motion.x = min(motion.x + ACCELERATION, MAX_SPEED);	
					$Sprite.flip_h = false;
			else:
				motion.x = min(motion.x + AIR_ACCELERATION, MAX_SPEED);	
				$Sprite.flip_h = false;
		elif left:
			if is_on_floor():
				if motion.x > ACCELERATION:
					motion.x = max(motion.x - BACKWARDS_ACCELERATION, -MAX_SPEED);
					$FrictionParticle.emit_for_motion(lastFrameMotion);
					animation = "Friction";
				else:
					$Sprite.flip_h = true;
					motion.x = max(motion.x - ACCELERATION, -MAX_SPEED);
					animation = "Run";
			else:
				$Sprite.flip_h = true;
				motion.x = max(motion.x - AIR_ACCELERATION, -MAX_SPEED);
		else:
			isIdle = true
			
	if is_on_floor():
		air_time = 0;
		if lastFrameMotion.y > DANGER_FALL_SPEED:
			if time_since_roll_click > SAFE_LANDING_AFTER_ROLL_TIME_WINDOW:
				shake_precentage = lastFrameMotion.y / MAX_FALL_SPEED;
				time_since_break_fall = -(shake_precentage * IMMOBILTIY_AFTER_FALL_DURATION);
				$Camera2D.shake(abs(time_since_break_fall), 300 * shake_precentage, 10 * shake_precentage);
				Input.start_joy_vibration(0, 1 * shake_precentage, 1 * shake_precentage, abs(time_since_break_fall))
				$DropParticle.set_amount(15 * shake_precentage);
				$DropParticle.set_lifetime(abs(time_since_break_fall));
				$DropParticle.get_process_material().set_param(ParticlesMaterial.PARAM_SCALE, 10 * shake_precentage);
				$DropParticle.set_emitting(true);

		if isIdle:
			# Avoid very slow deaccl when velocity is close to 0
			if (abs(motion.x) < ACCELERATION):
				motion.x = 0;
			else:
				motion.x = lerp(motion.x, 0, current_friction);
	else:
		air_time += delta;
		if motion.y < 0:
			animation = "Jump";
		else:
			animation = "Fall";
	
	if !is_on_floor() || is_on_wall():
		$FrictionParticle.set_emitting(false);
	
	if is_wall_sliding():
		animation = "WallSlide"
		wall_collision();
	if is_edge_holding_right() || is_edge_holding_left():
		motion.y = 0;
		wall_collision();
	jump()
	if dash && time_since_dash > air_time && air_time > 0 && time_since_dash > 0.15:
		time_since_dash = -0.3;
	if time_since_dash < -0.2 && time_since_dash >= -0.3:
		$DropParticle.restart();
		$DropParticle.set_amount(15);
		$DropParticle.set_lifetime(1);
		$DropParticle.get_process_material().set_param(ParticlesMaterial.PARAM_SCALE, 10);
		$DropParticle.set_emitting(true);
		motion.x = 0;
		motion.y = 0;
		Input.start_joy_vibration(0, 0.7 + time_since_dash, 0.7 + time_since_dash, time_since_dash * 10)
	if time_since_dash >= -0.2 && time_since_dash <= 0:
		if is_on_wall():
			time_since_dash = 0;
			$DropParticle.set_emitting(false);
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


	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var cell_pos = tilemap.world_to_map(collision.get_position())
		var tile_id = tilemap.get_cellv(cell_pos)
		var tile_name = tilemap.tile_set.tile_get_name(tile_id)
		if tile_name == "0": 
			if lastFrameMotion.y > MAX_FALL_SPEED / 4 && is_on_floor():
				print("todo");
				#motion.y = lerp(-lastFrameMotion.y, 0, 0.2);
				#motion.x = lerp(-lastFrameMotion.x, 0, 0.2)
		else: 
			current_friction = 0.08;
	
	
	$Camera2D.set_zoom_from_motion(motion);
	$Camera2D.offset_for_motion(motion);
		
	lastFrameMotion = motion;
	
	motion = move_and_slide(motion, UP);
	time_since_dash += delta;	
	time_since_roll_click += delta;
	time_since_jump += delta;
	$Sprite.play(animation);

func _ready():
	 tilemap = get_parent().get_node("NormalTile");

func wall_collision():
	air_time = 0;
	if motion.y > 0:
		motion.y = min(motion.y - GRAVITY * WALL_SLIDE_FRICTION, MAX_WALL_SLIDE_SPEED);

func _process(delta):
	OS.set_window_title("FirstGame | fps: " + str(Engine.get_frames_per_second()))

var jump_vector = Vector2();
func jump():
	var jump_just_pressed = Input.is_action_just_pressed("ui_jump");
	var jump_pressed = Input.is_action_pressed("ui_jump");
	if is_edge_holding_right():
		jump_vector.x = -EDGE_HOLD_JUMP_FORCE;
		jump_vector.y = INITIAL_JUMP_FORCE;
	elif is_edge_holding_left():
		jump_vector.x = EDGE_HOLD_JUMP_FORCE;
		jump_vector.y = INITIAL_JUMP_FORCE;
	elif is_wall_sliding():
		if lastFrameMotion.x > 0:
			jump_vector.x = -WALL_JUMP_FORCE;
		elif lastFrameMotion.x < 0:
			jump_vector.x = WALL_JUMP_FORCE;
		jump_vector.y = INITIAL_JUMP_FORCE;
	elif is_on_floor():
		jump_vector.y = INITIAL_JUMP_FORCE;
		jump_vector.x = motion.x;
			
	
	if jump_just_pressed && air_time <= 0.15 && (motion.y >= 0 || abs(jump_vector.x) == WALL_JUMP_FORCE ):
		time_since_jump = 0;
		motion = jump_vector;
			
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
			
			