@abstract class_name A2JTypeHandler extends RefCounted

## Convert a value to an AJSON object. Can connect to [code]A2J._to_json[/code] for recursion.
@abstract func to_json(value, ruleset:Dictionary)
## Convert an AJSON object back into the original item. Can connect to [code]A2J._from_json[/code] for recursion.
@abstract func from_json(value, ruleset:Dictionary)

const a2jError := 'A2J Error (%s): '
var print_errors := true
var error_strings = []
var error_stack:Array[int] = []
## Data merged to [code]A2J._process_data[/code] every time serialization begins.
var init_data:Variant = {}


## Report an error to Any-JSON.
## [param translations] should be strings.
func report_error(error:int, ...translations) -> void:
	var a2jError_ = a2jError % self.get_script().get_global_name()
	error_stack.append(error)
	if not print_errors: return
	var message = error_strings.get(error)
	if not message:
		printerr(a2jError_+str(error))
	else:
		var translated_message = message
		for tr in translations:
			if tr is not String: continue
			translated_message = translated_message.replace('~~', tr)
		printerr(a2jError_+translated_message)
