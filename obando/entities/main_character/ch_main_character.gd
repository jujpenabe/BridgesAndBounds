extends CharacterBody2D
class_name Player

enum {
	IDLE,
	MOVE,
	ORDER
}

@onready var _donkey_sound_pool: SoundPool2D = %DonkeySoundPool
@onready var _walking_sound_pool: SoundPool2D = %WalkingSoundPool
@onready var _dialogue_sound_pool: SoundPool2D = %DialogueSoundPool
@onready var _main_character = %Main
@onready var _mount = %Mount
# get reference of the camera
@onready var camera = %Camera2D
@onready var _order_timer = %OrderTimer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var type_a_followers = []
var type_b_followers = []
var type_c_followers = []
var _speed = 60
var _current_state = IDLE
var _is_ordering = false
var _current_followers: int = 0

var _random: RandomNumberGenerator = RandomNumberGenerator.new()


func _process(delta: float) -> void:
	match _current_state:
		IDLE:
			if (_is_ordering):
				_main_character.animation = "order"
			else:
				_main_character.animation = "idle"
				_mount.animation = "idle"
				_play_donkey_sound(0.01)
		MOVE:
			_mount.animation = "walking"
			if (_is_ordering):
				_main_character.animation = "order"
			else:
				_main_character.animation = "walking"
				_play_donkey_sound(0.005)
			_play_footstep_sounds();

		ORDER:
			_main_character.animation = "order"
		_:
			print("Error: Invalid state.")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed/10)


	# Animations
	if (velocity.x > 1 || velocity.x < -1):
		_current_state = MOVE
	else:
		_current_state = IDLE

	var isLeft = velocity.x < 0;
	if (velocity.x != 0):
		_main_character.flip_h = isLeft;
		_mount.flip_h = isLeft;
		if (isLeft):
			_mount.offset.x = -6;
		else:
			_mount.offset.x = 6;

	move_and_slide()

func _input(event):
	if event.is_action_pressed("add"):
		_main_character.animation = "order"
		_is_ordering = true
		_order_timer.start(1)
		_play_dialogue_sound(_random.randf_range(0.95, 1.05))

func _on_order_timer_timeout() -> void:
	_is_ordering = false

# Register new followers.
func register_follower(vill: Villager) -> void:
	if vill._is_tired:
		vill.add_stamina(50)
	match vill.type:
		0:
			type_a_followers.append(vill)
		1:
			type_b_followers.append(vill)
		2:
			type_c_followers.append(vill)
		_:
			print("Error: Invalid follower type.")
	_current_followers += 1

func unregister_follower(vill: Villager) -> void:
	match vill.type:
		0:
			type_a_followers.erase(vill)
		1:
			type_b_followers.erase(vill)
		2:
			type_c_followers.erase(vill)
		_:
			print("Error: Invalid follower type.")
	_current_followers -= 1

func assign_followers(type: int, post: Post) -> void:
	if post.is_pool_full():
		return
	match type:
		0:
			# take the first follower from the list and change its status to working
			if (type_a_followers.size() == 0):
				return
			type_a_followers.pop_front().assign_to_post(post)
		1:
			# take the first follower from the list and change its status to working
			if (type_b_followers.size() == 0):
				return
			type_b_followers.pop_front().assign_to_post(post)
		2:
			# take the first follower from the list and change its status to working
			if (type_c_followers.size() == 0):
				return
			type_c_followers.pop_front().assign_to_post(post)
		_:
			print("Error: Invalid follower type.")
	_current_followers -= 1

func _play_footstep_sounds() -> void:
	_walking_sound_pool.play_random_sound(_random.randi_range(-18, -6), _random.randf_range(0.95, 1.05))
	_walking_sound_pool.set_pool_position(global_position)

func _play_dialogue_sound(pitch: float = 1) -> void:
	_dialogue_sound_pool.play_random_sound(_random.randi_range(-8, -4), pitch);
	_dialogue_sound_pool.set_pool_position(global_position)

func _play_donkey_sound(rng: float) -> void:
	_donkey_sound_pool.play_random_sound(_random.randi_range(-18, -12), _random.randf_range(0.95, 1.05), rng);
	_donkey_sound_pool.set_pool_position(global_position)

func get_current_followers() -> int:
	return _current_followers
