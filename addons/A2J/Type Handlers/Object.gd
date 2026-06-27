## Handles serialization for the Object type.
class_name A2JObjectTypeHandler extends A2JTypeHandler

const script_property_type_details:Dictionary[String,Dictionary] = {
	'script': {
		'class_name': &'Script',
		'type': 24,
		'hint': 17,
		'hint_string': 'Script',
	},
}


func _init() -> void:
	error_strings = [
		'Class "%s" is not defined in registry.',
		'"property_exclusions" in ruleset should be structured as follows: Array[String].',
		'"property_references" in ruleset should be structured as follows: Dictionary[String,String].',
		'"instantiator_function" in ruleset should be structured as follows: Callable(registered_object:Object, object_class:String, args:Array=[]) -> Object.',
		'"instantiator_arguments" in rulset should be structured as follows: Dictionary[String,Array].',
		'"property_inclusions" in ruleset should be structured as follows: Array[String].',
		'Cannot convert from an invalid JSON representation.',
		'Unable to instantiate a default object of "%s". Make sure you have passed all arguments needed for this object in the "instantiator_arguments" rule.',
	]
	init_data = {
		# Property type data cache.
		# This is used to store per-class property type data so
		# it does not need to be grabbed & processed for every object.
		'ptd_cache': {},
	}


func to_json(object:Object, ruleset:Dictionary) -> Variant:
	var object_class := A2JUtil.get_class_name(object)

	# Get & check registered object equivalent.
	var registered_object = A2J.object_registry.get(object_class, null)
	if registered_object == null:
		report_error(0, object_class)
		return null
	registered_object = registered_object as Object
	# Get default object to compare properties with.
	var default_object:Object = _get_default_object(registered_object, object_class, ruleset)
	if default_object == null:
		report_error(7, object_class)
		return null

	# If object is an external resource, return a reference to it.
	if ruleset.get('automatic_resource_references') == true && object is Resource:
		if not object.resource_path.is_empty() && not object.resource_path.contains('::'):
			return A2JReferenceTypeHandler.make_reference('r:%s' % object.resource_path)

	# If object has been serialized before, return a reference to it.
	var variant_map:Dictionary = A2J._process_data.variant_map
	var id = variant_map.find_key(object)
	if id is int:
		return A2JReferenceTypeHandler.make_reference(str(id))
	# If not, add to map.
	else:
		id = variant_map.keys().size()
		A2J._process_data.variant_map.set(id, object)

	# Set up result.
	var result:Dictionary[String,Variant] = {
		'.t': 'Obj:%s:%s' % [id, object_class],  # Pack class name & ID into type.
	}

	# Get exceptions from ruleset.
	var properties_to_reference:Dictionary[String,String] = ruleset.get('property_references', Dictionary({}, TYPE_STRING, '', null, TYPE_STRING, '', null))
	var properties_to_exclude:Array = ruleset.get('property_exclusions', [])
	var properties_to_include:Array = ruleset.get('property_inclusions', [])
	var props_to_include_temp:Array = ruleset.get('property_inclusions', [])
	var do_properties_to_include = not props_to_include_temp.is_empty()

	# Convert all properties.
	for property:Dictionary in object.get_property_list():
		if _validate_object_property(result, property.name, properties_to_reference, properties_to_exclude, properties_to_include, do_properties_to_include, ruleset) == false: continue
		# Exclude null values.
		var property_value = object.get(property.name)
		if property_value == null: continue
		# Exclude values that are the same as default values.
		if ruleset.get('exclude_default_values'):
			if property_value == default_object.get(property.name): continue

		A2J._tree_position.append(property.name)
		# Convert value.
		var new_value = A2J._to_json(property_value)
		# Don't store null values.
		if new_value == null:
			A2J._tree_position.pop_back()
			continue
		# Set new value.
		result.set(property.name, new_value)
		A2J._tree_position.pop_back()

	# Get DPITexture source code & apply to result.
	if object is DPITexture:
		result.set('source', object.get_source())

	return result


