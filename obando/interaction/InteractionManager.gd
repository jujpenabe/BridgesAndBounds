extends Node2D

var active_areas = [];
var can_register = true;

func register_area(area: InteractionArea):
	active_areas.push_back(area);

func unregister_area(area: InteractionArea):
	area.unfocus.call();
	var index = active_areas.find(area);
	if index != -1:
		active_areas.remove_at(index);
	# if there are no more areas, hide the banner
	#if active_areas.size() == 0:
	#	UIManager.start_timer(1.2);

func _process(delta):
	active_areas.sort_custom(GameManager.sort_by_distance_to_player);
	if active_areas.size() > 0:
		UIManager.display_ui()
		active_areas.front().stair.call();
		# call the unfocus method on the remaining areas
		for i in range(1, active_areas.size()):
			active_areas[i].unfocus.call();
	else:
		# _rich_text_label.hide();
		pass

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
