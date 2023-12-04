extends Node2D


@onready var _player = get_tree().get_first_node_in_group("player");
@onready var _followers_banner: TextureRect = %FollowersBanner;
@onready var _timer = %Timer;

const base_text = ""

var active_areas = [];
var can_register = true;
var _followers_banner_init_pos: Vector2;

# on ready
func _ready():
	_followers_banner.hide();
	_followers_banner_init_pos = _followers_banner.position;

func register_area(area: InteractionArea):
	active_areas.push_back(area);

func unregister_area(area: InteractionArea):
	area.unfocus.call();
	var index = active_areas.find(area);
	if index != -1:
		active_areas.remove_at(index);
	# if there are no more areas, hide the banner
	if active_areas.size() == 0:
		_timer.start(1);

func _process(delta):
	active_areas.sort_custom(_sort_by_distance_to_player);
	if active_areas.size() > 0:
		_display_followers();
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

		if event.is_action_released("order_type_a"):
			active_areas.front().cancel_a_order.call();
		if event.is_action_released("order_type_b"):
			active_areas.front().cancel_b_order.call();
		if event.is_action_released("order_type_c"):
			active_areas.front().cancel_c_order.call();

# function to assign follower to the post
func assign_follower_to_post(type: int, post: Post, offset = 0):
	_player.assign_followers(type, post, offset);

# function to remove follower from the post
func assign_follower_from_post(vill: Villager):
	_player.register_follower(vill);

func _display_followers() -> void:
	# if is not visible, show it
	if not _followers_banner.visible:
		_followers_banner.show();
		var tween = create_tween().set_parallel(true);
		tween.tween_property(_followers_banner, "modulate", Color.WHITE, 0.2)
		tween.tween_property(_followers_banner, "position", _followers_banner_init_pos, 0.2)

func _hide_followers() -> void:
	if _followers_banner.visible:
		var tween = create_tween().set_parallel(true);
		tween.tween_property(_followers_banner, "modulate", Color.TRANSPARENT, 0.4)
		tween.tween_property(_followers_banner, "position", _followers_banner.position + Vector2(0, _followers_banner.size.y), 0.4)
		tween.chain().tween_callback(_followers_banner.hide)
		_timer.stop();

func _on_timer_timeout():
	# fade in the followers banner
	_hide_followers();
