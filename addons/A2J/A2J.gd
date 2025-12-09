@tool
## Main API for the Any-JSON plugin.
class_name A2J extends RefCounted


## Primitive types that do not require handlers.
const primitive_types:Array[Variant.Type] = [
	TYPE_NIL,
	TYPE_BOOL,
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_STRING,
]

## The default ruleset used when calling [code]to_json[/code].
const default_ruleset_to:Dictionary = {
	'type_exclusions': [
		'RID',
		'Signal',
		'Callable',
	],
	'type_inclusions': [],
	'class_exclusions': [],
	'class_inclusions': [],
	'property_exclusions': {
		# Exclude all resource properties when converting to AJSON.
		'Resource': [
			'resource_local_to_scene',
			'resource_path',
			'resource_name',
			'resource_scene_unique_id',
			'resource_priority',
		],
	},
	'property_inclusions': {},
	'exclude_private_properties': true, # Exclude properties that start with an underscore "_".
	'exclude_properties_set_to_default': true, # Exclude properties whoms values are the same as the default of that property. This is used to reduce the amount of data we have to store, but isn't recommended if the defaults of class properties are expected to change.
	'property_references': {}, # Property names that will be converted to references instead of being converted to JSON representations of that property.
	'instantiator_arguments': {}, # Arguments that will be passed to the object's `new` method. 
	'fppe_mitigation': false, # Floating point precision error mitigation.
}

## The default ruleset used when calling [code]from_json[/code].
const default_ruleset_from:Dictionary = {
	'type_exlcusions': default_ruleset_to.type_exclusions,
	'property_exclusions': default_ruleset_to.property_exclusions,
	'exclude_private_properties': true,
	'references': {}, # Named references & the values to assign to them.
}

const error_strings:PackedStringArray = [
	'No handler implemented for type "~~". Make a handler with the abstract A2JTypeHandler class.',
	'"type_exclusions" & "type_inclusions" in ruleset should be structured as follows: Array[String].',
	'"class_exclusions" & "class_inclusions" in ruleset should be structured as follows: Array[String].',
]

# Template for instantiator function.
static func _default_instantiator_function(registered_object:Object, _object_class:String, args:Array=[]) -> Object:
	return registered_object.callv('new', args)


static var _vector_type_handler := A2JVectorTypeHandler.new()
static var _packed_array_type_handler := A2JPackedArrayTypeHandler.new()
static var _misc_type_handler := A2JMiscTypeHandler.new()
## A2JTypeHandlers that can be used.
## You can add custom type handlers here.
static var type_handlers:Dictionary[String,A2JTypeHandler] = {
	'A2JRef':A2JReferenceTypeHandler.new(),
	'Object':A2JObjectTypeHandler.new(),
	'Array':A2JArrayTypeHandler.new(),
	'Dictionary':A2JDictionaryTypeHandler.new(),
	'Vector':_vector_type_handler, 'Vector2':_vector_type_handler, 'Vector2i':_vector_type_handler,
	'Vector3':_vector_type_handler, 'Vector3i':_vector_type_handler,
	'Vector4':_vector_type_handler, 'Vector4i':_vector_type_handler,
	'PackedByteArray':_packed_array_type_handler,
	'PackedInt32Array':_packed_array_type_handler, 'PackedInt64Array':_packed_array_type_handler,
	'PackedFloat32Array':_packed_array_type_handler, 'PackedFloat64Array':_packed_array_type_handler,
	'PackedVector2Array':_packed_array_type_handler, 'PackedVector3Array':_packed_array_type_handler, 'PackedVector4Array':_packed_array_type_handler,
	'PackedColorArray':_packed_array_type_handler,
	'PackedStringArray':_packed_array_type_handler,
	'StringName':_misc_type_handler,
	'NodePath':_misc_type_handler,
	'Color':_misc_type_handler,
	'Plane':_misc_type_handler,
	'Quaternion':_misc_type_handler,
	'Rect2':_misc_type_handler, 'Rect2i':_misc_type_handler,
	'AABB':_misc_type_handler,
	'Basis':_misc_type_handler,
	'Transform2D':_misc_type_handler, 'Transform3D':_misc_type_handler,
	'Projection':_misc_type_handler,
}

