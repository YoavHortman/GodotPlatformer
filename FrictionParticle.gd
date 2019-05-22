extends Particles2D


const MIN_LIFE_TIME = 1;
const MAX_LIFE_TIME = 3;
const MAX_SPEED_SCALE = 7;
const MIN_SPEED_SCALE = 3;
const MIN_INITIAL_VELOCITY = 80;
const MAX_INITIAL_VELOCITY = 150;
const MAX_SIZE_SCALE = 7;
const MIN_SIZE_SCALE = 3;
const MAX_SPEED = 600;

func emit_for_motion(motion):
	var percent = abs(motion.x) / MAX_SPEED;
	if (motion.x >= get_parent().ACCELERATION):
		set_rotation_degrees(340);
	else: 
		set_rotation_degrees(200);
	set_lifetime(max(MIN_LIFE_TIME, percent * MAX_LIFE_TIME));
	set_speed_scale(max(MIN_SPEED_SCALE, percent * MAX_SPEED_SCALE));
	get_process_material().set_param(ParticlesMaterial.PARAM_INITIAL_LINEAR_VELOCITY, max(MIN_INITIAL_VELOCITY, percent * MAX_INITIAL_VELOCITY))
	get_process_material().set_param(ParticlesMaterial.PARAM_SCALE, max(MIN_SIZE_SCALE, percent * MAX_SIZE_SCALE))
	set_emitting(true);
	