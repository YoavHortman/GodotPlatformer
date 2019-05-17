extends RayCast2D

const MIN_TIME_SCALE = 0.3;
const MAX_TIME_SCALE_VELOCITY = 700;

func _physics_process(delta):
	var motion = get_parent().motion;
	var threshold = get_parent().MAX_FALL_SPEED;
	var time_since_roll = get_parent().time_since_roll_click;
	var safe_landing = get_parent().SAFE_LANDING_AFTER_ROLL_TIME_WINDOW;
	if is_colliding() && motion.y > threshold / 2 && time_since_roll > safe_landing:
		Engine.time_scale = 0.3
		 #max(MIN_TIME_SCALE, (1 - motion.y / MAX_TIME_SCALE_VELOCITY));
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1, 0.2);
		
	if motion.y > threshold / 2:
		var shake_precentage = motion.y / 900;
		get_parent().get_node("Camera2D").shake(delta, 30 * shake_precentage, 5 * shake_precentage);
	cast_to_for_motion(motion.y);
		
		
const MIN_LENGTH = 20;
const MAX_LENGTH = 100;
const MAX_LENGTH_VELOCITY = 900;

func cast_to_for_motion(velocity):
	var target = Vector2();
	target.y = max(MIN_LENGTH, (velocity / MAX_LENGTH_VELOCITY) * MAX_LENGTH);
	set_cast_to(target);
	