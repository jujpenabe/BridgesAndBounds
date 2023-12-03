@tool
extends Node2D
class_name SoundQueue2D

var _next:int = 0
var _current_volume:float = 0
var _current_position:Vector2 = Vector2(0,0)
var _is_playing:bool = false
# create empty array list of AudioStreamPlayer "_audioStreamPlayers2D"
var _audioStreamPlayers2D: = []

@export var count:int  = 1

func _ready() -> void:
	if get_child_count() == 0:
		print("No child node found")
		return

	var child = get_child(0)
	if child is AudioStreamPlayer2D:
		child.finished.connect(_on_sound_finished)
		_audioStreamPlayers2D.append(child)

		for i in range(count):
			var newChild = child.duplicate()
			newChild.finished.connect(_on_sound_finished)
			_audioStreamPlayers2D.append(newChild)
			add_child(newChild)

func _get_configuration_warnings() -> PackedStringArray:
	if get_child_count() == 0:
		return ["No child node found. Expected AudioStreamPlayer child."]

	if get_child(0).get_class() != "AudioStreamPlayer2D":
		return ["Expected first child to be AudioStreamPlayer2D."]

	return []

func _on_sound_finished() -> void:
	_is_playing = false

func play_sound() -> void:
	# check if next audio stream player is playing
	if !_audioStreamPlayers2D[_next].is_playing():
		# change the volume of the next audio stream player
		_audioStreamPlayers2D[_next+1].volume_db = _current_volume
		# play next+1 audio stream player
		_audioStreamPlayers2D[_next+1].play()
		# set position
		_audioStreamPlayers2D[_next+1].position = _current_position
		_is_playing = true
		_next %= _audioStreamPlayers2D.size()

func is_queue_playing() -> bool:
	return _is_playing

func set_volume_db(volume_db:float = 0) -> void:
	_current_volume = volume_db
	_audioStreamPlayers2D[_next].volume_db = volume_db

func set_new_position(pos:Vector2) -> void:
	_current_position = pos
	# _audioStreamPlayers2D[_next].position = pos
