class_name A2JReferenceTypeHandler extends A2JTypeHandler


func _init() -> void:
	error_strings = [
		'"references" in ruleset should be structured as follows: Dictionary[String,Variant].',
		'Reference name should be a String.',
	]


## Should not be used.
func to_json(_value, _ruleset:Dictionary) -> void:
	pass


func from_json(json:Dictionary, ruleset:Dictionary) -> Variant:
	var named_references = ruleset.get('references',{})
	if named_references is not Dictionary:
		report_error(0)
		return null

	var name = json.get('value','')
	if name is not String:
		report_error(1)
		return null
	name = name as String

	if name.begins_with('.i'):
		var object_stack = A2J._process_data.get('object_stack_dict', {})
		if object_stack is Dictionary:
			var index:String = name.split('.i')[1]
			return object_stack.get(index, '_A2J_unresolved_reference')

	return named_references.get(name, null)
