extends RigidBody2D
class_name Post

@onready var _interaction_area = %InteractionArea
@onready var _sprite = %Sprite2D
@onready var _label = %Label
@onready var _timer = %Timer

@export var _max_villagers: int = 5
@export var _max_effort: int = 10
@export var _max_resources: int = 5
@export_enum("A", "B", "C") var type: int = 0;


var _villagers: Array = []
var _wood: int = 0

var _effort = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_interaction_area.interact = Callable(self, "_on_interact")
	_interaction_area.a_order = Callable(self, "_on_a_order")
	_interaction_area.b_order = Callable(self, "_on_b_order")
	_interaction_area.c_order = Callable(self, "_on_c_order")
	_interaction_area.stair = Callable(self, "_on_stair")
	_interaction_area.unfocus = Callable(self, "_on_unfocus")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move Sprite Region to the right
	pass

func add_to_pool(vill: Villager) -> void:
	if is_pool_full():
		return
	_villagers.append(vill)

func is_pool_full() -> bool:
	return _villagers.size() >= _max_villagers


func _on_body_exited(body:Node) -> void:
	pass # Replace with function body.

func _on_interact() -> void:
	# empty for now
	pass # Replace with function body.

func _on_a_order() -> void:
	# if the player has villagers in the pool and the post is not full assign them to the post pool
	if is_pool_full():
		return
	InteractionManager.assign_follower_to_post(0)

func _on_b_order() -> void:
	# if the player has villagers in the pool and the post is not full assign them to the post pool
	if is_pool_full():
		return
	InteractionManager.assign_follower_to_post(1)

func _on_c_order() -> void:
	# if the player has villagers in the pool and the post is not full assign them to the post pool
	if is_pool_full():
		return
	InteractionManager.assign_follower_to_post(2)

func _on_stair() -> void:
	# if the pool is not full display the current number of villagers / the max
	if !is_pool_full():
		_label.text = str(_villagers.size()) + "/" + str(_max_villagers)
		_label.global_position = _interaction_area.global_position
		_label.global_position.y -= 32
		_label.global_position.x -= _label.size.x * 0.5
		_label.show()
	
	# else print "Full"
	elif is_pool_full():
		_label.text = "Full"
		_label.global_position = _interaction_area.global_position
		_label.global_position.y -= 32
		_label.global_position.x -= _label.size.x * 0.5
		_label.show()

func _on_unfocus() -> void:
	# empty for now
	pass # Replace with function body.

# On timer timeout calculate the work of resources to produce every 5 seconds (add to a pool)
# based on the number of villagers in the pool and the type of them (A, B, C)
# according to the post type (A, B, C) some produce more than others
func _on_timer_timeout() -> void:
	match type:
		0:
			_produce()
		1:
			_produce()
		2:
			_produce()

	# wait 5 seconds and repeat

func _produce() -> void:
	var work = 0
	if _villagers.size() > 0:
		for vill in _villagers:
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
			if _wood < _max_resources:
				_wood += 1
			# reset the progress to 0
			_label.hide()

		# print the work of resources produced
		print("Current villagers: " + str(_villagers.size()) + "Work: " + str(work) + "Progress: " + str(_effort) + " total resources: " + str(_wood))
		_timer.wait_time = 5