## Set of recognized objects used for conversion to & from AJSON.
## You can safely add or remove objects from this registry as you see fit.
## [br][br]
## Is equipped with many (but not all) built-in Godot classes by default.
static var object_registry:Dictionary[StringName,Object] = {
	'Object':Object, 'RefCounted':RefCounted, 'Resource':Resource, 'Script':Script, 'GDScript':GDScript, 'GDExtension':GDExtension,
	# Shader.
	'Shader':Shader, 'ShaderInclude':ShaderInclude, 'VisualShader':VisualShader, 'VisualShaderNode':VisualShaderNode,
	# Texture.
	'Texture':Texture, 'Texture2D':Texture2D, 'AnimatedTexture':AnimatedTexture, 'AtlasTexture':AtlasTexture, 'CameraTexture':CameraTexture, 'CanvasTexture':CanvasTexture, 'CompressedTexture2D':CompressedTexture2D, 'CurveTexture':CurveTexture, 'CurveXYZTexture':CurveXYZTexture, 'DPITexture':DPITexture, 'ExternalTexture':ExternalTexture, 'GradientTexture1D':GradientTexture1D, 'GradientTexture2D':GradientTexture2D, 'ImageTexture':ImageTexture, 'ImageTexture3D':ImageTexture3D, 'MeshTexture':MeshTexture, 'NoiseTexture2D':NoiseTexture2D, 'NoiseTexture3D':NoiseTexture3D, 'PlaceholderTexture2D':PlaceholderTexture2D, 'ViewportTexture':ViewportTexture,
	# Animation.
	'Animation':Animation, 'AnimationLibrary':AnimationLibrary, 'AnimationNode':AnimationNode, 'AnimationNodeAdd2':AnimationNodeAdd2, 'AnimationNodeAdd3':AnimationNodeAdd3, 'AnimationNodeAnimation':AnimationNodeAnimation, 'AnimationNodeBlend2':AnimationNodeBlend2, 'AnimationNodeBlend3':AnimationNodeBlend3, 'AnimationNodeBlendSpace1D':AnimationNodeBlendSpace1D, 'AnimationNodeBlendSpace2D':AnimationNodeBlendSpace2D, 'AnimationNodeBlendTree':AnimationNodeBlendTree, 'AnimationNodeExtension':AnimationNodeExtension, 'AnimationNodeOneShot':AnimationNodeOneShot, 'AnimationNodeOutput':AnimationNodeOutput, 'AnimationNodeStateMachine':AnimationNodeStateMachine,
	# Mesh.
	'Mesh':Mesh, 'ArrayMesh':ArrayMesh, 'PrimitiveMesh':PrimitiveMesh, 'BoxMesh':BoxMesh, 'CapsuleMesh':CapsuleMesh, 'CylinderMesh':CylinderMesh, 'PlaneMesh':PlaneMesh, 'QuadMesh':QuadMesh, 'PointMesh':PointMesh, 'PrismMesh':PrismMesh, 'RibbonTrailMesh':RibbonTrailMesh, 'SphereMesh':SphereMesh, 'TextMesh':TextMesh, 'TorusMesh':TorusMesh, 'TubeTrailMesh':TubeTrailMesh, 'PlaceholderMesh':PlaceholderMesh, 'ImmediateMesh':ImmediateMesh,
	# Material.
	'Material':Material, 'ShaderMaterial':ShaderMaterial, 'CanvasItemMaterial':CanvasItemMaterial, 'PanoramaSkyMaterial':PanoramaSkyMaterial, 'ParticleProcessMaterial':ParticleProcessMaterial, 'PhysicalSkyMaterial':PhysicalSkyMaterial, 'ProceduralSkyMaterial':ProceduralSkyMaterial, 'StandardMaterial3D':StandardMaterial3D, 'ORMMaterial3D':ORMMaterial3D, 'FogMaterial':FogMaterial, 'PlaceholderMaterial':PlaceholderMaterial,
	# Occluder3D.
	'Occluder3D':Occluder3D, 'ArrayOccluder3D':ArrayOccluder3D, 'BoxOccluder3D':BoxOccluder3D, 'PolygonOccluder3D':PolygonOccluder3D, 'QuadOccluder3D':QuadOccluder3D, 'SphereOccluder3D':SphereOccluder3D,
	# AudioBusLayout / AudioEffect / AudioStream.
	'AudioBusLayout':AudioBusLayout, 'AudioEffect':AudioEffect, 'AudioEffectAmplify':AudioEffectAmplify, 'AudioEffectChorus':AudioEffectChorus, 'AudioEffectCompressor':AudioEffectCompressor, 'AudioEffectDelay':AudioEffectDelay, 'AudioEffectDistortion':AudioEffectDistortion, 'AudioEffectReverb':AudioEffectReverb, 'AudioEffectPhaser':AudioEffectPhaser, 'AudioEffectFilter':AudioEffectFilter,
	'AudioStream':AudioStream, 'AudioStreamGenerator':AudioStreamGenerator, 'AudioStreamGeneratorPlayback':AudioStreamGeneratorPlayback, 'AudioStreamInteractive':AudioStreamInteractive, 'AudioStreamMicrophone':AudioStreamMicrophone, 'AudioStreamMP3':AudioStreamMP3, 'AudioStreamOggVorbis':AudioStreamOggVorbis, 'AudioStreamPlayback':AudioStreamPlayback, 'AudioStreamPlaybackInteractive':AudioStreamPlaybackInteractive, 'AudioStreamPlaybackOggVorbis':AudioStreamPlaybackOggVorbis, 'AudioStreamPlaybackPlaylist':AudioStreamPlaybackPlaylist, 'AudioStreamPlaybackPolyphonic':AudioStreamPlaybackPolyphonic, 'AudioStreamPlaybackResampled':AudioStreamPlaybackResampled, 'AudioStreamPlaybackSynchronized':AudioStreamPlaybackSynchronized,
	# Shape.
	'Shape2D':Shape2D, 'CapsuleShape2D':CapsuleShape2D, 'CircleShape2D':CircleShape2D, 'ConcavePolygonShape2D':ConcavePolygonShape2D, 'ConvexPolygonShape2D':ConvexPolygonShape2D, 'RectangleShape2D':RectangleShape2D, 'SegmentShape2D':SegmentShape2D, 'SeparationRayShape2D':SeparationRayShape2D, 'WorldBoundaryShape2D':WorldBoundaryShape2D,
	'BoxShape3D':BoxShape3D, 'CapsuleShape3D':CapsuleShape3D, 'ConcavePolygonShape3D':ConcavePolygonShape3D, 'ConvexPolygonShape3D':ConvexPolygonShape3D, 'CylinderShape3D':CylinderShape3D, 'HeightMapShape3D':HeightMapShape3D, 'SeparationRayShape3D':SeparationRayShape3D, 'SphereShape3D':SphereShape3D, 'WorldBoundaryShape3D':WorldBoundaryShape3D,
	# # Theme / StyleBox / Font.
	'FontFile':FontFile, 'FontVariation':FontVariation, 'SystemFont':SystemFont,
	'Theme':Theme, 'StyleBoxEmpty':StyleBoxEmpty, 'StyleBoxFlat':StyleBoxFlat, 'StyleBoxLine':StyleBoxLine, 'StyleBoxTexture':StyleBoxTexture,
	# Multiplayer.
	'SceneMultiplayer':SceneMultiplayer, 'MultiplayerPeer':MultiplayerPeer, 'OfflineMultiplayerPeer':OfflineMultiplayerPeer, 'ENetMultiplayerPeer':ENetMultiplayerPeer, 'MultiplayerPeerExtension':MultiplayerPeerExtension,
	# InputEvent.
	'InputEventAction':InputEventAction, 'InputEventJoypadButton':InputEventJoypadButton, 'InputEventJoypadMotion':InputEventJoypadMotion, 'InputEventKey':InputEventKey, 'InputEventMagnifyGesture':InputEventMagnifyGesture, 'InputEventMIDI':InputEventMIDI, 'InputEventMouseButton':InputEventMouseButton, 'InputEventMouseMotion':InputEventMouseMotion, 'InputEventPanGesture':InputEventPanGesture, 'InputEventScreenDrag':InputEventScreenDrag, 'InputEventScreenTouch':InputEventScreenTouch, 'InputEventShortcut':InputEventShortcut,
	# Misc.
	'BitMap':BitMap, 'BoneMap':BoneMap, 'ColorPalette':ColorPalette, 'Curve':Curve, 'Curve2D':Curve2D, 'Curve3D':Curve3D, 'CameraAttributes':CameraAttributes, 'CameraAttributesPhysical':CameraAttributesPhysical, 'CameraAttributesPractical':CameraAttributesPractical, 'LabelSettings':LabelSettings, 'SyntaxHighlighter':SyntaxHighlighter, 'CodeHighlighter':CodeHighlighter, 'Translation':Translation, 'OptimizedTranslation':OptimizedTranslation, 'PhysicsMaterial':PhysicsMaterial, 'ButtonGroup':ButtonGroup,
	# Node.
	'Node':Node,
	'Window':Window, 'FileDialog':FileDialog, 'AcceptDialog':AcceptDialog, 'ConfirmationDialog':ConfirmationDialog, 'EditorFileDialog':EditorFileDialog, 'ScriptCreateDialog':ScriptCreateDialog, 'Popup':Popup, 'PopupMenu':PopupMenu, 'PopupPanel':PopupPanel,
	'AudioStreamPlayer':AudioStreamPlayer, 'AudioStreamPlayer2D':AudioStreamPlayer2D, 'AudioStreamPlayer3D':AudioStreamPlayer3D,
	'CanvasLayer':CanvasLayer, 'CanvasGroup':CanvasGroup, 'CanvasModulate':CanvasModulate, 'Parallax2D':Parallax2D,
	'Control':Control, 'Node2D':Node2D, 'Node3D':Node3D, 'Camera2D':Camera2D, 'Camera3D':Camera3D,
}


