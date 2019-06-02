extends Line2D

func _process(delta):
	var vector = get_parent().find_node("Player").global_position
	var motion = get_parent().find_node("Player").motion
	if motion.y > 600:
		if randi() % 2 == 0:
			vector.x += (randi() % 20);
			vector.y += (randi() % 20);
		else:
			vector.x -= (randi() % 20);
			vector.y -= (randi() % 20);
	add_point(vector);
	if motion.y == 0 && motion.x == 0 && get_point_count() > 1:
		remove_point(0);
		remove_point(0);
	elif get_point_count() > 100:
		set_point_position(get_point_count() - 1, vector);
		remove_point(0);