func from_json(headers:PackedStringArray, json:Dictionary, ruleset:Dictionary) -> Object:
	# Throw error if invalid number of headers.
	if headers.size() != 3:
		report_error(6)
		return null
	# Set object class & id.
	var object_class:String = headers[2]
	var id = headers[1]
	# Throw error if invalid id.
	if not id.is_valid_int():
		report_error(6)
		return null
	id = id.to_int()

	# Get & check registered object equivalent.
	var registered_object = A2J.object_registry.get(object_class, null)
	if registered_object == null:
		report_error(0)
	registered_object = registered_object as Object

	# Create base result object.
	var result: Object
	# DPITexture should be created with "create_from_string".
	if object_class == 'DPITexture' && 'source' in json:
		result = DPITexture.create_from_string(json['source'])
	else:
		result = _get_default_object(registered_object, object_class, ruleset)
		if result == null:
			report_error(7, object_class)
			return null

	# Add result object to "variant_map" for use in references.
	A2J._process_data.variant_map.set(id, result)
	# Get rules.
	var properties_to_reference:Dictionary[String,String] = ruleset.get('property_references', Dictionary({}, TYPE_STRING, '', null, TYPE_STRING, '', null))
	var properties_to_exclude:Array = ruleset.get('property_exclusions', [])
	var properties_to_include:Array = ruleset.get('property_inclusions', [])
	var do_properties_to_include = not ruleset.get('property_inclusions',[]).is_empty()
	var has_script:bool = false
	# Sort keys to prioritize script property.
	var keys = json.keys()
	for item in ['script']:
		if keys.has(item):
			has_script = true
			keys.erase(item)
			keys.insert(0, item)
	# Dont get property type details before script is applied.
	var all_property_type_details:Dictionary[String,Dictionary] = script_property_type_details
	if not has_script:
		var ptd_cache = A2J._process_data.ptd_cache.get(object_class,null)
		if ptd_cache is Dictionary:
			all_property_type_details = ptd_cache
		else:
			all_property_type_details = _get_all_property_type_details(result)
			A2J._process_data.ptd_cache.set(object_class, all_property_type_details)

	# Convert all values in the dictionary.
	for key in keys:
		if key == 'source' && object_class == 'DPITexture': continue # Skip "source" as it is used when DPITexture is created with "create_from_string".
		if _validate_object_property(result, key, {}, properties_to_exclude, properties_to_include, do_properties_to_include, ruleset) == false: continue
		A2J._tree_position.append(key)
		var value = json[key]
		var property_type_details:Dictionary = all_property_type_details.get(key, {})
		var new_value = A2J._from_json(value, property_type_details)
		# Pass unresolved reference off to be resolved ater all objects are serialized & present in the object stack.
		if new_value is String && new_value == '_A2J_unresolved_reference':
			A2J._process_next_pass_functions.append(_resolve_reference.bind(result, key, value))
			A2J._tree_position.pop_back()
			continue
		# Set value as metadata.
		if key.begins_with('metadata/'):
			result.set_meta(key.replace('metadata/',''), new_value)
		# Set value.
		else: result.set(key, new_value)
		A2J._tree_position.pop_back()

		# Update property type details after script has been applied to the object.
		if key == 'script':
			var ptd_cache = A2J._process_data.ptd_cache.get(id,null)
			if ptd_cache is Dictionary:
				all_property_type_details = ptd_cache
			else:
				all_property_type_details = _get_all_property_type_details(result)
				A2J._process_data.ptd_cache.set(id, all_property_type_details)

	return result


func _validate_object_property(result, name:String, properties_to_reference:Dictionary, properties_to_exclude:Array, properties_to_include:Array, do_properties_to_include:bool, ruleset:Dictionary) -> bool:
	if name in properties_to_exclude: return false
	if ruleset.get('exclude_private_properties'):
		if name.begins_with('_') or name.begins_with('metadata/_'): return false
	if do_properties_to_include && name not in properties_to_include: return false
	# If reference is on "properties_to_reference" list. Set a reference of the property.
	if name in properties_to_reference:
		var reference_name = properties_to_reference[name]
		result.set(name, A2JReferenceTypeHandler.make_reference(reference_name))
		return false
	return true


func _resolve_reference(value, result, ruleset:Dictionary, object:Object, property:String, reference_to_resolve) -> Variant:
	var resolved_reference = A2J._from_json(reference_to_resolve)
	if resolved_reference is String && resolved_reference == '_A2J_unresolved_reference': resolved_reference = null

	# Set value as metadata.
	if property.begins_with('metadata/'):
		object.set_meta(property.replace('metadata/',''), resolved_reference)
	# Set value
	else: object.set(property, resolved_reference)

	return result


## Get the default object to compare properties to.
func _get_default_object(registered_object:Object, object_class:StringName, ruleset:Dictionary) -> Object:
	var instantiator_function = ruleset.get('instantiator_function', A2J._default_instantiator_function)
	var instantiator_arguments = ruleset.get('instantiator_arguments', {})
	if instantiator_function is not Callable:
		instantiator_function = A2J._default_instantiator_function
		report_error(3)
	# Correct instantiator arguments to be dictionary if it isn't.
	if instantiator_arguments is not Dictionary:
		instantiator_arguments = {}
		report_error(4)
	# Get arguments.
	var args = instantiator_arguments.get(object_class)
	# If no instantiation arguments provided, call with no arguments.
	if args is not Array or args.is_empty():
		return instantiator_function.call(registered_object, object_class)
	# Otherwise, call with arguments.
	else:
		return instantiator_function.call(registered_object, object_class, args)


func _get_all_property_type_details(object:Object) -> Dictionary[String,Dictionary]:
	var properties:Dictionary[String,Dictionary] = {}
	var property_list := object.get_property_list()
	for item in property_list:
		if item.name.begins_with('metadata/'): continue
		properties.set(item.name, {
			'class_name': item.class_name,
			'type': item.type,
			'hint_string': item.hint_string,
		})
	return properties
