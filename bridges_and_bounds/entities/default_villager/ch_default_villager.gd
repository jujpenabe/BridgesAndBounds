extends CharacterBody2D
class_name Villager

enum {
	IDLE,
	NEW_DIR,
	MOVE,
	WORKING
}
@export_enum("A", "B", "C") var type: int = 0;
@export var _speed = 30;
var _current_state = IDLE;
var current_dir = Vector2.RIGHT;
var far_distance = 0;
var is_following = false;
var is_working = false;

@onready var _rich_text_label = %RichTextLabel;
@onready var sprite_2d = $Sprite2D
@onready var interaction_area = $InteractionArea
@onready var _player = get_tree().get_first_node_in_group("player");

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact");
	interaction_area.a_order = Callable(self, "_on_a_order");
	interaction_area.stair = Callable(self, "_on_stair");
	interaction_area.unfocus = Callable(self, "_on_unfocus");
	_rich_text_label.hide();
	randomize();

func _process(delta: float) -> void:
	match _current_state:
		IDLE:
			sprite_2d.animation = "idle"
		NEW_DIR:
			if is_following:
				# If the player is following, set the current state to NEW_DIR.
				#check if the player is to the left or right of the NPC.
				if _player.position.x >= position.x + 100:
					sprite_2d.flip_h = false;
					current_dir = Vector2.RIGHT;
				elif _player.position.x <= position.x - 100:
					sprite_2d.flip_h = true;
					current_dir = Vector2.LEFT;
				elif _player.position.x < position.x + 100 && _player.position.x >= position.x + 25:
					sprite_2d.flip_h = false;
					current_dir = Vector2.RIGHT;
				elif _player.position.x > position.x - 100 && _player.position.x <= position.x - 25:
					sprite_2d.flip_h = true;
					current_dir = Vector2.LEFT;
				elif _player.position.x < position.x + 25 && _player.position.x > 0:
					sprite_2d.flip_h = false;
					current_dir = Vector2.RIGHT;
				elif _player.position.x > position.x - 25 && _player.position.x <=0:
					sprite_2d.flip_h = true;
					current_dir = Vector2.LEFT;
				else:
					pass;
			else:
				# If the far distance is greater than 0, add another Vector2.LEFT to the choose array.
				var array = [Vector2.RIGHT, Vector2.LEFT];
				if far_distance > 0:
					# Make array based on far_distance.
					for i in range(abs(int(far_distance))):
						array.append(Vector2.LEFT);
					current_dir = _choose(array);
				else:
					# Make array based on far_distance.
					for i in range(abs(int(far_distance))):
						array.append(Vector2.RIGHT);
					current_dir = _choose(array);
			# If the current direction is Vector2.RIGHT, set the sprite's flip_h to false.
			if current_dir == Vector2.RIGHT:
				sprite_2d.flip_h = false;
			else:
				sprite_2d.flip_h = true;
			_current_state = MOVE;
		MOVE:
			if is_following:
				if _player.position.x >= position.x + 100:
					_speed = move_toward(_speed, 90, _choose([5, 10]));
				elif _player.position.x <= position.x - 100:
					_speed = move_toward(_speed, 90, _choose([5, 10]));
				elif _player.position.x < position.x + 100 && _player.position.x >= position.x + 25:
					_speed = move_toward(_speed, 60, 10);
				elif _player.position.x > position.x - 100 && _player.position.x <= position.x - 25:
					_speed = move_toward(_speed, 60, 10);
				elif _player.position.x < position.x + 25 && _player.position.x > 0:
					_speed = move_toward(_speed, 30, 5);
				elif _player.position.x > position.x - 25 && _player.position.x < 0:
					_speed = move_toward(_speed, 30, 5);
				else:
					_current_state = IDLE
			elif is_working:
				if far_distance > 50:
					_speed = move_toward(_speed, 60, 5);
				elif far_distance <= 50 &&  far_distance >= 0:
					_speed = move_toward(_speed, 30, 10);
				elif far_distance < 0 && far_distance > -50:
					_speed = move_toward(_speed, 30, 10);
				elif far_distance <= -50:
					_speed = move_toward(_speed, 60, 5);
			_move(delta);
		WORKING:
			sprite_2d.animation = "working"

func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _move(delta):
	var _delta = current_dir * _speed * delta;
	far_distance += _delta.x;
	position += _delta;
	sprite_2d.animation = "walking"

func _choose(array):
	array.shuffle();
	return array.front();

