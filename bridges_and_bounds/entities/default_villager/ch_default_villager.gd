extends CharacterBody2D

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

const SPEED = 30;
var current_state = IDLE;
var current_dir = Vector2.RIGHT;
var far_distance = 0;
@onready var sprite_2d = $Sprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	randomize();

func _process(delta: float) -> void:
	match current_state:
		IDLE:
			sprite_2d.animation = "idle"
			pass;
		NEW_DIR:
		# If the far distance is greater than 0, add another Vector2.LEFT to the choose array.
			var array = [Vector2.RIGHT, Vector2.LEFT];
			if far_distance > 0:
				# Make array based on far_distance.
				for i in range(far_distance):
					array.append(Vector2.LEFT);
				current_dir = _choose(array);
			else:
				# Make array based on far_distance.
				for i in range(abs(far_distance)):
					array.append(Vector2.RIGHT);
				current_dir = _choose(array);
		# If the current direction is Vector2.RIGHT, set the sprite's flip_h to false.
			if current_dir == Vector2.RIGHT:
				sprite_2d.flip_h = false;
				far_distance += 1;
			else:
				sprite_2d.flip_h = true;
				far_distance -= 1;
			current_state = MOVE;
		MOVE:
			_move(delta);


func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta


	move_and_slide()

func _move(delta):
	position += current_dir * SPEED * delta;
	sprite_2d.animation = "walking"


func _choose(array):
	array.shuffle();
	return array.front();


func _on_timer_timeout() -> void:
	current_state = _choose([IDLE, NEW_DIR, MOVE]);
	# If current state is MOVE, set the wait_time to 0.5.
	if current_state == IDLE:
		$Timer.wait_time = _choose([1.5, 2, 4, 8]);
	else:
		$Timer.wait_time = _choose([0.5, 1, 1.5]);
