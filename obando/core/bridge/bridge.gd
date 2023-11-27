extends Post
class_name Bridge

@onready var _bridge_sprite = %BridgeSprite
@onready var _scaffold_sprite = %ScaffoldSprite
@onready var _bridge_limit = %BridgeLimit
@onready var _bridge_floor = %BridgeFloor

# SFX
@onready var _buildSoun1 = %BuildSound1

var _progress = 0

# On timer timeout calculate the work of resources to produce every 5 seconds (add to a pool)
# based on the number of villagers in the pool and the type of them (A, B, C)
# according to the post type (A, B, C) some produce more than others

# On readt set the wood amount to 10
func _ready() -> void:
	super._ready()
	_wood = 100

func _on_p_timer_timeout() -> void:
	_build()
	# wait 5 seconds and repeat

func _build() -> void:
	var work = 0
	if _a_villagers.size() + _b_villagers.size() + _c_villagers.size() == 0:
		return
	if _a_villagers.size() > 0:
		for vill in _a_villagers:
			if vill.type == type:
				work += 4
			if (vill.type + 1) % 3 == type:
				work += 2
			if (vill.type + 2) % 3 == type:
				work += 1
	if _b_villagers.size() > 0:
		for vill in _b_villagers:
			if vill.type == type:
				work += 4
			if (vill.type + 1) % 3 == type:
				work += 2
			if (vill.type + 2) % 3 == type:
				work += 1
	if _c_villagers.size() > 0:
		for vill in _c_villagers:
			if vill.type == type:
				work += 4
			if (vill.type + 1) % 3 == type:
				work += 2
			if (vill.type + 2) % 3 == type:
				work += 1
	_effort += work
	if _effort >= _max_effort:
		# append a new item to the lots array and spawn a notification above the post
		# to notify the player that the post produced a new resource, the sound is louder when the post is full
		# and the notification is bigger
		# the notification is a label that fades out after 2 seconds
		_effort = 0
		# consume resources
		_label.hide()
		if _wood > 0:
			_wood -= 1
			_progress += 1
			# if progres is odd build the scaffold
			var section = 40
			if _progress % 2 == 1:
				_scaffold_sprite.region_rect = Rect2(_scaffold_sprite.region_rect.position, Vector2(_scaffold_sprite.region_rect.size.x + section, _scaffold_sprite.region_rect.size.y))
				_scaffold_sprite.offset.x += section * 0.5
			# if progress is even build the bridge
			if _progress % 2 == 0:
				_bridge_sprite.region_rect = Rect2(_bridge_sprite.region_rect.position, Vector2(_bridge_sprite.region_rect.size.x + section, _bridge_sprite.region_rect.size.y))
				_bridge_sprite.offset.x += section * 0.5
				
				# Move the scaffold left to the right
				# random 50% thath the sprite will move
				if _progress > 1 && randi() % 2:
					_scaffold_sprite.region_rect = Rect2(_scaffold_sprite.region_rect.position, Vector2(_scaffold_sprite.region_rect.size.x - section, _scaffold_sprite.region_rect.size.y))
					_scaffold_sprite.offset.x += section * 0.5
					_bridge_limit.shape.set_b(Vector2(_bridge_limit.shape.get_b().x + section * 0.5, _bridge_limit.shape.get_b().y))
					_bridge_floor.position.x += section * 0.5
					# Move the villagers current far distnace to the right
					for vill in _a_villagers:
						vill.new_far_distance(position.x + (section))

			# print the work of resources produced
		_production_timer.wait_time = 10
