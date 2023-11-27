extends CharacterBody2D

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

const SPEED = 30;
var current_state = IDLE;
var current_dir = Vector2.RIGHT;


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	randomize();

func _process(delta: float) -> void:
	match current_state:
		IDLE:
			pass;
		NEW_DIR:
			current_dir = _choose([Vector2.RIGHT, Vector2.LEFT]);
		MOVE:
			_move(delta);


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func _move(delta):
	position += current_dir * SPEED * delta;
	
func _choose(array):
	array.shuffle();
	return array.front();


func _on_timer_timeout() -> void:
	$Timer.wait_time = _choose([1, 2, 3]);
	current_state = _choose([IDLE, NEW_DIR, MOVE]);
