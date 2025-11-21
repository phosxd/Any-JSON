class_name A2JReferenceTypeHandler extends A2JTypeHandler


func _init() -> void:
	error_strings = [
		'"named_references" in ruleset should be structured as follows: Dictionary[String,Variant].',
		'Reference name should be a String.',
	]


## Should not be used.
func to_json(dict:Dictionary, ruleset:Dictionary) -> Dictionary[String,Variant]:
	return {}


func from_json(json:Dictionary, ruleset:Dictionary) -> Variant:
	var named_references = ruleset.get('references',{})
	if named_references is not Dictionary:
		report_error(0)
		return null

	var name = json.get('value','')
	if name is not String:
		report_error(1)
		return null

	return named_references.get(name, null)
