class_name MyRes
extends Resource

@export var action_name: String = ""
@export var inputs: Array[InputEvent]

func _to_string() -> String:
	return "MyRes: { action_name: %s, inputs: %s }" % [action_name, inputs]
