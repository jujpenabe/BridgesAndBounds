extends CharacterBody2D
class_name Player

var _speed = 100.0
@onready var _sound_pool_2d: SoundPool2D = %SoundPool2D
@onready var _main_character = %Main
@onready var _mount = %Mount
# get reference of the camera
@onready var camera = %Camera2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var type_a_followers = []
var type_b_followers = []
var type_c_followers = []

func _process(delta: float) -> void:
	pass

func _physics_process(delta):

	# Animations
	if (velocity.x > 1 || velocity.x < -1):
		_main_character.animation = "walking"
		_mount.animation = "walking"
	else:
		_main_character.animation = "idle"
		_mount.animation = "idle"

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed/10)

	move_and_slide()

	var isLeft = velocity.x < 0;
	if (velocity.x != 0):
		_main_character.flip_h = isLeft;
		_mount.flip_h = isLeft;
		_play_footstep_sounds();
		if (isLeft):
			_mount.offset.x = -6;
		else:
			_mount.offset.x = 6;

# Register new followers.
func register_follower(vill: Villager) -> void:
	match vill.type:
		0:
			type_a_followers.append(vill)
		1:
			type_b_followers.append(vill)
		2:
			type_c_followers.append(vill)
		_:
			print("Error: Invalid follower type.")

func assign_followers(type: int, post: Post) -> void:
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

func _play_footstep_sounds() -> void:
	_sound_pool_2d.play_random_sound(-6)
	_sound_pool_2d.set_pool_position(global_position)