## Data that [A2JTypeHandler] objects can share & use during serialization.
## Cleared before & after [code]to_json[/code] or [code]from_json[/code] is called.
static var _process_data:Dictionary = {}

## Array of functions for [A2JTypeHandler] objects to add to. Will be called in order after the main serialization has completed.
static var _process_next_pass_functions:Array[Callable] = []


## Report an error to Any-JSON.
## [param translations] should be strings.
static func report_error(error:int, ...translations) -> void:
	var a2jError_ = A2JTypeHandler.a2jError % 'A2J'
	var message = error_strings.get(error)
	if message is not String: printerr(a2jError_+str(error))
	else:
		var translated_message:String = message
		for tr in translations:
			if tr is not String: continue
			translated_message = translated_message.replace('~~', tr)
		printerr(a2jError_+translated_message)


## Convert [param value] to an AJSON object or a JSON friendly value.
## If [param value] is an [Object], only objects in the [code]object_registry[/code] can be converted.
## [br][br]
## Returns [code]null[/code] if failed.
static func to_json(value:Variant, ruleset:=default_ruleset_to) -> Variant:
	_process_next_pass_functions.clear()
	_process_data.clear()
	_init_handler_data()
	var result = _to_json(value, ruleset)
	result = _call_next_pass_functions(value, result, ruleset)
	_process_data.clear()
	return result


