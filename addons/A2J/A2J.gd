@tool
## Main API for the Any-JSON plugin.
class_name A2J extends RefCounted

## Primitive types that do not require handlers.
const primitive_types:Array[Variant.Type] = [
	TYPE_BOOL,
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_STRING,
]

## The default ruleset used when calling [code]to_json[/code].
const default_ruleset_to := {
	'type_exclusions': [
		'Callable'
	],
	'property_exclusions': {
		# Exclude all resource properties when converting to AJSON.
		'Resource': [
			'resource_local_to_scene',
			'resource_path',
			'resource_name',
			'resource_scene_unique_id',
			'resource_priority',
		],
		'Node': [
			'_import_path',
		],
	},
	'convert_properties_to_references': {}, # Define property names that will be converted to references instead of being converted to JSON representations of that property.
}

## The default ruleset used when calling [code]from_json[/code].
const default_ruleset_from := {
	'property_exclusions': default_ruleset_to.property_exclusions,
	'named_references': {}, # Define named references & the value to assign to them.
}

const error_strings := [
	'No handler implemented for type "~~". Make a handler with the abstract A2JTypeHandler class.',
	'"type_exclusions" in ruleset should be structured as follows: Array[String].',
]

static var _vector_type_handler := A2JVectorTypeHandler.new()
static var _packed_array_type_handler := A2JPackedArrayTypeHandler.new()
static var _misc_type_handler := A2JMiscTypeHandler.new()
## A2JTypeHandlers that can be used.
## You can add custom type handlers here.
static var type_handlers:Dictionary[String,A2JTypeHandler] = {
	'A2JReference': A2JReferenceTypeHandler.new(),
	'Object': A2JObjectTypeHandler.new(),
	'Array': A2JArrayTypeHandler.new(),
	'Dictionary': A2JDictionaryTypeHandler.new(),
	'Vector': _vector_type_handler, 'Vector2': _vector_type_handler, 'Vector2i': _vector_type_handler,
	'Vector3': _vector_type_handler, 'Vector3i': _vector_type_handler,
	'Vector4': _vector_type_handler, 'Vector4i': _vector_type_handler,
	'PackedByteArray': _packed_array_type_handler,
	'PackedInt32Array': _packed_array_type_handler, 'PackedInt64Array': _packed_array_type_handler,
	'PackedFloat32Array': _packed_array_type_handler, 'PackedFloat64Array': _packed_array_type_handler,
	'PackedVector2Array': _packed_array_type_handler, 'PackedVector3Array': _packed_array_type_handler, 'PackedVector4Array': _packed_array_type_handler,
	'PackedColorArray': _packed_array_type_handler,
	'PackedStringArray': _packed_array_type_handler,
	'StringName': _misc_type_handler,
	'NodePath': _misc_type_handler,
	'Color': _misc_type_handler,
	'Plane': _misc_type_handler,
	'Quaternion': _misc_type_handler,
	'Rect2': _misc_type_handler, 'Rect2i': _misc_type_handler,
	'AABB': _misc_type_handler,
	'Basis': _misc_type_handler,
	'Transform2D': _misc_type_handler, 'Transform3D': _misc_type_handler,
	'Projection': _misc_type_handler,
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
	'Material':Material, 'ShaderMaterial':ShaderMaterial, 'CanvasItemMaterial':CanvasItemMaterial, 'PanoramaSkyMaterial':PanoramaSkyMaterial, 'ParticleProcessMaterial':ParticleProcessMaterial, 'StandardMaterial3D':StandardMaterial3D, 'ORMMaterial3D':ORMMaterial3D, 'FogMaterial':FogMaterial, 'PlaceholderMaterial':PlaceholderMaterial,
	# Occluder3D.
	'Occluder3D':Occluder3D, 'ArrayOccluder3D':ArrayOccluder3D, 'BoxOccluder3D':BoxOccluder3D, 'PolygonOccluder3D':PolygonOccluder3D, 'QuadOccluder3D':QuadOccluder3D, 'SphereOccluder3D':SphereOccluder3D,
	# AudioBusLayout / AudioEffect.
	'AudioBusLayout':AudioBusLayout, 'AudioEffect':AudioEffect, 'AudioEffectAmplify':AudioEffectAmplify, 'AudioEffectChorus':AudioEffectChorus, 'AudioEffectCompressor':AudioEffectCompressor, 'AudioEffectDelay':AudioEffectDelay, 'AudioEffectDistortion':AudioEffectDistortion, 'AudioEffectReverb':AudioEffectReverb, 'AudioEffectPhaser':AudioEffectPhaser, 'AudioEffectFilter':AudioEffectFilter,
	# AudioStream.
	'AudioStream':AudioStream, 'AudioStreamGenerator':AudioStreamGenerator, 'AudioStreamGeneratorPlayback':AudioStreamGeneratorPlayback, 'AudioStreamInteractive':AudioStreamInteractive, 'AudioStreamMicrophone':AudioStreamMicrophone, 'AudioStreamMP3':AudioStreamMP3, 'AudioStreamOggVorbis':AudioStreamOggVorbis, 'AudioStreamPlayback':AudioStreamPlayback, 'AudioStreamPlaybackInteractive':AudioStreamPlaybackInteractive, 'AudioStreamPlaybackOggVorbis':AudioStreamPlaybackOggVorbis, 'AudioStreamPlaybackPlaylist':AudioStreamPlaybackPlaylist, 'AudioStreamPlaybackPolyphonic':AudioStreamPlaybackPolyphonic, 'AudioStreamPlaybackResampled':AudioStreamPlaybackResampled, 'AudioStreamPlaybackSynchronized':AudioStreamPlaybackSynchronized,
	# Shape2D.
	'Shape2D':Shape2D, 'CapsuleShape2D':CapsuleShape2D, 'CircleShape2D':CircleShape2D, 'ConcavePolygonShape2D':ConcavePolygonShape2D, 'ConvexPolygonShape2D':ConvexPolygonShape2D, 'RectangleShape2D':RectangleShape2D, 'SegmentShape2D':SegmentShape2D, 'SeparationRayShape2D':SeparationRayShape2D, 'WorldBoundaryShape2D':WorldBoundaryShape2D,
	# Shape3D.
	'BoxShape3D':BoxShape3D, 'CapsuleShape3D':CapsuleShape3D, 'ConcavePolygonShape3D':ConcavePolygonShape3D, 'ConvexPolygonShape3D':ConvexPolygonShape3D, 'CylinderShape3D':CylinderShape3D, 'HeightMapShape3D':HeightMapShape3D, 'SeparationRayShape3D':SeparationRayShape3D, 'SphereShape3D':SphereShape3D, 'WorldBoundaryShape3D':WorldBoundaryShape3D,
	# Font.
	'FontFile':FontFile, 'FontVariation':FontVariation, 'SystemFont':SystemFont,
	# Theme / StyleBox.
	'Theme':Theme, 'StyleBoxEmpty':StyleBoxEmpty, 'StyleBoxFlat':StyleBoxFlat, 'StyleBoxLine':StyleBoxLine, 'StyleBoxTexture':StyleBoxTexture,
	# Misc.
	'BitMap':BitMap, 'BoneMap':BoneMap, 'Curve':Curve, 'Curve2D':Curve2D, 'Curve3D':Curve3D, 'CameraAttributes':CameraAttributes, 'CameraAttributesPhysical':CameraAttributesPhysical, 'CameraAttributesPractical':CameraAttributesPractical,
	# Node.
	'Node':Node, 'Control':Control, 'Node2D':Node2D, 'Node3D':Node3D, 'Camera2D':Camera2D, 'Camera3D':Camera3D, 'AudioStreamPlayer2D':AudioStreamPlayer2D, 'AudioStreamPlayer3D':AudioStreamPlayer3D,
}


