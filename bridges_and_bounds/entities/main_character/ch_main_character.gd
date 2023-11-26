extends CharacterBody2D
class_name Player

var _speed = 100.0
@onready var sprite_2d = $Sprite2D
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
		sprite_2d.animation = "walking"
	else:
		sprite_2d.animation = "idle"

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed/15)

	move_and_slide()

	var isLeft = velocity.x < 0;
	sprite_2d.flip_h = isLeft;

# Register new followers.
func register_follower(vill: Villager) -> void:
	match vill.type:
		0:
			type_a_followers.append(vill)
			print("Registered follower of type A.")
		1:
			type_b_followers.append(vill)
			print("Registered follower of type B.")
		2:
			type_c_followers.append(vill)
			print("Registered follower of type C.")
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