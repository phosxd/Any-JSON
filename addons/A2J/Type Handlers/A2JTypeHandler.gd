@abstract class_name A2JTypeHandler extends RefCounted

## Convert a value to an AJSON object. Can connect to [code]A2J._to_json[/code] for recursion.
@abstract func to_json(value, ruleset:Dictionary)
## Convert an AJSON object back into the original item. Can connect to [code]A2J._from_json[/code] for recursion.
@abstract func from_json(value, ruleset:Dictionary)


const a2jError := 'A2J Error (%s): '
## When true, errors reported using [code]report_error[/code] will be printed to the console.
var print_errors := true
## Error message strings.
var error_strings:Array[String] = []
## Array of error codes (corresponding to error message indices) accumulated throughout the object's lifespan.
var error_stack := PackedInt32Array()
## Data merged to [code]A2J._process_data[/code] every time serialization/deserialization begins.
var init_data:Dictionary = {}


## Report an error to Any-JSON.
## [param translations] should be strings.
func report_error(error:int, ...translations) -> void:
	var a2jError_ = a2jError % self.get_script().get_global_name()
	# Append to error stack.
	error_stack.append(error)
	# Skip printing if print errors is set to false.
	if not print_errors: return

	# Print error.
	var message = error_strings.get(error)
	if not message:
		printerr(a2jError_+str(error))
	else:
		# Translate error message.
		var translated_message = message
		for tr in translations:
			if tr is not String: continue
			translated_message = translated_message.replace('~~', tr)
		printerr(a2jError_+translated_message)
