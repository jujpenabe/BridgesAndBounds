extends Area2D
class_name InteractionArea

@export var action_name: String = "interact"
@export var is_registrable: bool =	true

var interact: Callable = func():
	pass

var a_order: Callable = func():
	pass

var b_order: Callable = func():
	pass

var c_order: Callable = func():
	pass


var cancel_a_order: Callable = func():
	pass

var cancel_b_order: Callable = func():
	pass

var cancel_c_order: Callable = func():
	pass

var stair: Callable = func(text):
	pass

var unfocus: Callable = func():
	pass

func _on_body_entered(body: Node2D) -> void:
	InteractionManager.register_area(self)

func _on_body_exited(body: Node2D) -> void:
	InteractionManager.unregister_area(self)
