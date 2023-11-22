extends CharacterBody2D


var _speed = 100.0
@onready var sprite_2d = $Sprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var followers = []

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
func register_follower(follow: CharacterBody2D) -> void:
	followers.append(follow)
