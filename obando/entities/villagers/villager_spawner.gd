extends StaticBody2D
class_name VillagerSpawner

var villager_scene = preload("res://obando/entities/villagers/ch_a_villager1.tscn")
# instantiate a new villager and add it to the scene

func spawn_villager(type: int = 0, sprite: int = 0):
	var villager = villager_scene.instantiate()
	villager.global_position = global_position
	villager.type = type
	villager.sprite_index = sprite
	# add the villager to the scene, "Villagers" 2D node
	get_tree().get_root().get_node("Main/Villagers").add_child(villager)
	# modulate to transparent
	villager.modulate = Color(1, 1, 1, 0)
	# fade in
	var tween = create_tween()
	tween.tween_property(villager, "modulate", Color(1, 1, 1, 1), 2)
