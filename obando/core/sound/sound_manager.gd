extends Node2D

static var instance

var _sound_queues_by_name: Dictionary = {}
var _sound_pools_by_name: Dictionary = {}

func _ready():
	instance = self
