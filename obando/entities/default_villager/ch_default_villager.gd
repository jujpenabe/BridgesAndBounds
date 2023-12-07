extends CharacterBody2D
class_name Villager

enum {
	IDLE,
	NEW_DIR,
	MOVE,
	WORKING
}
@export_enum("A", "B", "C",) var type: int = 0;
@export_range (0, 11) var sprite_index: int;

@onready var _player = get_tree().get_first_node_in_group("player");
@onready var _rich_text_label = %RichTextLabel;
@onready var sprites_2d: Array[AnimatedSprite2D]
@onready var interaction_area = %InteractionArea
@onready var _villager_sprite_animations = %VillagerSpriteAnimations
@onready var _spawn_position = global_position;

@onready var _walking_sound_pool: SoundPool2D = %WalkingSoundPool;
@onready var _chopping_sound_pool: SoundPool2D = %ChoppingSoundPool;
@onready var _farming_sound_pool: SoundPool2D = %FarmingSoundPool;
@onready var _cooking_sound_pool: SoundPool2D = %CookingSoundPool;
@onready var _hammer_sound_pool: SoundPool2D = %HammerSoundPool;
@onready var _woman_recruitment_sound_pool: SoundPool2D = %WomanRecruitmentSoundPool;
@onready var _man_recruitment_sound_pool: SoundPool2D = %ManRecruitmentSoundPool;

var _sprite_2d: AnimatedSprite2D = null;
var _current_state = IDLE;
var _current_dir = Vector2.RIGHT;

var _far_distance: float = 0;

var _is_following = false;
var _is_working = false;
var _is_tired = false;

var _working_post: Post = null;
var _current_work:int = 0;

var _speed:float = 30;
var _stamina:float = 200;

var _random: RandomNumberGenerator = RandomNumberGenerator.new()

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
	_sprite_2d = sprites_2d[sprite_index];
	_sprite_2d.show();
	# add the sprite_2d to the root node.
	set_group("sleeping");
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
					_speed = move_toward(_speed, 75, _choose([5, 10]));
				elif _player.position.x <= position.x - 100:
					_speed = move_toward(_speed, 75, _choose([5, 10]));
				elif _player.position.x < position.x + 100 && _player.position.x >= position.x + 25:
					_speed = move_toward(_speed, 50, 10);
				elif _player.position.x > position.x - 100 && _player.position.x <= position.x - 25:
					_speed = move_toward(_speed, 50, 10);
				elif _player.position.x < position.x + 25 && _player.position.x > 0:
					_speed = move_toward(_speed, 25, 5);
				elif _player.position.x > position.x - 25 && _player.position.x < 0:
					_speed = move_toward(_speed, 25, 5);
				else:
					_current_state = IDLE
			elif _is_working:
				if _far_distance > 50:
					_speed = move_toward(_speed, 50, 5);
				elif _far_distance <= 50 &&  _far_distance >= 0:
					_speed = move_toward(_speed, 25, 10);
				elif _far_distance < 0 && _far_distance > -50:
					_speed = move_toward(_speed, 25, 10);
				elif _far_distance <= -50:
					_speed = move_toward(_speed, 50, 5);
			elif _is_tired:
				if _far_distance > 50:
					_speed = move_toward(_speed, 25, 1);
				elif _far_distance <= 50 &&  _far_distance >= 0:
					_speed = move_toward(_speed, 10, 5);
				elif _far_distance < 0 && _far_distance > -50:
					_speed = move_toward(_speed, 10, 5);
				elif _far_distance <= -50:
					_speed = move_toward(_speed, 25, 1);
			_move(delta);
		WORKING:
			match _current_work:
				0:
					_sprite_2d.animation = "chopping"
					_play_chopping_sound()
				1:
					_sprite_2d.animation = "farming"
					_play_farming_sound()
				2:
					_sprite_2d.animation = "cooking"
					_play_cooking_sound()
				3:
					_sprite_2d.animation = "building"
					_play_hammer_sound()

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
	_play_footstep_sounds();

func _choose(array):
	array.shuffle();
	return array.front();

func _on_timer_timeout() -> void:
	match  _current_state:
		IDLE:
			if _is_following:
				if _player.position.x >= position.x + 75 || _player.position.x <= position.x - 75:
					_current_state = _choose([NEW_DIR, IDLE, NEW_DIR]);
				else:
					_current_state = _choose([NEW_DIR, IDLE, IDLE, IDLE, IDLE, IDLE]);
				if _current_state == NEW_DIR:
					$Timer.wait_time = _choose([0.2, 0.2, 0.4]);
				elif _current_state == IDLE:
					$Timer.wait_time = _choose([0.8, 1.6, 2]);
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
				if _is_tired && _far_distance > -25 && _far_distance < 25 && _current_state == NEW_DIR:
					_current_state = IDLE;
					# fade out the villager.
					var tween = create_tween()
					tween.tween_property(_sprite_2d, "modulate", Color(1, 1, 1, 0), 2)
					tween.tween_callback(queue_free)
				$Timer.wait_time = _choose([1, 1, 1.5, 2]);
		NEW_DIR:
			pass
		MOVE:
			if _is_following:
				if _player.position.x >= position.x + 75 || _player.position.x <= position.x - 75:
					_current_state = _choose([NEW_DIR, NEW_DIR, NEW_DIR, NEW_DIR, NEW_DIR, IDLE]);
				else:
					_current_state = _choose([NEW_DIR, IDLE, IDLE, IDLE, IDLE, IDLE]);
				if _current_state == NEW_DIR:
					$Timer.wait_time = _choose([0.2, 0.2, 0.4]);
				elif _current_state == IDLE:
					$Timer.wait_time = _choose([0.5, 1, 1]);
				_stamina -= 1;
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
				_stamina -= 2;
			else:
				_current_state = _choose([NEW_DIR, MOVE, IDLE]);
				if _current_state == NEW_DIR:
					var duration = _choose([0.4, 0.6]);
					var front = _random.randi_range(-2,16);
					$Timer.wait_time = duration
					set_sprite_position(Vector2(0, front) , duration, int(front * 0.25) + 4);
				elif _current_state == IDLE:
					$Timer.wait_time = _choose([2.4, 3.2]);
				else:
					$Timer.wait_time = _choose([0.4, 0.6]);
		WORKING:
			if _far_distance > 50:
				_current_state = _choose([NEW_DIR, IDLE]);
			elif _far_distance <= 50 &&  _far_distance >= 0:
				_current_state = _choose([NEW_DIR, WORKING, WORKING, WORKING, IDLE]);
			elif _far_distance < 0 && _far_distance > -50:
				_current_state = _choose([NEW_DIR, WORKING, WORKING, WORKING, WORKING, IDLE]);
			elif _far_distance <= -50:
				_current_state = _choose([NEW_DIR, IDLE]);

			if _current_state == WORKING:
				$Timer.wait_time = _choose([2, 2, 3]);
				_stamina -= 2;
			elif _current_state == IDLE:
				$Timer.wait_time = _choose([0.5, 1, 1]);
			else:
				$Timer.wait_time = _choose([0.2, 0.4, 0.6]);
				_stamina -= 1;
	# if the stamina is less than 0, go to home.
	if _stamina < 0:
		go_to_home();

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
	if !_is_tired:
		_current_state = IDLE;

