extends Node2D

static var instance

@onready var _rooster_sound_pool: SoundPool2D = %RoosterSoundPool;

var _sound_queues_by_name: Dictionary = {}
var _sound_pools_by_name: Dictionary = {}

func _ready():
	instance = self
	_play_rooster_sound()

func _play_rooster_sound():
	_rooster_sound_pool.play_random_sound(-18)
	# at players position
	var player = get_tree().get_first_node_in_group("player")
	_rooster_sound_pool.set_pool_position(player.global_position)
