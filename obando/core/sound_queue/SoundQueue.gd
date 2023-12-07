@tool
extends Node

var _next:int = 0
# create empty array list of AudioStreamPlayer "_audioStreamPlayer"
var _audioStreamPlayer: Array[AudioStreamPlayer] = []

@export var count:int  = 1

func _ready() -> void:
	if get_child_count() == 0:
		print("No child node found")
		return

	var child = get_child(0)
	if child is AudioStreamPlayer:
		_audioStreamPlayer.append(child)

		for i in range(count):
			var newChild = child.duplicate()
			_audioStreamPlayer.append(newChild)
			add_child(newChild)

func _get_configuration_warnings() -> PackedStringArray:
	if get_child_count() == 0:
		return ["No child node found. Expected AudioStreamPlayer child."]

	if get_child(0) != AudioStreamPlayer:
		return ["Expected first child to be AudioStreamPlayer."]

	return []

func play_sound() -> void:
	# check if next audio stream player is playing
	if !_audioStreamPlayer[_next].is_playing():
		# play next+1 audio stream player
		_audioStreamPlayer[_next+1].play()   # Warning: Index out of bounds: 1
		_next %= _audioStreamPlayer.size()