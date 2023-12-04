extends RigidBody2D
class_name Post

@onready var _interaction_area = %InteractionArea
@onready var _sprite = %Facade
@onready var _label = %Label
@onready var _production_timer = %PTimer
@onready var _production_stream_player1 = %ProductionStreamPlayer1
@onready var _a_timer = %ATimer
@onready var _b_timer = %BTimer
@onready var _c_timer = %CTimer

@export var _facade: CompressedTexture2D
@export var _description_text: String = "Post"
@export var _max_villagers: int = 5
@export var _max_effort: int = 10
@export var _max_resources: int = 5
@export var _resources: int = 0
@export_enum("Chop", "Farm", "Cook", "Build") var type: int = 0;


var _a_villagers: Array = []
var _b_villagers: Array = []
var _c_villagers: Array = []

var _random: RandomNumberGenerator = RandomNumberGenerator.new()
var _offset: int = 0
var _effort = 0
var _can_cancel = true
var _type_text = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_interaction_area.interact = Callable(self, "_on_interact")
	_interaction_area.a_order = Callable(self, "_on_a_order")
	_interaction_area.b_order = Callable(self, "_on_b_order")
	_interaction_area.c_order = Callable(self, "_on_c_order")

	_interaction_area.cancel_a_order = Callable(self, "_on_cancel_a_order")
	_interaction_area.cancel_b_order = Callable(self, "_on_cancel_b_order")
	_interaction_area.cancel_c_order = Callable(self, "_on_cancel_c_order")

	_interaction_area.stair = Callable(self, "_on_stair")
	_interaction_area.unfocus = Callable(self, "_on_unfocus")

	_label.text = _description_text
	_label.global_position = _interaction_area.global_position
	_label.global_position.y -= 32
	_label.global_position.x -= _label.size.x * 0.5

	_production_stream_player1.position = position
	# replace the sprite with the facade if not empty
	if _facade != null:
		_sprite.texture = _facade
		add_child(_sprite)

	match type:
		0:
			_type_text = "Wood"
		1:
			_type_text = "Wheat"
		2:
			_type_text = "Food"
		3:
			_type_text = ""
	_label.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_to_pool(vill: Villager) -> void:
	if is_pool_full():
		return
	# start the production timer if it is not running
	if _production_timer.is_stopped():
		_production_timer.start(2)
	# update the far distance of the villager
	vill.set_far_distance(position.x + _offset)
	# move the villager to the corresponding post
	match type:
		0:
			vill.set_sprite_position(Vector2(0, - 32), 0.6, 2)
		1:
			vill.set_sprite_position(Vector2(0, - 16), 0.6, 2)
		2:
			vill.set_sprite_position(Vector2(0, - 16), 0.6, 2)
		3:
			vill.set_sprite_position(Vector2(0, _random.randi_range(-4,4)), 2)
	match vill.type:
		0:
			_a_villagers.append(vill)
		1:
			_b_villagers.append(vill)
		2:
			_c_villagers.append(vill)

func remove_from_pool(vill_type: int) -> void:
	# if there are no villagers in the pool return stop work
	if _a_villagers.size() + _b_villagers.size() + _c_villagers.size() == 0:
		_stop_production()
		return
	match vill_type:
		0:
			if _a_villagers.size() == 0:
				return
			_a_villagers.pop_front().follow_player()
		1:
			if _b_villagers.size() == 0:
				return
			_b_villagers.pop_front().follow_player()
		2:
			if _c_villagers.size() == 0:
				return
			_c_villagers.pop_front().follow_player()

func is_pool_full() -> bool:
	return (_a_villagers.size() + _b_villagers.size() + _c_villagers.size()) >= _max_villagers

func _on_body_exited(body:Node) -> void:
	pass # Replace with function body.

func _on_interact() -> void:
	# empty for now
	pass # Replace with function body.

func _on_a_order() -> void:
	_a_timer.start()
	_can_cancel = true

func _on_b_order() -> void:
	_b_timer.start()
	_can_cancel = true

func _on_c_order() -> void:
	_c_timer.start()
	_can_cancel = true