func _on_timer_timeout() -> void:
	match  _current_state:
		IDLE:
			if is_following:
				if _player.position.x >= position.x + 75 || _player.position.x <= position.x - 75:
					_current_state = _choose([NEW_DIR, MOVE, NEW_DIR]);
				else:
					_current_state = _choose([NEW_DIR, IDLE, IDLE, IDLE]);

				if _current_state == NEW_DIR:
					$Timer.wait_time = _choose([0.2, 0.2, 0.4]);
				elif _current_state == IDLE:
					$Timer.wait_time = _choose([0.8, 1.6, 2.4, 3.2]);
				else:
					$Timer.wait_time = _choose([0.4, 0.6]);
			elif is_working:
				if far_distance > 75:
					_current_state = _choose([NEW_DIR]);
				elif far_distance <= 75 &&  far_distance >= 0:
					_current_state = _choose([NEW_DIR, WORKING, WORKING]);
				elif far_distance < 0 && far_distance > -75:
					_current_state = _choose([NEW_DIR, WORKING, WORKING, IDLE]);
				elif far_distance <= -75:
					_current_state = _choose([NEW_DIR]);

				match _current_state:
					NEW_DIR:
						$Timer.wait_time = _choose([0.2, 0.4, 0.4]);
					WORKING:
						$Timer.wait_time = _choose([1, 1, 2]);
					IDLE:
						$Timer.wait_time = _choose([0.4, 0.6]);
			else:
				_current_state = _choose([NEW_DIR, IDLE, IDLE]);
				$Timer.wait_time = _choose([1.5, 2, 4, 8]);
		NEW_DIR:
			print("NEW_DIR");
		MOVE:
			if is_following:
				if _player.position.x >= position.x + 75 || _player.position.x <= position.x - 75:
					_current_state = _choose([NEW_DIR, NEW_DIR, NEW_DIR, IDLE]);
				else:
					_current_state = _choose([NEW_DIR, IDLE, IDLE, IDLE]);
				if _current_state == NEW_DIR:
					$Timer.wait_time = _choose([0.2, 0.2, 0.4]);
				elif _current_state == IDLE:
					$Timer.wait_time = _choose([1, 1.5]);
			elif is_working:
				if far_distance > 75:
					_current_state = _choose([NEW_DIR, IDLE]);
				elif far_distance <= 75 &&  far_distance >= 0:
					_current_state = _choose([NEW_DIR, WORKING, IDLE]);
				elif far_distance < 0 && far_distance > -75:
					_current_state = _choose([NEW_DIR, WORKING, WORKING, IDLE]);
				elif far_distance <= -75:
					_current_state = _choose([NEW_DIR, IDLE]);

				if _current_state == IDLE:
					$Timer.wait_time = _choose([0.4, 0.6]);
				elif _current_state == WORKING:
					$Timer.wait_time = _choose([2, 2, 4]);
			else:
				_current_state = _choose([NEW_DIR, MOVE, NEW_DIR]);
				if _current_state == NEW_DIR:
					$Timer.wait_time = _choose([0.6, 0.8]);
				elif _current_state == IDLE:
					$Timer.wait_time = _choose([2.4, 3.2]);
		WORKING:
			# If too far dont work.
			if far_distance > 50:
				_current_state = _choose([NEW_DIR, IDLE]);
			elif far_distance <= 50 &&  far_distance >= 0:
				_current_state = _choose([NEW_DIR, WORKING, IDLE]);
			elif far_distance < 0 && far_distance > -50:
				_current_state = _choose([NEW_DIR, WORKING, WORKING, IDLE]);
			elif far_distance <= -50:
				_current_state = _choose([NEW_DIR, IDLE]);

			if _current_state == WORKING:
				$Timer.wait_time = _choose([1, 1, 2]);
			elif _current_state == IDLE:
				$Timer.wait_time = _choose([1, 1, 2]);
			else:
				$Timer.wait_time = _choose([0.4, 0.4, 0.6]);

func assign_to_post(post) -> void:
	# Assign the NPC to a post.
	is_following = false;
	is_working = true;
	_current_state = NEW_DIR;
	# calculate far distance from current position to post position.
	far_distance = position.x - post.position.x;
	# Add to the pool of the pos
	post.add_to_pool(self);

func _on_interact() -> void:
	# Add to the player's followers.
	_player.register_follower(self);
	InteractionManager.unregister_area(interaction_area);
	interaction_area.monitoring = false;
	$Timer.start(0.2);
	is_following = true;
	_current_state = NEW_DIR;

func _on_a_order() -> void:
	# empty for now
	pass;

func _on_stair() -> void:
	# if typo is A color the character A in red.
	# if typo is B color the character B in green.
	# if typo is C color the character C in blue.
	match type:
		0:
			_rich_text_label.bbcode_text = "[center] add [color=#cc194c]A[/color] (s) [/center]"
		1:
			_rich_text_label.bbcode_text = "[center] add [color=#4ce619]B[/color] (s) [/center]"
		2:
			_rich_text_label.bbcode_text = "[center] add [color=#194ce6]C[/color] (s) [/center]"
	# modulate color of the last single character.

	_rich_text_label.global_position = global_position;
	_rich_text_label.global_position.y -= 48;
	_rich_text_label.global_position.x -= _rich_text_label.size.x * 0.5;
	_rich_text_label.show();
	_current_state = IDLE;

func _on_unfocus() -> void:
	_rich_text_label.hide();
	# _current_state = NEW_DIR;