static func _to_json(value:Variant, ruleset:=default_ruleset_to) -> Variant:
	# Get type of value.
	var type := type_string(typeof(value))
	var object_class: String
	if type == 'Object': object_class = A2JUtil.get_class_name(value)

	# If type excluded, return null.
	if _type_excluded(type, ruleset): return null
	# If class excluded, return null.
	elif object_class && _class_excluded(object_class, ruleset): return null
	# If type is primitive, return the value unchanged.
	if typeof(value) in primitive_types:
		if value is float && ruleset.get('fppe_mitigation'):
			value = snappedf(value, 0.00000001)
		return value

	# Get type handler.
	var handler = type_handlers.get(type, null)
	if handler == null:
		report_error(0, type)
		return null
	handler = handler as A2JTypeHandler

	# Call midpoint function.
	var midpoint = ruleset.get('midpoint')
	if midpoint is Callable:
		# If returns true, discard conversion.
		if midpoint.call(value, ruleset) == true: return null

	# Return converted value.
	return handler.to_json(value, ruleset)


## Convert [param value] to it's original value. Returns [code]null[/code] if failed.
static func from_json(value, ruleset:=default_ruleset_from) -> Variant:
	_process_next_pass_functions.clear()
	_process_data.clear()
	_init_handler_data()
	var result = _from_json(value, ruleset)
	result = _call_next_pass_functions(value, result, ruleset)
	_process_data.clear()
	return result


