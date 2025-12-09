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
TYPE_PACKED_FLOAT32_ARRAY:'PackedFloat32Array',
TYPE_PACKED_FLOAT64_ARRAY:'PackedFloat64Array',
TYPE_PACKED_INT32_ARRAY:'PackedInt32Array',
TYPE_PACKED_INT64_ARRAY:'PackedInt64Array',
TYPE_PACKED_STRING_ARRAY:'PackedStringArray',
TYPE_PACKED_VECTOR2_ARRAY:'PackedVector2Array',
TYPE_PACKED_VECTOR3_ARRAY:'PackedVector3Array',
TYPE_PACKED_VECTOR4_ARRAY:'PackedVector4Array',
TYPE_PLANE:'Plane',
TYPE_PROJECTION:'Projection',
TYPE_QUATERNION:'Quaternion',
TYPE_RECT2:'Rect2',
TYPE_RECT2I:'Rect2i',
TYPE_RID:'RID',
TYPE_SIGNAL:'Signal',
TYPE_STRING:'String',
TYPE_STRING_NAME:'StringName',
TYPE_TRANSFORM2D:'Transform2D',
TYPE_TRANSFORM3D:'Transform3D',
TYPE_VECTOR2:'Vector2',
TYPE_VECTOR2I:'Vector2i',
TYPE_VECTOR3:'Vector3',
TYPE_VECTOR3I:'Vector3i',
TYPE_VECTOR4:'Vector4',
TYPE_VECTOR4I:'Vector4i',
TYPE_MAX:'MAX',
}


## Returns true if the array consists of only numbers (int or float).
static func is_number_array(array:Array) -> bool:
	return array.all(func(item) -> bool:
		return item is int or item is float
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
