extends Particles2D


const MAX_AMOUNT = 20;
const MIN_LIFE_TIME = 0.1;
const MAX_LIFE_TIME = 3;
const MAX_PARTICLE_SPEED_SCALE = 10;
const MAX_SPEED = 600;

func emit_for_motion(motion):
	if (motion.x >= get_parent().ACCELERATION):
		set_rotation_degrees(330);
	else: 
		set_rotation_degrees(210);
	set_emitting(true);
	set_lifetime(max(1, (abs(motion.x) / MAX_SPEED) * MAX_LIFE_TIME));
	set_speed_scale(max(3, (abs(motion.x) / MAX_SPEED) * 7));
	