@abstract class_name A2JTypeHandler extends RefCounted

## Convert a value to an AJSON object. Can connect to [code]A2J._to_json[/code] for recursion.
@abstract func to_json(value, ruleset:Dictionary)
## Convert an AJSON object back into the original item. Can connect to [code]A2J._from_json[/code] for recursion.
@abstract func from_json(value, ruleset:Dictionary)


const a2jError := '%s.gd found error at [code]%s[/code]: '
## When true, errors reported using [code]report_error[/code] will be printed to the console.
var print_errors := true
## Error message strings.
var error_strings:Array[String] = []
## Data merged to [code]A2J._process_data[/code] every time serialization/deserialization begins.
var init_data:Dictionary = {}


## Report an error to Any-JSON.
## [param translations] should be strings.
func report_error(error:int, ...translations) -> void:
	var a2jError_ = a2jError % [self.get_script().get_global_name(), ' > '.join(A2J._tree_position)]

	# Construct message.
	var message = error_strings.get(error)
	if not message:
		if print_errors: printerr(a2jError_+str(error))
	else:
		# Translate error message.
		for tr in translations:
			if tr is not String && tr is not StringName: continue
			message = message.replace('~~', tr)
		if print_errors: printerr(a2jError_+message)

	# Emit error.
	var handler_name:String = get_script().get_global_name()
	A2J.error_server.handler_error.emit(handler_name, error, message, A2J._tree_position.duplicate())
