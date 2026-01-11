## Provides common functions for all A2J systems to use.
class_name A2JUtil extends RefCounted


const variant_type_string_map:Dictionary[Variant.Type,StringName] = {
TYPE_NIL:'Nil',
TYPE_AABB:'AABB',
TYPE_BASIS:'Basis',
TYPE_BOOL:'bool',
TYPE_CALLABLE:'Callable',
TYPE_COLOR:'Color',
TYPE_DICTIONARY:'Dictionary',
TYPE_FLOAT:'float',
TYPE_INT:'int',
TYPE_NODE_PATH:'NodePath',
TYPE_OBJECT:'Object',
TYPE_PACKED_BYTE_ARRAY:'PackedByteArray',
TYPE_PACKED_COLOR_ARRAY:'PackedColorArray',
TYPE_PACKED_FLOAT32_ARRAY:'PackedFloat32Array', TYPE_PACKED_FLOAT64_ARRAY:'PackedFloat64Array',
TYPE_PACKED_INT32_ARRAY:'PackedInt32Array', TYPE_PACKED_INT64_ARRAY:'PackedInt64Array',
TYPE_PACKED_STRING_ARRAY:'PackedStringArray',
TYPE_PACKED_VECTOR2_ARRAY:'PackedVector2Array', TYPE_PACKED_VECTOR3_ARRAY:'PackedVector3Array', TYPE_PACKED_VECTOR4_ARRAY:'PackedVector4Array',
TYPE_PLANE:'Plane',
TYPE_PROJECTION:'Projection',
TYPE_QUATERNION:'Quaternion',
TYPE_RECT2:'Rect2', TYPE_RECT2I:'Rect2i',
TYPE_RID:'RID',
TYPE_SIGNAL:'Signal',
TYPE_STRING:'String', TYPE_STRING_NAME:'StringName',
TYPE_TRANSFORM2D:'Transform2D', TYPE_TRANSFORM3D:'Transform3D',
TYPE_VECTOR2:'Vector2', TYPE_VECTOR2I:'Vector2i',
TYPE_VECTOR3:'Vector3', TYPE_VECTOR3I:'Vector3i',
TYPE_VECTOR4:'Vector4', TYPE_VECTOR4I:'Vector4i',
TYPE_MAX:'MAX',
}


## Returns true if the array consists of only numbers (int or float).
static func is_number_array(array:Array) -> bool:
	return array.all(func(item) -> bool:
		return item is int or item is float
	)


## Returns true if the array consists of only strings.
static func is_string_array(array:Array) -> bool:
	return array.all(func(item) -> bool:
			return item is String
	)


## Returns the global class name of the [param object].
static func get_class_name(object:Object) -> StringName:
	var object_class: StringName
	var script = object.get_script()
	if script is Script:
		# Search for class in `A2J.object_registry`.
		var object_class_in_registry = A2J.object_registry.find_key(object.get_script())
		if object_class_in_registry is StringName: object_class = object_class_in_registry

		else: object_class = object.get_class()
	else: object_class = object.get_class()

	return object_class


## Re-types the [param dict] with [param type_details]. If failed, returns the dictionary unchanged.
## [br][br]
## [param type_details] should follow the same format as items found within [Object][code].get_property_list()[/code].
static func type_dictionary(dict:Dictionary, type_details:Dictionary) -> Dictionary:
	# Return unchanged if type details do not specify valid values for a Dictionary.
	if type_details.get('type') != TYPE_DICTIONARY && type_details.get('hint_string') is not String:
		return dict
	# Get hint string.
	var hint_string:PackedStringArray = type_details.get('hint_string').split(';')
	# Return unchanged if "hint_string" is not the expected size.
	if hint_string.size() != 2:
		return dict

	# Return typed dictionary.
	var key_details := decode_hint_string(hint_string[0])
	var value_details := decode_hint_string(hint_string[1])
	return Dictionary(dict,
		key_details[0], key_details[1], key_details[2],
		value_details[0], value_details[1], value_details[2],
	)


## Re-types the [param array] with [param type_details]. If failed, returns the array unchanged.
## [br][br]
## [param type_details] should follow the same format as items found within [Object][code].get_property_list()[/code].
static func type_array(array:Array, type_details:Dictionary) -> Array:
	# Return unchanged if type details do not specify valid values for an Array.
	if type_details.get('type') != TYPE_ARRAY or type_details.get('hint_string') is not String:
		return array
	# Get hint string.
	var hint_string:PackedStringArray = type_details.hint_string.split(';')
	# Return unchanged if "hint_string" is not the expected size.
	if not hint_string.size() == 1 \
	or not hint_string[0]:
		return array
	
	# Get details & return typed array.
	var details = decode_hint_string(hint_string[0])
	return Array(array, details[0], details[1], details[2])


## Retrives nested type, class name, & class script (in order) from the given [param hint_string].
## [br][br]
## [param hint_string] should be the hint string seperated by ";". E.g [code]var hint_string:PackedStringArray = type_details.hint_string.split(';')
static func decode_hint_string(hint_string:String) -> Array:
	var value_hint:PackedStringArray = hint_string.split(':')
	# Get the nested value type by checking at different layers.
	# Layer 1: if the type is a Variant.Type, we can find it in the `variant_type_string_map`.
	var value_type = A2JUtil.variant_type_string_map.find_key(value_hint[-1])
	if value_type == null:
		# Layer 2: if it's not in the string map, sometimes we can find the Variant.Type number at the beginning of the hint string.
		var value_hint_2 := value_hint[0].split('/')[0]
		if value_hint_2.is_valid_int():
			value_type = value_hint_2.to_int()
		# Layer 3: if we can't find it in the string map or in the hint string we have to assume the type to be TYPE_OBJECT.
		# I don't like this solution very much, but if it causes problems we can always revise it or add more exceptions.
		else:
			value_type = TYPE_OBJECT
	var value_class_name := &''
	var value_script = null
	var construct_with_value_class_name := &''

	# If type is Object, determine the script.
	if value_type == TYPE_OBJECT:
		value_class_name = value_hint[-1]
		value_script = A2J.object_registry.get(value_class_name)
		# Constructors do not accept custom class names, use "Object" if script is a custom class.
		construct_with_value_class_name = &'Object' if not ClassDB.class_exists(value_class_name) else value_class_name

	return [value_type, construct_with_value_class_name, value_script]
