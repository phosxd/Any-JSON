## Hosts signals for [A2J] errors. Access [code]A2J.error_server[/code], do not use your own instantiation.
class_name A2JErrorServer extends RefCounted

## Emitted when any of the [code]type_handlers[/code] catch an error.
## [param tree_position] points to the location of the value that caused the error.
signal handler_error(handler_name:String, error:int, message:String, tree_position:Array[String])

## Emitted when the core [code]A2J[/code] process catches an error.
signal core_error(error:int, message:String)
