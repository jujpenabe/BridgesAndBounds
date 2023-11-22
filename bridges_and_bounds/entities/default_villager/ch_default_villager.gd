extends CharacterBody2D

enum {
	IDLE,
	NEW_DIR,
	MOVE,
}

var _speed = 45;
var current_state = IDLE;
var current_dir = Vector2.RIGHT;
var far_distance = 0;
var is_following = false;

@onready var sprite_2d = $Sprite2D
@onready var interaction_area = $InteractionArea
@onready var _player = get_tree().get_first_node_in_group("player");

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact");
	interaction_area.stair = Callable(self, "_on_stair");
	randomize();

func _process(delta: float) -> void:
	match current_state:
		IDLE:
			sprite_2d.animation = "idle"
		NEW_DIR:
			if is_following:
				#check if the player is to the left or right of the NPC.
				current_state = MOVE;
				if _player.position.x > position.x + 75:
					current_dir = Vector2.RIGHT;
					sprite_2d.flip_h = false;
					_speed = move_toward(_speed, 120, _choose([10, 15]));
				elif _player.position.x < position.x - 75:
					current_dir = Vector2.LEFT;
					sprite_2d.flip_h = true;
					_speed = move_toward(_speed, 120, _choose([10, 15]));
				elif _player.position.x < position.x + 75 && _player.position.x > position.x + 25:
					current_dir = Vector2.RIGHT;
					sprite_2d.flip_h = false;
					_speed = move_toward(_speed, 60, 15);
				elif _player.position.x > position.x - 75 && _player.position.x < position.x - 25:
					current_dir = Vector2.LEFT;
					sprite_2d.flip_h = true;
					_speed = move_toward(_speed, 60, 15);
				else:
					current_state = IDLE;
			else:
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
	position += current_dir * _speed * delta;
	sprite_2d.animation = "walking"

func _choose(array):
	array.shuffle();
	return array.front();

func _on_timer_timeout() -> void:
	if is_following:
		# If the player is following, set the current state to NEW_DIR.
		current_state = NEW_DIR;
	else:
		# If the player is not following, set the current state to IDLE.
		current_state = _choose([IDLE, NEW_DIR, MOVE]);

	# If current state is MOVE, set the wait_time to 0.5.
	if current_state == IDLE:
		if is_following:
			$Timer.wait_time = _choose([0.5, 1]);
		else:
			$Timer.wait_time = _choose([1.5, 2, 4, 8]);
	else:
		if is_following:
			$Timer.wait_time = _choose([0.5, 1]);
		else:
			$Timer.wait_time = _choose([0.5, 1, 1.5]);
func _on_interact() -> void:
	# Add to the player's followers.
	_player.register_follower(self);
	InteractionManager.unregister_area(interaction_area);
	interaction_area.monitoring = false;

	is_following = true;
	current_state = NEW_DIR;

func _on_stair() -> void:
	current_state = IDLE;