## Report an error to Any-JSON.
## [param translations] should be strings.
static func report_error(error:int, ...translations) -> void:
	var a2jError_ = A2JTypeHandler.a2jError % 'A2J'
	var message = error_strings.get(error)
	if not message:
		printerr(a2jError_+str(error))
	else:
		var translated_message = message
		for tr in translations:
			if tr is not String: continue
			translated_message = translated_message.replace('~~', tr)
		printerr(a2jError_+translated_message)


## Convert [param value] to an AJSON object or a JSON friendly value.
## If [param value] is an Object, only objects in the Object Registry can be converted.
static func to_json(value:Variant, ruleset=default_ruleset_to) -> Variant:
	# Get type of value.
	var type := type_string(typeof(value))
	if type == 'Dictionary':
		type = value.get('.type', '').split(':')[0]
		if type == '': type = 'Dictionary'

	# Check if type is in type exclusions.
	var type_exclusions = ruleset.get('type_exclusions', [])
	# Throw error if type exclusions is not an array.
	if type_exclusions is not Array:
		report_error(1)
		return null
	# If type is excluded, return null.
	if type in type_exclusions:
		return null

	# If type is primitive, return the value unchanged.
	if typeof(value) in primitive_types:
		return value

	# Get type handler.
	var handler = type_handlers.get(type, null)
	if handler == null:
		report_error(0, type)
		return null
	handler = handler as A2JTypeHandler

	# Return converted value.
	return handler.to_json(value, ruleset)


## Convert [param value] to it's original value.
static func from_json(value, ruleset=default_ruleset_from) -> Variant:
	# Get type of value.
	var type: String
	if value is Dictionary:
		type = value.get('.type', '').split(':')[0]
		if type == '': type = 'Dictionary'
	elif value is Array:
		type = 'Array'

	# Check if type is in type exclusions.
	var type_exclusions = ruleset.get('type_exclusions', [])
	# Throw error if type exclusions is not an array.
	if type_exclusions is not Array:
		report_error(1)
		return null
	# If type is excluded, return null.
	if type in type_exclusions:
		return null

	# If type is primitive, return value unchanged.
	elif typeof(value) in primitive_types:
		return value

	# Get type handler.
	var handler = type_handlers.get(type, null)
	if handler == null:
		report_error(0, type)
		return null
	handler = handler as A2JTypeHandler

	# Return converted value.
	return handler.from_json(value, ruleset)
