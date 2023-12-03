extends CharacterBody2D
class_name Villager

enum {
	IDLE,
	NEW_DIR,
	MOVE,
	WORKING
}
@export_enum("A", "B", "C",) var type: int = 0;
@export var _speed = 30;
@export_range (0, 11) var _sprite_2d_index: int;

@onready var _rich_text_label = %RichTextLabel;
@onready var sprites_2d: Array[AnimatedSprite2D]
@onready var interaction_area = %InteractionArea
@onready var _villager_sprite_animations = %VillagerSpriteAnimations
@onready var _player = get_tree().get_first_node_in_group("player");
@onready var _walking_sound_pool: SoundPool2D = %WalkingSoundPool;

var _sprite_2d: AnimatedSprite2D = null;
var _current_state = IDLE;
var _current_dir = Vector2.RIGHT;
var _far_distance = 0;
var _is_following = false;
var _is_working = false;
var _current_work:int = 0;


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact");
	interaction_area.a_order = Callable(self, "_on_a_order");
	interaction_area.stair = Callable(self, "_on_stair");
	interaction_area.unfocus = Callable(self, "_on_unfocus");
	_rich_text_label.hide();
	for child in _villager_sprite_animations.get_children():
		if child is AnimatedSprite2D:
			sprites_2d.append(child);

	# set the sprite_2d to the first sprite in the array.
	_sprite_2d = sprites_2d[_sprite_2d_index];
	_sprite_2d.show();
	# add the sprite_2d to the root node.
	randomize();

func _process(delta: float) -> void:
	match _current_state:
		IDLE:
			_sprite_2d.animation = "idle"
		NEW_DIR:
			if _is_following:
				# If the player is following, set the current state to NEW_DIR.
				#check if the player is to the left or right of the NPC.
				if _player.position > position:
					_current_dir = Vector2.RIGHT;
				elif _player.position < position:
					_current_dir = Vector2.LEFT;
				else:
					pass;
			else:
				# If the far distance is greater than 0, add another Vector2.LEFT to the choose array.
				var array = [Vector2.RIGHT, Vector2.LEFT];
				if _far_distance > 0:
					# Make array based on _far_distance.
					for i in range(abs(int(_far_distance))):
						array.append(Vector2.LEFT);
					_current_dir = _choose(array);
				else:
					# Make array based on _far_distance.
					for i in range(abs(int(_far_distance))):
						array.append(Vector2.RIGHT);
					_current_dir = _choose(array);
			# If the current direction is Vector2.RIGHT, set the sprite's flip_h to false.
			if _current_dir == Vector2.RIGHT:
				_sprite_2d.flip_h = false;
			else:
				_sprite_2d.flip_h = true;
			_current_state = MOVE;
		MOVE:
			if _is_following:
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
			elif _is_working:
				if _far_distance > 50:
					_speed = move_toward(_speed, 60, 5);
				elif _far_distance <= 50 &&  _far_distance >= 0:
					_speed = move_toward(_speed, 30, 10);
				elif _far_distance < 0 && _far_distance > -50:
					_speed = move_toward(_speed, 30, 10);
				elif _far_distance <= -50:
					_speed = move_toward(_speed, 60, 5);
			_move(delta);
		WORKING:
			match _current_work:
				0:
					_sprite_2d.animation = "chopping"
				1:
					_sprite_2d.animation = "farming"
				2:
					_sprite_2d.animation = "cooking"
				3:
					_sprite_2d.animation = "building"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _move(delta):
	var _delta = _current_dir * _speed * delta;
	_far_distance += _delta.x;
	position += _delta;
	_sprite_2d.animation = "walking"
	_play_footsp_sounds();

func _choose(array):
	array.shuffle();
	return array.front();

func _on_timer_timeout() -> void:
	match  _current_state:
		IDLE:
			if _is_following:
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
			elif _is_working:
				if _far_distance > 75:
					_current_state = _choose([NEW_DIR]);
				elif _far_distance <= 75 &&  _far_distance >= 0:
					_current_state = _choose([NEW_DIR, WORKING, WORKING]);
				elif _far_distance < 0 && _far_distance > -75:
					_current_state = _choose([NEW_DIR, WORKING, WORKING, IDLE]);
				elif _far_distance <= -75:
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
			if _is_following:
				if _player.position.x >= position.x + 75 || _player.position.x <= position.x - 75:
					_current_state = _choose([NEW_DIR, NEW_DIR, NEW_DIR, NEW_DIR, IDLE]);
				else:
					_current_state = _choose([NEW_DIR, IDLE, IDLE, IDLE, IDLE]);
				if _current_state == NEW_DIR:
					$Timer.wait_time = _choose([0.2, 0.2, 0.4]);
				elif _current_state == IDLE:
					$Timer.wait_time = _choose([1, 1.5]);
			elif _is_working:
				if _far_distance > 75:
					_current_state = _choose([NEW_DIR, IDLE]);
				elif _far_distance <= 75 &&  _far_distance >= 0:
					_current_state = _choose([NEW_DIR, WORKING, IDLE]);
				elif _far_distance < 0 && _far_distance > -75:
					_current_state = _choose([NEW_DIR, WORKING, WORKING, IDLE]);
				elif _far_distance <= -75:
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
			if _far_distance > 50:
				_current_state = _choose([NEW_DIR, IDLE]);
			elif _far_distance <= 50 &&  _far_distance >= 0:
				_current_state = _choose([NEW_DIR, WORKING, WORKING, IDLE]);
			elif _far_distance < 0 && _far_distance > -50:
				_current_state = _choose([NEW_DIR, WORKING, WORKING, WORKING, IDLE]);
			elif _far_distance <= -50:
				_current_state = _choose([NEW_DIR, IDLE]);

			if _current_state == WORKING:
				$Timer.wait_time = _choose([1, 1, 2]);
			elif _current_state == IDLE:
				$Timer.wait_time = _choose([1, 1, 2]);
			else:
				$Timer.wait_time = _choose([0.4, 0.4, 0.6]);

func assign_to_post(post) -> void:
	# Assign the NPC to a post.
	_is_following = false;
	_is_working = true;
	_current_state = NEW_DIR;
	# calculate far distance from current position to post position.
	_far_distance = position.x - post.position.x;
	# Add to the pool of the pos
	post.add_to_pool(self);
	# set the animation based on the type of the post.
	_current_work = post.type;

func _on_interact() -> void:
	# Add to the player's followers.
	follow_player();

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

func follow_player() -> void:
	# Add to the player's followers.
	_player.register_follower(self);
	InteractionManager.unregister_area(interaction_area);
	interaction_area.monitoring = false;
	$Timer.start(0.2);
	_is_following = true;
	_is_working = false;
	_current_state = NEW_DIR;

func new_far_distance(point: int) -> void:
	_far_distance = position.x - point;

func _play_footsp_sounds() -> void:
	_walking_sound_pool.play_random_sound(-18);
	_walking_sound_pool.set_pool_position(global_position);
