extends Node

# Game Manager Script to manage the game

# Reference to the player
@onready var _player = get_tree().get_first_node_in_group("player")

var _total_villagers = 0

var _villager_spawners = []
var _spawn_timer = 0

func _ready() -> void:
	# get all the villager spawners
	_villager_spawners = get_tree().get_nodes_in_group("spawner")
	#UIManager.update_ui()

func _process(delta):
	# if the amount of villagers is less than 15, spawn more
	if _villager_spawners.size() == 0:
		return

	if get_total_villagers() < 15:
		_spawn_timer += delta
		if _spawn_timer > 5:
			_spawn_timer = 0
			_spawn_villager()


func _input(event):
	if event.is_action_pressed("add"):
		UIManager.display_ui()
	if event.is_action_pressed("exit"):
		# exit application
		get_tree().quit()

func sort_by_distance_to_player(area1, area2) -> bool:
	var area1_to_player = _player.global_position.distance_squared_to(area1.global_position);
	var area2_to_player = _player.global_position.distance_squared_to(area2.global_position);
	return area1_to_player < area2_to_player;

# function to assign follower to the post
func assign_follower_to_post(type: int, post: Post):
	_player.assign_followers(type, post);
# function to remove follower from the post
func assign_follower_from_post(vill: Villager):
	_player.register_follower(vill);

func get_player_followers(type: int):
	match type:
		0:
			return _player.type_a_followers.size()
		1:
			return _player.type_b_followers.size()
		2:
			return _player.type_c_followers.size()
		_:
			return []
func get_total_villagers():
	_total_villagers = get_tree().get_nodes_in_group("villager").size()
	return _total_villagers # could be optimized by storing the value

func get_following_villagers():
	return get_tree().get_nodes_in_group("following").size()

func get_sleeping_villagers():
	return get_tree().get_nodes_in_group("sleeping").size()

func _spawn_villager():
	# spawn on a random spawner
	var spawner = _villager_spawners[randi() % _villager_spawners.size()]
	# calculate the type of villager to spawn based on the amount of villagers of each type
	var type_a = _player.type_a_followers.size()
	var type_b = _player.type_b_followers.size()
	var type_c = _player.type_c_followers.size()
	# the type with the least amount has the highest chance of spawning
	var type = 0
	if type_a < type_b and type_a < type_c:
		type = 0
	elif type_b < type_a and type_b < type_c:
		type = 1
	elif type_c < type_a and type_c < type_b:
		type = 2
	else:
		type = randi() % 3
	# the index is a random number between 0 and 11
	var idx = randi() % 12
	spawner.spawn_villager(type, idx)

func game_over():
	UIManager.display_game_over()
