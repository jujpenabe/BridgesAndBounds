extends Post
class_name Bridge

@onready var _bridge_sprite = %BridgeSprite
@onready var _scaffold_sprite = %ScaffoldSprite
@onready var _bridge_limit = %BridgeLimit
@onready var _bridge_floor = %BridgeFloor

# SFX
@onready var _buildSound1 = %BuildSound1

var _progress = 0
var _section = 40

# On timer timeout calculate the work of resources to produce every 5 seconds (add to a pool)
# based on the number of villagers in the pool and the type of them (A, B, C)
# according to the post type (A, B, C) some produce more than others

# On readt set the wood amount to 10
func _ready() -> void:
	super._ready()
	# set the location of the sound to the bridge location
	_wood = 100
	_buildSound1.position = position

func _on_p_timer_timeout() -> void:
	_build()
	# wait 5 seconds and repeat

func _build() -> void:
	if _a_villagers.size() + _b_villagers.size() + _c_villagers.size() == 0:
		_effort = 0
		# stop the sound
		_buildSound1.stop()
		return
	# play the build sound is not playing or is finished
	if !_buildSound1.is_playing():
		_buildSound1.play()

		print("play build sound")
	var work = 0

	if _a_villagers.size() > 0:
		for vill in _a_villagers:
			if vill.type == 0:
				work += 4
			if (vill.type + 1) % 3 == 0:
				work += 2
			if (vill.type + 2) % 3 == 0:
				work += 1
	if _b_villagers.size() > 0:
		for vill in _b_villagers:
			if vill.type == 0:
				work += 4
			if (vill.type + 1) % 3 == 0:
				work += 2
			if (vill.type + 2) % 3 == 0:
				work += 1
	if _c_villagers.size() > 0:
		for vill in _c_villagers:
			if vill.type == 0:
				work += 4
			if (vill.type + 1) % 3 == 0:
				work += 2
			if (vill.type + 2) % 3 == 0:
				work += 1
	_effort += work
	if _effort >= _max_effort:
		_effort = 0
		# consume resources
		_label.hide()
		if _wood > 0:
			_wood -= 1
			_progress += 1
			# if progres is odd build the scaffold
			if _progress % 2 == 1:
				_scaffold_sprite.region_rect = Rect2(_scaffold_sprite.region_rect.position, Vector2(_scaffold_sprite.region_rect.size.x + _section, _scaffold_sprite.region_rect.size.y))
				_scaffold_sprite.offset.x += _section * 0.5
			# if progress is even build the bridge
			if _progress % 2 == 0:
				_bridge_sprite.region_rect = Rect2(_bridge_sprite.region_rect.position, Vector2(_bridge_sprite.region_rect.size.x + _section, _bridge_sprite.region_rect.size.y))
				_bridge_sprite.offset.x += _section * 0.5

				# Move the scaffold left to the right
				# random 50% thath the sprite will move
				if _progress > 1 && randi() % 2:
					_scaffold_sprite.region_rect = Rect2(_scaffold_sprite.region_rect.position, Vector2(_scaffold_sprite.region_rect.size.x - _section, _scaffold_sprite.region_rect.size.y))
					_scaffold_sprite.offset.x += _section * 0.5
					_bridge_limit.shape.set_b(Vector2(_bridge_limit.shape.get_b().x + _section * 0.5, _bridge_limit.shape.get_b().y))
					_bridge_floor.position.x += _section * 0.5
					# move the sound position
					_buildSound1.position.x += _section * 0.5
					# Move the villagers current far distnace to the right
					for vill in _a_villagers:
						vill.new_far_distance(position.x + (_section))

			# print the work of resources produced
		_production_timer.wait_time = 10