func _on_stair() -> void:
	# if the pool is not full display the current number of villagers / the max
	# modulate the text back to white
	#_label.modulate = Color(1, 1, 1, 1)
	if !is_pool_full():
		# if pool is empty display 0/5 and the description text

		if _a_villagers.size() + _b_villagers.size() + _c_villagers.size() == 0:
			_label.text = _description_text
			_label.global_position = _interaction_area.global_position
			_label.global_position.y -= 32
			_label.global_position.x -= _label.size.x * 0.5
			_label.show()
		else:
			_label.text = _type_text + ": " + str(_resources) + "/" + str(_max_resources) + "\n" + str( _a_villagers.size() + _b_villagers.size() + _c_villagers.size()) + "/" + str(_max_villagers)
			_label.global_position = _interaction_area.global_position
			_label.global_position.y -= 16
			_label.global_position.x -= _label.size.x * 0.5
			_label.show()

	elif is_pool_full():
		_label.text = _type_text + ": " + str(_resources) + "/" + str(_max_resources) + "\n" + str( _a_villagers.size() + _b_villagers.size() + _c_villagers.size()) + "/" + str(_max_villagers)
		_label.global_position = _interaction_area.global_position
		_label.global_position.y -= 16
		_label.global_position.x -= _label.size.x * 0.5
		_label.show()

func _on_unfocus() -> void:
	# empty for now
	pass # Replace with function body.

func _on_p_timer_timeout() -> void:
	match type:
		0:
			_produce()
		1:
			_produce()
		2:
			_produce()

	# wait 5 seconds and repeat

func _produce() -> void:
	if _a_villagers.size() + _b_villagers.size() + _c_villagers.size() == 0:
		return
	if !_production_stream_player1.is_playing:
		_production_stream_player1.play()
	var work = 0
	if _a_villagers.size() > 0:
		for vill in _a_villagers:
			if vill.type == type:
				work += 4
			if (vill.type + 1) % 3 == type:
				work += 2
			if (vill.type + 2) % 3 == type:
				work += 1
	if _b_villagers.size() > 0:
		for vill in _b_villagers:
			if vill.type == type:
				work += 4
			if (vill.type + 1) % 3 == type:
				work += 2
			if (vill.type + 2) % 3 == type:
				work += 1
	if _c_villagers.size() > 0:
		for vill in _c_villagers:
			if vill.type == type:
				work += 4
			if (vill.type + 1) % 3 == type:
				work += 2
			if (vill.type + 2) % 3 == type:
				work += 1

	_effort += work

	if _effort >= _max_effort:
		# append a new item to the lots array and spawn a notification above the post
		# to notify the player that the post produced a new resource, the sound is louder when the post is full
		# and the notification is bigger
		# the notification is a label that fades out after 2 seconds
		_effort = 0
		# if the resources size is not full add a new resource
		# produce according to the type of post
		if _resources < _max_resources:
			_resources += 1
			_label.global_position = _interaction_area.global_position
			_label.global_position.y -= 16
			_label.global_position.x -= _label.size.x * 0.5
			_label.text = "+1 "
			_label.show()

		# check if the resources are empty, half full or full and move the region rect +/- 32 pixels accordingly
		# if the resources are full play a sound
		# if the resources are empty play a sound
		# if the resources are half full play a sound
		if _resources < _max_resources * 0.2 || _resources == 0:
			# play the empty sound
			_sprite.region_rect = Rect2(0, 0, 32, 32)
		elif _resources >= _max_resources * 0.2 && _resources < _max_resources * 0.8:
			# play the half full sound
			_sprite.region_rect = Rect2(32, 0, 32, 32)
		elif _resources >= _max_resources * 0.8 || _resources == _max_resources:
			# play the full sound
			_sprite.region_rect = Rect2(64, 0, 32, 32)
		# reset the progress to 0
		_production_timer.wait_time = 1

	else:
		_label.hide()
		_production_timer.wait_time = 5

	# print the work of resources produced

func _on_a_timer_timeout() -> void:
	remove_from_pool(0)
	_can_cancel = false

func _on_b_timer_timeout() -> void:
	remove_from_pool(1)
	_can_cancel = false

func _on_c_timer_timeout() -> void:
	remove_from_pool(2)
	# can remove from pool false
	_can_cancel = false

func _on_cancel_a_order() -> void:
	if _a_timer.time_left < _a_timer.wait_time && _can_cancel:
		if !is_pool_full():
			InteractionManager.assign_follower_to_post(0, self)
	_a_timer.stop()

func _on_cancel_b_order() -> void:
	if _b_timer.time_left < _b_timer.wait_time && _can_cancel:
		if !is_pool_full():
			InteractionManager.assign_follower_to_post(1, self)
	_b_timer.stop()

func _on_cancel_c_order() -> void:
	if _c_timer.time_left < _c_timer.wait_time && _can_cancel:
		if !is_pool_full():
			InteractionManager.assign_follower_to_post(2, self)
	_c_timer.stop()

func _stop_production() -> void:
	_production_timer.stop()
	_a_timer.stop()
	_b_timer.stop()
	_c_timer.stop()
	_effort = 0
	_can_cancel = true
	if _production_stream_player1.is_playing:
		_production_stream_player1.stop()