## [param type_details] tells the function how to type the result.
static func _from_json(value, ruleset:=default_ruleset_from, type_details:Dictionary={}) -> Variant:
	# Get type of value.
	var type: String
	var object_class: String
	if value is Dictionary:
		var split_type:Array = value.get('.type', '').split(':')
		type = split_type[0]
		if split_type.size() == 2: object_class = split_type[1]
		if type == '': type = 'Dictionary'
	elif value is Array: type = 'Array'
	else: type = type_string(typeof(value))

	# If type excluded, return null.
	if _type_excluded(type, ruleset): return null
	# If class excluded, return null.
	elif object_class && _class_excluded(object_class, ruleset): return null
	# If type is primitive.
	elif typeof(value) in primitive_types:
		# If float is a whole number, convert to an int (JSON in Godot converts ints to floats, we need to convert them back).
		if value is float && fmod(value, 1) == 0: return int(value)
		return value

	# Get type handler.
	var handler = type_handlers.get(type, null)
	if handler == null:
		report_error(0, type)
		return null
	handler = handler as A2JTypeHandler

	# Call midpoint function.
	var midpoint = ruleset.get('midpoint')
	if midpoint is Callable:
		# If returns true, discard conversion.
		if midpoint.call(value, ruleset) == true: return null

	# Convert value.
	var result = handler.from_json(value, ruleset)
	# Type dictionary.
	if result is Dictionary && type_details.get('type') == TYPE_DICTIONARY && type_details.get('hint_string') is String:
		var hint_string:PackedStringArray = (type_details.get('hint_string') as String).split(';')
		if hint_string.size() == 2:
			var key_type = A2JUtil.variant_type_string_map.find_key(hint_string[0])
			var value_type = A2JUtil.variant_type_string_map.find_key(hint_string[1])
			var key_class_name := &''
			var value_class_name := &''
			var key_script = null
			var value_script = null
			if key_type == TYPE_OBJECT:
				key_class_name = hint_string[0]
				key_script = object_registry.get(key_class_name)
			if value_type == TYPE_OBJECT:
				value_class_name = hint_string[1]
				value_script = object_registry.get(value_class_name)
			
			result = Dictionary(result,
				key_type, key_class_name, key_script,
				value_type, value_class_name, value_script,
			)
	# Type array.
	elif result is Array && type_details.get('type') == TYPE_ARRAY && type_details.get('hint_string') is String:
		var hint_string:PackedStringArray = (type_details.get('hint_string') as String).split(';')
		if hint_string.size() == 1:
			var value_type = A2JUtil.variant_type_string_map.find_key(hint_string[0])
			var value_class_name = ''
			var value_script = null
			if value_type == TYPE_OBJECT:
				value_class_name = hint_string[1]
				value_script = object_registry.get(value_class_name)
			
			result = Array(result, value_type, value_class_name, value_script)
	# Type other.
	elif type_details.get('type') is int:
		result = type_convert(result, type_details.get('type'))
	# Return result.
	return result




static func _type_excluded(type:String, ruleset:Dictionary) -> bool:
	# Get type exclusions & inclusions.
	var type_exclusions = ruleset.get('type_exclusions', [])
	var type_inclusions = ruleset.get('type_inclusions', [])
	# Throw error if is not an array.
	if type_exclusions is not Array or type_inclusions is not Array:
		report_error(1)
		return true
	# If type is excluded, return true.
	if type in type_exclusions or (type_inclusions.size() > 0 && type not in type_inclusions):
		return true

	return false


static func _class_excluded(object_class:String, ruleset:Dictionary) -> bool:
	# Get class exclusions & inclusions.
	var class_exclusions = ruleset.get('class_exclusions', [])
	var class_inclusions = ruleset.get('class_inclusions', [])
	# Throw error if is not an array.
	if class_exclusions is not Array or class_inclusions is not Array:
		report_error(2)
		return true
	# If class is excluded, return true.
	if object_class in class_exclusions or (class_inclusions.size() > 0 && object_class not in class_inclusions):
		return true

	return false


static func _init_handler_data() -> void:
	for key in type_handlers:
		var handler:A2JTypeHandler = type_handlers[key]
		_process_data.merge(handler.init_data.duplicate(true), true)


static func _call_next_pass_functions(value, result, ruleset:Dictionary) -> Variant:
	for callable in _process_next_pass_functions:
		result = callable.call(value, result, ruleset)
	return result