func _on_unfocus() -> void:
	_rich_text_label.hide();
	# _current_state = NEW_DIR;

func follow_player() -> void:
	# Add to the player's followers.
	set_group("following");
	_player.register_follower(self);
	# play the recruitment sound.
	_play_recruitment_sound(_random.randf_range(0.8, 0.95));
	InteractionManager.unregister_area(interaction_area);
	_is_following = true;
	_is_working = false;
	_current_state = NEW_DIR;
	_working_post = null;
	interaction_area.monitoring = false;
	# set z index to 4
	set_sprite_position(Vector2(), 0.4, 4);

func assign_to_post(post) -> void:
	# Assign the NPC to a post.
	set_group("working");
	_play_recruitment_sound(_random.randf_range(1.05, 1.2));
	_is_following = false;
	_is_working = true;
	_current_state = NEW_DIR;
	# calculate far distance from current position to post position.
	# Add to the pool of the pos
	post.add_to_pool(self);
	# set the animation based on the type of the post.
	_current_work = post.type;
	_working_post = post;

func go_to_home() -> void:
	_stamina = 0;
	interaction_area.monitoring = true;
	# Go to the home position.
	set_group("sleeping");
	if _is_following:
		_player.unregister_follower(self);
		_is_following = false;
	elif _is_working:
		_working_post.remove_villager(self);
		_is_working = false;
	_is_tired = true;
	set_far_distance(_spawn_position.x);
	# set z index to 4
	set_sprite_position(Vector2(), 0.4, 4);

func set_far_distance(point: float) -> void:
	_far_distance = position.x - point;
	_current_state = NEW_DIR;

func _play_footstep_sounds() -> void:
	_walking_sound_pool.play_random_sound(_random.randi_range(-18, -12));
	_walking_sound_pool.set_pool_position(global_position + Vector2(0, _random.randi_range(16, 32)));

func _play_chopping_sound() -> void:
	_chopping_sound_pool.play_random_sound(_random.randi_range(-18, -12));
	_chopping_sound_pool.set_pool_position(global_position + Vector2(0, -_random.randi_range(16, 32)));

func _play_farming_sound() -> void:
	_farming_sound_pool.play_random_sound(_random.randi_range(-18, -12));
	_farming_sound_pool.set_pool_position(global_position + Vector2(0, -_random.randi_range(16, 32)));

func _play_cooking_sound() -> void:
	_cooking_sound_pool.play_random_sound(_random.randi_range(-18, -12));
	_cooking_sound_pool.set_pool_position(global_position + Vector2(0, -_random.randi_range(16, 32)));

func _play_recruitment_sound(pitch: float = 1) -> void:
	# if the current index is odd play the woman sound.
	if (sprite_index % 2 == 0):
		_woman_recruitment_sound_pool.play_random_sound(_random.randi_range(-12, -6), pitch);
		_woman_recruitment_sound_pool.set_pool_position(global_position + Vector2(0, _random.randi_range(16, 32)));
	else:
		_man_recruitment_sound_pool.play_random_sound(_random.randi_range(-12, -6), pitch);
		_man_recruitment_sound_pool.set_pool_position(global_position + Vector2(0, _random.randi_range(16, 32)));

func _play_hammer_sound() -> void:
	_hammer_sound_pool.play_random_sound(_random.randi_range(-24, -12));
	_hammer_sound_pool.set_pool_position(global_position + Vector2(0, -_random.randi_range(-32, 32)));

func set_sprite_position(pos: Vector2, duration: float = 1	, z_idx: int = 4, scale: float = 1) -> void:
	set_z_index(z_idx);
	var tween = create_tween().set_parallel()
	tween.tween_property(_sprite_2d, "position", pos , duration)
	tween.tween_property(_sprite_2d, "scale", Vector2(scale, scale) , duration)

func set_group(group: String) -> void:
	# remove from all groups.
	remove_from_group("sleeping");
	remove_from_group("working");
	remove_from_group("following");
	# add to the group.
	add_to_group(group);

func add_stamina(amount: float) -> void:
	_stamina += amount;
	_is_tired = false;
