extends Line2D

func _process(delta):
	var vector = get_parent().find_node("Player").global_position
	var motion = get_parent().find_node("Player").motion
	set_zoom_from_motion(motion);
	var percentage = motion.y / 900;
	if motion.y > 600:
		var color = Color(1, 0, 0, 0.4)
		color.r = percentage;
		set_default_color(color);
		if randi() % 2 == 0:
			vector.x += (randi() % 15) * percentage;
			vector.y += (randi() % 15) * percentage;
		else:
			vector.x -= (randi() % 15) * percentage;
		vector.y -= (randi() % 15) * percentage;
	else:
		set_default_color(Color("78000000"));
	add_point(vector);
	if motion.y == 0 && motion.x == 0:
		remove_point(0);
		remove_point(0);
	elif get_point_count() > 10 :
		set_point_position(get_point_count() - 1, vector);
		remove_point(0);

	
const MAX_ZOOM_OUT = 17;
const MAX_ZOOM_IN = 1;
const MAX_ZOOM_OUT_VELOCITY = 1200;
const ZOOM_HISTORY_LENGTH = 30;

var zoom_history = [];
var current_zoom = Vector2();
func set_zoom_from_motion(motion):
	var angular_velocity = sqrt(pow(motion.x, 2) + pow(motion.y, 2));
	var velocity = min(MAX_ZOOM_OUT_VELOCITY, angular_velocity);
	var delta_zoom = MAX_ZOOM_OUT - MAX_ZOOM_IN;
	var point_in_history = (velocity / MAX_ZOOM_OUT_VELOCITY) * delta_zoom + MAX_ZOOM_IN;
	
	if len(zoom_history) > ZOOM_HISTORY_LENGTH:
		zoom_history.pop_back()
	zoom_history.push_front(point_in_history);
	
	var sum = 0;
	for item in zoom_history:
		sum += item;
	var avrege = sum / len(zoom_history);
	var target_zoom = Vector2(avrege, avrege);
	
	current_zoom = lerp(current_zoom, target_zoom, 0.05);
	
	set_width(current_zoom.x);