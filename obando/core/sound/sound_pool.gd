@tool
extends Node
class_name SoundPool

var _sounds: Array[SoundQueue] = []
var _random: RandomNumberGenerator = RandomNumberGenerator.new()
var _last_index: int = -1

func _ready():
	# Add all children to the sound queue
	for child in get_children():
		if child is SoundQueue:
			_sounds.append(child)

func _get_configuration_warnings() -> PackedStringArray:
	var number_of_sound_queue_children = 0
	for child in get_children():
		if child is SoundQueue:
			number_of_sound_queue_children += 1

	if (number_of_sound_queue_children < 2):
		return ["You need at least 2 SoundQueue children to play random sounds."]

	return []

func play_random_sound():
	# check if there are is a sound playing
	for sound in _sounds:
		if sound.is_queue_playing():
			return
	var index
	while true:
		index = _random.randi_range(0, _sounds.size() - 1)
		if index != _last_index:
			break
	_last_index = index
	_sounds[index].play_sound()
