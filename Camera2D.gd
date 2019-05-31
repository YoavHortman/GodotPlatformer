extends Camera2D
var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)

func _ready():
    set_process(true)

# Shake with decreasing intensity while there's time remaining.
func _process(delta):
    # Only shake when there's shake time remaining.
    if _timer == 0:
        return
    # Only shake on certain frames.
    _last_shook_timer = _last_shook_timer + delta
    # Be mathematically correct in the face of lag; usually only happens once.
    while _last_shook_timer >= _period_in_ms:
        _last_shook_timer = _last_shook_timer - _period_in_ms
        # Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
        var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
        # Noise calculation logic from http://jonny.morrill.me/blog/view/14
        var new_x = rand_range(-1.0, 1.0)
        var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
        var new_y = rand_range(-1.0, 1.0)
        var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
        _previous_x = new_x
        _previous_y = new_y
        # Track how much we've moved the offset, as opposed to other effects.
        var new_offset = Vector2(x_component, y_component)
        set_offset(get_offset() - _last_offset + new_offset)
        _last_offset = new_offset
    # Reset the offset when we're done shaking.
    _timer = _timer - delta
    if _timer <= 0:
        _timer = 0
        set_offset(get_offset() - _last_offset)

# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude):
    # Initialize variables.
    _duration = duration
    _timer = duration
    _period_in_ms = 1.0 / frequency
    _amplitude = amplitude
    _previous_x = rand_range(-1.0, 1.0)
    _previous_y = rand_range(-1.0, 1.0)
    # Reset previous offset, if any.
    set_offset(get_offset() - _last_offset)
    _last_offset = Vector2(0, 0)
	
const MAX_ZOOM_OUT = 2.5;
const MAX_ZOOM_IN = 1.2;
const MAX_ZOOM_OUT_VELOCITY = 1200;
const ZOOM_HISTORY_LENGTH = 100;

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
	var target_zoom = Vector2();
	target_zoom.x = avrege;
	target_zoom.y = avrege;
	
	
	current_zoom = lerp(current_zoom, target_zoom, 0.05);
	
	set_zoom(current_zoom);

const MAX_OFFSET_X = 400;
const MAX_OFFSET_Y = 250;
const MAX_OFFSET_VELOCITY_X = 600;
const MAX_OFFSET_VELOCITY_Y = 900;

var current_offset = Vector2();
func offset_for_motion(motion):
	var target = Vector2();
	if motion.x >= 0:
		target.x = min((motion.x / MAX_OFFSET_VELOCITY_X) * MAX_OFFSET_X, MAX_OFFSET_X);
	else:
		target.x = max((motion.x / MAX_OFFSET_VELOCITY_X) * MAX_OFFSET_X, -MAX_OFFSET_X);
	
	if motion.y >= 0:
		target.y = min((motion.y / MAX_OFFSET_VELOCITY_Y) * MAX_OFFSET_Y, MAX_OFFSET_Y);
	else:
		target.y = max((motion.y / MAX_OFFSET_VELOCITY_Y) * MAX_OFFSET_Y, -MAX_OFFSET_Y);
	current_offset = lerp(current_offset, target, 0.02);
	set_offset(current_offset);
	
func offset_for_dash(right):
	if right:
		current_offset.x = lerp(current_offset.x, MAX_OFFSET_X, 0.03);
	else:
		current_offset.x = lerp(current_offset.x, -MAX_OFFSET_X, 0.03);
	set_offset(current_offset);
	