extends Node2D


@onready var _player = get_tree().get_first_node_in_group("player");
@onready var _label = $Label;

const base_text = "[S] "

var active_areas = [];
var can_interact = true;

func register_area(area: InteractionArea):
	active_areas.push_back(area);

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area);
	if index != -1:
		active_areas.remove_at(index);

func _process(delta):
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player);
		_label.text =  base_text + active_areas.front().action_name;
		_label.global_position = active_areas.front().global_position;
		_label.global_position.y -= 48;
		_label.global_position.x -= _label.size.x * 0.5;
		_label.show();
		active_areas.front().stair.call();
	else:
		_label.hide();

func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = _player.global_position.distance_squared_to(area1.global_position);
	var area2_to_player = _player.global_position.distance_squared_to(area2.global_position);
	return area1_to_player < area2_to_player;

func _input(event):
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false;
			_label.hide();
			
			await active_areas.front().interact.call();
			
			can_interact = true;
