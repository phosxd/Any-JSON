## Provides common functions for all A2J systems to use.
class_name A2JUtil extends RefCounted


## Returns true if the array consists of only numbers (int or float).
static func is_number_array(array:Array) -> bool:
	return array.all(func(item) -> bool:
		return item is int or item is float
	)
