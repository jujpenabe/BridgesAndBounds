@tool
extends Node
class_name SoundQueue

var _next:int = 0
var _current_volume:float = 0
var _is_playing:bool = false
# create empty array list of AudioStreamPlayer "_audioStreamPlayer"
var _audioStreamPlayer: = []

@export var count:int  = 1

func _ready() -> void:
	if get_child_count() == 0:
		print("No child node found")
		return

	var child = get_child(0)
	if child is AudioStreamPlayer:
		child.finished.connect(_on_sound_finished)
		_audioStreamPlayer.append(child)

		for i in range(count):
			var newChild = child.duplicate()
			newChild.finished.connect(_on_sound_finished)
			_audioStreamPlayer.append(newChild)
			add_child(newChild)

func _get_configuration_warnings() -> PackedStringArray:
	if get_child_count() == 0:
		return ["No child node found. Expected AudioStreamPlayer child."]

	if get_child(0).get_class() != "AudioStreamPlayer":
		return ["Expected first child to be AudioStreamPlayer."]

	return []

func _on_sound_finished() -> void:
	_is_playing = false

func play_sound() -> void:
	# check if next audio stream player is playing
	if !_audioStreamPlayer[_next].is_playing():
		# change the volume of the next audio stream player
		_audioStreamPlayer[_next].volume_db = _current_volume
		# play next+1 audio stream player
		_audioStreamPlayer[_next+1].play()
		_is_playing = true
		_next %= _audioStreamPlayer.size()

func is_queue_playing() -> bool:
	return _is_playing

func set_volume_db(volume_db:float) -> void:
	_current_volume = volume_db
	_audioStreamPlayer[_next].volume_db = volume_db
