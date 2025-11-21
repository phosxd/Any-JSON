@tool
extends Node

@export_tool_button('Test A2J') var test_a2j = test_a2j_callback

class custom_object_1:
	var some_value:bool = true


# In this example script we convert a simple object with some meta data to raw JSON
# & reconstruct the full original object just from the provided JSON.
#
# This example also showcases ruleset features like named references.


func test_a2j_callback() -> void:
	print_rich('[color=yellow][b]Converting to AJSON...')
	# Create example object & assign metadata to it.
	var test_obj := Object.new()
	test_obj.set_meta('example', ['a','b','c', Vector3(1,2,3)])
	var nested_obj := Object.new()
	test_obj.set_meta('example_nested_object', nested_obj)
	test_obj.set_meta('reference_example', 'this should be replaced with a named reference.')

	# Create ruleset to be used when converting to AJSON.
	var test_ruleset_to := A2J.default_ruleset_to.duplicate(true); test_ruleset_to.merge({
		# Define property names that will be converted to references instead of being converted to JSON representations of that property.
		'property_references': {
			'Object': {
				'metadata/reference_example': 'reference_1',
			},
		},
	}, true)
	# Convert to AJSON & print result.
	var test_obj_json:Dictionary = A2J.to_json(test_obj, test_ruleset_to)
	print(test_obj_json)

	# Create ruleset to be used when converting back.
	print_rich('[color=green][b]Converting back to original...')
	var test_ruleset_from := A2J.default_ruleset_to.duplicate(true); test_ruleset_from.merge({
		# Define named references & the value to assign to them.
		'references': {
			'reference_1': 'new value',
		},
	}, true)
	# Convert back to an Object & print the metadata.
	var json_to_object:Object = A2J.from_json(test_obj_json, test_ruleset_from)
	print(json_to_object.get_meta('example')) # prints: ['a','b','c', (1,2,3)]
	print(json_to_object.get_meta('example_nested_object')) # prints: <Object#...>
	print(json_to_object.get_meta('reference_example')) # prints: 'new value'
