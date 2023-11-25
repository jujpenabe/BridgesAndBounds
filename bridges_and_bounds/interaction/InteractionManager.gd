extends Node2D


@onready var _player = get_tree().get_first_node_in_group("player");
@onready var _rich_text_label = %RichTextLabel;
@onready var _timer = %Timer;

const base_text = ""

var active_areas = [];
var can_register = true;

# on ready
func _ready():
	_rich_text_label.hide();

func register_area(area: InteractionArea):
	active_areas.push_back(area);

func unregister_area(area: InteractionArea):
	area.unfocus.call();
	var index = active_areas.find(area);
	if index != -1:
		active_areas.remove_at(index);
	# if there are no more areas, hide the rich text label
	if active_areas.size() == 0:
		_timer.start(2);

func _process(delta):
	_display_followers();
	active_areas.sort_custom(_sort_by_distance_to_player);
	if active_areas.size() > 0:
		_rich_text_label.show();
		active_areas.front().stair.call();
		# call the unfocus method on the remaining areas
		for i in range(1, active_areas.size()):
			active_areas[i].unfocus.call();
		# display the total of followers
	else:
		# _rich_text_label.hide();
		# add a timer to hide after 2 seconds
		pass


func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = _player.global_position.distance_squared_to(area1.global_position);
	var area2_to_player = _player.global_position.distance_squared_to(area2.global_position);
	return area1_to_player < area2_to_player;

func _input(event):
	if active_areas.size() > 0:
		if event.is_action_pressed("add"):
			await active_areas.front().interact.call();
		if event.is_action_pressed("order_type_a"):
			active_areas.front().a_order.call();

		if event.is_action_pressed("order_type_b"):
			active_areas.front().b_order.call();
		if event.is_action_pressed("order_type_c"):
			active_areas.front().c_order.call();

# function to assign follower to the post
func assign_follower_to_post(type: int):
	_player.assign_followers(type, active_areas.front().get_parent());

func _display_followers() -> void:
	_rich_text_label.bbcode_text = "[center] Pacillences: \n" + "[color=red] A  [/color]" + str(_player.type_a_followers.size())  + " [color=green] B [/color]" + str(_player.type_b_followers.size()) + " [color=blue] C [/color]" + str(_player.type_c_followers.size())+"[/center]";
	_rich_text_label.global_position = _player.camera.global_position;
	_rich_text_label.global_position.y -= 128;
	_rich_text_label.global_position.x -= _rich_text_label.size.x / 2;
	print("It works")

func _on_timer_timeout():
	_rich_text_label.hide();
	_timer.stop();
