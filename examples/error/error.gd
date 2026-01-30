@tool
extends Node

@export var structure_depth:int = 3
@export_tool_button('Unknown class') var unknown_class_button = unknown_class_callback
#@export_enum('type_exclusions', 'type_inclusions', 'class_exclusions', 'class_inclusions', 'property_exclusions', 'property_inclusions', 'exclude_private_properties', 'exclude_properties_set_to_default', 'fppe_mitigation', 'property_references', 'references', 'instantiator_function', 'instantiator_arguments', 'midpoint') var invalid_rule = 0
#@export_tool_button('Invalid rule') var invalid_rule_button = invalid_rule_callback


class DummyObject:
	var property


func generate_dummy_object() -> Array[Object]:
	A2J.object_registry.set('DummyObject', DummyObject)
	var objects:Array[Object] = [DummyObject.new()]
	for i in range(structure_depth-1):
		objects[-1].property = DummyObject.new()
		objects.append(objects[-1].property)
	return objects


func unknown_class_callback() -> void:
	print_rich('[b][color=yellow]Running error test "unknown class".[/color][/b]')
	A2J.object_registry.erase('Node3D')

	var dummies := generate_dummy_object()
	dummies[-1].property = Node3D.new()
	var ajson = A2J.to_json(dummies[0])
	print_rich('[b]Result:[/b] [code]' + JSON.stringify(ajson,'\t') + '[/code]')
	A2J.from_json(ajson)

	A2J.object_registry.set('Node3D', Node3D)
	print_rich('[b]Test ended.[/b]')


func invalid_rule_callback() -> void:
	return
