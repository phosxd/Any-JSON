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
static func _default_instantiator_function(registered_object:Object, _object_class:StringName, args:Array=[]) -> Object:
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

## Set of recognized classes used for conversion to & from AJSON.
## You can safely add or remove classes from this registry as you see fit.
## [br][br]
## Is, by default; equipped with many but not all built-in Godot classes.
## [br]
## This also means if your game export excludes certain classes you may need to remove them from here.
static var object_registry:Dictionary[StringName,Object] = {
	'AESContext':AESContext, 'AStar2D':AStar2D, 'AStar3D':AStar3D, 'AStarGrid2D':AStarGrid2D, 'AcceptDialog':AcceptDialog, 
	'AimModifier3D':AimModifier3D, 'AnimatableBody2D':AnimatableBody2D, 'AnimatableBody3D':AnimatableBody3D, 'AnimatedSprite2D':AnimatedSprite2D, 'AnimatedSprite3D':AnimatedSprite3D, 
	'AnimatedTexture':AnimatedTexture, 'Animation':Animation, 'AnimationLibrary':AnimationLibrary, 'AnimationPlayer':AnimationPlayer, 'AnimationTree':AnimationTree, 
	'Area2D':Area2D, 'Area3D':Area3D, 'ArrayMesh':ArrayMesh, 'ArrayOccluder3D':ArrayOccluder3D, 'AspectRatioContainer':AspectRatioContainer, 
	'AtlasTexture':AtlasTexture, 'AudioBusLayout':AudioBusLayout, 'AudioEffectInstance':AudioEffectInstance, 'AudioListener2D':AudioListener2D, 'AudioListener3D':AudioListener3D, 
	'AudioSample':AudioSample, 'AudioSamplePlayback':AudioSamplePlayback, 'AudioServer':AudioServer, 'AudioStreamPlayback':AudioStreamPlayback, 'AudioStreamPlaybackOggVorbis':AudioStreamPlaybackOggVorbis, 
	'AudioStreamPlaybackResampled':AudioStreamPlaybackResampled, 'AudioStreamPlayer':AudioStreamPlayer, 'AudioStreamPlayer2D':AudioStreamPlayer2D, 'AudioStreamPlayer3D':AudioStreamPlayer3D, 'BackBufferCopy':BackBufferCopy, 
	'BaseButton':BaseButton, 'BitMap':BitMap, 'Bone2D':Bone2D, 'BoneAttachment3D':BoneAttachment3D, 'BoneConstraint3D':BoneConstraint3D, 
	'BoneMap':BoneMap, 'BoxContainer':BoxContainer, 'BoxMesh':BoxMesh, 'BoxOccluder3D':BoxOccluder3D, 'BoxShape3D':BoxShape3D, 
	'Button':Button, 'ButtonGroup':ButtonGroup, 'CPUParticles2D':CPUParticles2D, 'CPUParticles3D':CPUParticles3D, 'CSGBox3D':CSGBox3D, 
	'CSGCombiner3D':CSGCombiner3D, 'CSGCylinder3D':CSGCylinder3D, 'CSGMesh3D':CSGMesh3D, 'CSGPolygon3D':CSGPolygon3D, 'CSGSphere3D':CSGSphere3D, 
	'CSGTorus3D':CSGTorus3D, 'CallbackTweener':CallbackTweener, 'Camera2D':Camera2D, 'Camera3D':Camera3D, 'CameraAttributes':CameraAttributes, 
	'CameraAttributesPhysical':CameraAttributesPhysical, 'CameraAttributesPractical':CameraAttributesPractical, 'CameraFeed':CameraFeed, 'CameraServer':CameraServer, 'CameraTexture':CameraTexture, 
	'CanvasGroup':CanvasGroup, 'CanvasItemMaterial':CanvasItemMaterial, 'CanvasLayer':CanvasLayer, 'CanvasModulate':CanvasModulate, 'CanvasTexture':CanvasTexture, 
	'CapsuleMesh':CapsuleMesh, 'CapsuleShape2D':CapsuleShape2D, 'CapsuleShape3D':CapsuleShape3D, 'CenterContainer':CenterContainer, 'CharFXTransform':CharFXTransform, 
	'CharacterBody2D':CharacterBody2D, 'CharacterBody3D':CharacterBody3D, 'CheckBox':CheckBox, 'CheckButton':CheckButton, 'CircleShape2D':CircleShape2D, 
	'ClassDB':ClassDB, 'CodeEdit':CodeEdit, 'CodeHighlighter':CodeHighlighter, 'CollisionPolygon2D':CollisionPolygon2D, 'CollisionPolygon3D':CollisionPolygon3D, 
	'CollisionShape2D':CollisionShape2D, 'CollisionShape3D':CollisionShape3D, 'ColorPalette':ColorPalette, 'ColorPicker':ColorPicker, 'ColorPickerButton':ColorPickerButton, 
	'ColorRect':ColorRect, 'Compositor':Compositor, 'CompositorEffect':CompositorEffect, 'CompressedCubemap':CompressedCubemap, 'CompressedCubemapArray':CompressedCubemapArray, 
	'CompressedTexture2D':CompressedTexture2D, 'CompressedTexture2DArray':CompressedTexture2DArray, 'CompressedTexture3D':CompressedTexture3D, 'ConcavePolygonShape2D':ConcavePolygonShape2D, 'ConcavePolygonShape3D':ConcavePolygonShape3D, 
	'ConeTwistJoint3D':ConeTwistJoint3D, 'ConfigFile':ConfigFile, 'ConfirmationDialog':ConfirmationDialog, 'Container':Container, 'Control':Control, 
	'ConvertTransformModifier3D':ConvertTransformModifier3D, 'ConvexPolygonShape2D':ConvexPolygonShape2D, 'ConvexPolygonShape3D':ConvexPolygonShape3D, 'CopyTransformModifier3D':CopyTransformModifier3D, 'Crypto':Crypto, 
	'CryptoKey':CryptoKey, 'Cubemap':Cubemap, 'CubemapArray':CubemapArray, 'Curve':Curve, 'Curve2D':Curve2D, 
	'Curve3D':Curve3D, 'CurveTexture':CurveTexture, 'CurveXYZTexture':CurveXYZTexture, 'CylinderMesh':CylinderMesh, 'CylinderShape3D':CylinderShape3D, 
	'DPITexture':DPITexture, 'DTLSServer':DTLSServer, 'DampedSpringJoint2D':DampedSpringJoint2D, 'Decal':Decal, 'DirectionalLight2D':DirectionalLight2D, 
	'DirectionalLight3D':DirectionalLight3D, 'ENetConnection':ENetConnection, 'ENetMultiplayerPeer':ENetMultiplayerPeer, 'EncodedObjectAsID':EncodedObjectAsID, 'EngineDebugger':EngineDebugger, 
	'EngineProfiler':EngineProfiler, 'Environment':Environment, 'Expression':Expression, 'ExternalTexture':ExternalTexture, 'FastNoiseLite':FastNoiseLite, 
	'FileDialog':FileDialog, 'FlowContainer':FlowContainer, 'FogMaterial':FogMaterial, 'FogVolume':FogVolume, 'FoldableContainer':FoldableContainer, 
	'FoldableGroup':FoldableGroup, 'FontFile':FontFile, 'FontVariation':FontVariation, 'GDScript':GDScript, 'GDScriptSyntaxHighlighter':GDScriptSyntaxHighlighter, 
	'GLTFObjectModelProperty':GLTFObjectModelProperty, 'GPUParticles2D':GPUParticles2D, 'GPUParticles3D':GPUParticles3D, 'GPUParticlesAttractorBox3D':GPUParticlesAttractorBox3D, 'GPUParticlesAttractorSphere3D':GPUParticlesAttractorSphere3D, 
	'GPUParticlesAttractorVectorField3D':GPUParticlesAttractorVectorField3D, 'GPUParticlesCollisionBox3D':GPUParticlesCollisionBox3D, 'GPUParticlesCollisionHeightField3D':GPUParticlesCollisionHeightField3D, 'GPUParticlesCollisionSDF3D':GPUParticlesCollisionSDF3D, 'GPUParticlesCollisionSphere3D':GPUParticlesCollisionSphere3D, 
	'Generic6DOFJoint3D':Generic6DOFJoint3D, 'Geometry2D':Geometry2D, 'Geometry3D':Geometry3D, 'GeometryInstance3D':GeometryInstance3D, 'Gradient':Gradient, 
	'GradientTexture1D':GradientTexture1D, 'GradientTexture2D':GradientTexture2D, 'GraphEdit':GraphEdit, 'GraphElement':GraphElement, 'GraphFrame':GraphFrame, 
	'GraphNode':GraphNode, 'GridContainer':GridContainer, 'GridMap':GridMap, 'GridMapEditorPlugin':GridMapEditorPlugin, 'GrooveJoint2D':GrooveJoint2D, 
	'HBoxContainer':HBoxContainer, 'HFlowContainer':HFlowContainer, 'HScrollBar':HScrollBar, 'HSeparator':HSeparator, 'HSlider':HSlider, 
	'HSplitContainer':HSplitContainer, 'HTTPClient':HTTPClient, 'HTTPRequest':HTTPRequest, 'HashingContext':HashingContext, 'HeightMapShape3D':HeightMapShape3D, 
	'HingeJoint3D':HingeJoint3D, 'Image':Image, 'ImageFormatLoaderExtension':ImageFormatLoaderExtension, 'ImageTexture':ImageTexture, 'ImageTexture3D':ImageTexture3D, 
	'ImmediateMesh':ImmediateMesh, 'ImporterMesh':ImporterMesh, 'ImporterMeshInstance3D':ImporterMeshInstance3D, 'InputEventAction':InputEventAction, 'InputEventJoypadButton':InputEventJoypadButton, 
	'InputEventJoypadMotion':InputEventJoypadMotion, 'InputEventKey':InputEventKey, 'InputEventMIDI':InputEventMIDI, 'InputEventMagnifyGesture':InputEventMagnifyGesture, 'InputEventMouseButton':InputEventMouseButton, 
	'InputEventMouseMotion':InputEventMouseMotion, 'InputEventPanGesture':InputEventPanGesture, 'InputEventScreenDrag':InputEventScreenDrag, 'InputEventScreenTouch':InputEventScreenTouch, 'InputEventShortcut':InputEventShortcut, 
	'InputMap':InputMap, 'IntervalTweener':IntervalTweener, 'ItemList':ItemList, 'JNISingleton':JNISingleton, 'JSON':JSON, 
	'JSONRPC':JSONRPC, 'JavaClass':JavaClass, 'JavaClassWrapper':JavaClassWrapper, 'JavaObject':JavaObject, 'KinematicCollision2D':KinematicCollision2D, 
	'KinematicCollision3D':KinematicCollision3D, 'Label':Label, 'Label3D':Label3D, 'LabelSettings':LabelSettings, 'LightOccluder2D':LightOccluder2D, 
	'LightmapGI':LightmapGI, 'LightmapGIData':LightmapGIData, 'LightmapProbe':LightmapProbe, 'LightmapperRD':LightmapperRD, 'Line2D':Line2D, 
	'LineEdit':LineEdit, 'LinkButton':LinkButton, 'Logger':Logger, 'LookAtModifier3D':LookAtModifier3D, 'MainLoop':MainLoop, 
	'MarginContainer':MarginContainer, 'Marker2D':Marker2D, 'Marker3D':Marker3D, 'Material':Material, 'MenuBar':MenuBar, 
	'MenuButton':MenuButton, 'Mesh':Mesh, 'MeshConvexDecompositionSettings':MeshConvexDecompositionSettings, 'MeshDataTool':MeshDataTool, 'MeshInstance2D':MeshInstance2D, 
	'MeshInstance3D':MeshInstance3D, 'MeshLibrary':MeshLibrary, 'MeshTexture':MeshTexture, 'MethodTweener':MethodTweener, 'MissingNode':MissingNode, 
	'MissingResource':MissingResource, 'MobileVRInterface':MobileVRInterface, 'ModifierBoneTarget3D':ModifierBoneTarget3D, 'MovieWriter':MovieWriter, 'MultiMesh':MultiMesh, 
	'MultiMeshInstance2D':MultiMeshInstance2D, 'MultiMeshInstance3D':MultiMeshInstance3D, 'MultiplayerAPIExtension':MultiplayerAPIExtension, 'MultiplayerPeerExtension':MultiplayerPeerExtension, 'MultiplayerSpawner':MultiplayerSpawner, 
	'MultiplayerSynchronizer':MultiplayerSynchronizer, 'Mutex':Mutex, 'NativeMenu':NativeMenu, 'NavigationAgent2D':NavigationAgent2D, 'NavigationAgent3D':NavigationAgent3D, 
	'NavigationLink2D':NavigationLink2D, 'NavigationLink3D':NavigationLink3D, 'NavigationMesh':NavigationMesh, 'NavigationMeshGenerator':NavigationMeshGenerator, 'NavigationMeshSourceGeometryData2D':NavigationMeshSourceGeometryData2D, 
	'NavigationMeshSourceGeometryData3D':NavigationMeshSourceGeometryData3D, 'NavigationObstacle2D':NavigationObstacle2D, 'NavigationObstacle3D':NavigationObstacle3D, 'NavigationPathQueryParameters2D':NavigationPathQueryParameters2D, 'NavigationPathQueryParameters3D':NavigationPathQueryParameters3D, 
	'NavigationPathQueryResult2D':NavigationPathQueryResult2D, 'NavigationPathQueryResult3D':NavigationPathQueryResult3D, 'NavigationPolygon':NavigationPolygon, 'NavigationRegion2D':NavigationRegion2D, 'NavigationRegion3D':NavigationRegion3D, 
	'NinePatchRect':NinePatchRect, 'Node':Node, 'Node2D':Node2D, 'Node3D':Node3D, 'NoiseTexture2D':NoiseTexture2D, 
	'NoiseTexture3D':NoiseTexture3D, 'ORMMaterial3D':ORMMaterial3D, 'Object':Object, 'OccluderInstance3D':OccluderInstance3D, 'OccluderPolygon2D':OccluderPolygon2D, 
	'OfflineMultiplayerPeer':OfflineMultiplayerPeer, 'OggPacketSequence':OggPacketSequence, 'OggPacketSequencePlayback':OggPacketSequencePlayback, 'OmniLight3D':OmniLight3D, 'OptimizedTranslation':OptimizedTranslation, 
	'OptionButton':OptionButton, 'PCKPacker':PCKPacker, 'PackedDataContainer':PackedDataContainer, 'PackedScene':PackedScene, 'PacketPeerDTLS':PacketPeerDTLS, 
	'PacketPeerExtension':PacketPeerExtension, 'PacketPeerStream':PacketPeerStream, 'PacketPeerUDP':PacketPeerUDP, 'Panel':Panel, 'PanelContainer':PanelContainer, 
	'PanoramaSkyMaterial':PanoramaSkyMaterial, 'Parallax2D':Parallax2D, 'ParallaxBackground':ParallaxBackground, 'ParallaxLayer':ParallaxLayer, 'ParticleProcessMaterial':ParticleProcessMaterial, 
	'Path2D':Path2D, 'Path3D':Path3D, 'PathFollow2D':PathFollow2D, 'PathFollow3D':PathFollow3D, 'Performance':Performance, 
	'PhysicalBone2D':PhysicalBone2D, 'PhysicalBone3D':PhysicalBone3D, 'PhysicalBoneSimulator3D':PhysicalBoneSimulator3D, 'PhysicalSkyMaterial':PhysicalSkyMaterial, 'PhysicsDirectBodyState2DExtension':PhysicsDirectBodyState2DExtension, 
	'PhysicsDirectBodyState3DExtension':PhysicsDirectBodyState3DExtension, 'PhysicsDirectSpaceState2DExtension':PhysicsDirectSpaceState2DExtension, 'PhysicsDirectSpaceState3DExtension':PhysicsDirectSpaceState3DExtension, 'PhysicsMaterial':PhysicsMaterial, 'PhysicsPointQueryParameters2D':PhysicsPointQueryParameters2D, 
	'PhysicsPointQueryParameters3D':PhysicsPointQueryParameters3D, 'PhysicsRayQueryParameters2D':PhysicsRayQueryParameters2D, 'PhysicsRayQueryParameters3D':PhysicsRayQueryParameters3D, 'PhysicsServer2DExtension':PhysicsServer2DExtension, 'PhysicsServer2DManager':PhysicsServer2DManager, 
	'PhysicsServer3DExtension':PhysicsServer3DExtension, 'PhysicsServer3DManager':PhysicsServer3DManager, 'PinJoint2D':PinJoint2D, 'PinJoint3D':PinJoint3D, 'PlaceholderCubemap':PlaceholderCubemap, 
	'PlaceholderCubemapArray':PlaceholderCubemapArray, 'PlaceholderMaterial':PlaceholderMaterial, 'PlaceholderMesh':PlaceholderMesh, 'PlaceholderTexture2D':PlaceholderTexture2D, 'PlaceholderTexture2DArray':PlaceholderTexture2DArray, 
	'PlaceholderTexture3D':PlaceholderTexture3D, 'PlaneMesh':PlaneMesh, 'PointLight2D':PointLight2D, 'PointMesh':PointMesh, 'Polygon2D':Polygon2D, 
	'PolygonOccluder3D':PolygonOccluder3D, 'PolygonPathFinder':PolygonPathFinder, 'Popup':Popup, 'PopupMenu':PopupMenu, 'PopupPanel':PopupPanel, 
	'PortableCompressedTexture2D':PortableCompressedTexture2D, 'PrimitiveMesh':PrimitiveMesh, 'PrismMesh':PrismMesh, 'ProceduralSkyMaterial':ProceduralSkyMaterial, 'ProgressBar':ProgressBar, 
	'ProjectSettings':ProjectSettings, 'PropertyTweener':PropertyTweener, 'QuadMesh':QuadMesh, 'QuadOccluder3D':QuadOccluder3D, 'RandomNumberGenerator':RandomNumberGenerator, 
	'Range':Range, 'RayCast2D':RayCast2D, 'RayCast3D':RayCast3D, 'RectangleShape2D':RectangleShape2D, 'RefCounted':RefCounted, 
	'ReferenceRect':ReferenceRect, 'ReflectionProbe':ReflectionProbe, 'RegEx':RegEx, 'RegExMatch':RegExMatch, 'RemoteTransform2D':RemoteTransform2D, 
	'RemoteTransform3D':RemoteTransform3D, 'RenderDataExtension':RenderDataExtension, 'RenderDataRD':RenderDataRD, 'RenderSceneBuffersConfiguration':RenderSceneBuffersConfiguration, 'RenderSceneBuffersExtension':RenderSceneBuffersExtension, 
	'RenderSceneBuffersRD':RenderSceneBuffersRD, 'RenderSceneDataExtension':RenderSceneDataExtension, 'RenderSceneDataRD':RenderSceneDataRD, 'Resource':Resource, 'ResourceFormatLoader':ResourceFormatLoader, 
	'ResourceFormatSaver':ResourceFormatSaver, 'ResourceImporterBMFont':ResourceImporterBMFont, 'ResourceImporterBitMap':ResourceImporterBitMap, 'ResourceImporterCSVTranslation':ResourceImporterCSVTranslation, 'ResourceImporterDynamicFont':ResourceImporterDynamicFont, 
	'ResourceImporterImage':ResourceImporterImage, 'ResourceImporterImageFont':ResourceImporterImageFont, 'ResourceImporterLayeredTexture':ResourceImporterLayeredTexture, 'ResourceImporterMP3':ResourceImporterMP3, 'ResourceImporterOBJ':ResourceImporterOBJ, 
	'ResourceImporterOggVorbis':ResourceImporterOggVorbis, 'ResourceImporterSVG':ResourceImporterSVG, 'ResourceImporterScene':ResourceImporterScene, 'ResourceImporterShaderFile':ResourceImporterShaderFile, 'ResourceImporterTexture':ResourceImporterTexture, 
	'ResourceImporterTextureAtlas':ResourceImporterTextureAtlas, 'ResourceImporterWAV':ResourceImporterWAV, 'ResourceLoader':ResourceLoader, 'ResourcePreloader':ResourcePreloader, 'ResourceSaver':ResourceSaver, 
	'RetargetModifier3D':RetargetModifier3D, 'RibbonTrailMesh':RibbonTrailMesh, 'RichTextEffect':RichTextEffect, 'RichTextLabel':RichTextLabel, 'RigidBody2D':RigidBody2D, 
	'RigidBody3D':RigidBody3D, 'RootMotionView':RootMotionView, 'SceneMultiplayer':SceneMultiplayer, 'SceneReplicationConfig':SceneReplicationConfig, 'SceneTree':SceneTree, 
	'ScriptCreateDialog':ScriptCreateDialog, 'ScrollContainer':ScrollContainer, 'SegmentShape2D':SegmentShape2D, 'Semaphore':Semaphore, 'SeparationRayShape2D':SeparationRayShape2D, 
	'SeparationRayShape3D':SeparationRayShape3D, 'Shader':Shader, 'ShaderGlobalsOverride':ShaderGlobalsOverride, 'ShaderInclude':ShaderInclude, 'ShaderMaterial':ShaderMaterial, 
	'ShapeCast2D':ShapeCast2D, 'ShapeCast3D':ShapeCast3D, 'Shortcut':Shortcut, 'Skeleton2D':Skeleton2D, 'Skeleton3D':Skeleton3D, 
	'SkeletonIK3D':SkeletonIK3D, 'SkeletonModification2D':SkeletonModification2D, 'SkeletonModification2DCCDIK':SkeletonModification2DCCDIK, 'SkeletonModification2DFABRIK':SkeletonModification2DFABRIK, 'SkeletonModification2DJiggle':SkeletonModification2DJiggle, 
	'SkeletonModification2DLookAt':SkeletonModification2DLookAt, 'SkeletonModification2DPhysicalBones':SkeletonModification2DPhysicalBones, 'SkeletonModification2DStackHolder':SkeletonModification2DStackHolder, 'SkeletonModification2DTwoBoneIK':SkeletonModification2DTwoBoneIK, 'SkeletonModificationStack2D':SkeletonModificationStack2D, 
	'SkeletonModifier3D':SkeletonModifier3D, 'SkeletonProfile':SkeletonProfile, 'SkeletonProfileHumanoid':SkeletonProfileHumanoid, 'Skin':Skin, 'Sky':Sky, 
	'SliderJoint3D':SliderJoint3D, 'SoftBody3D':SoftBody3D, 'SphereMesh':SphereMesh, 'SphereOccluder3D':SphereOccluder3D, 'SphereShape3D':SphereShape3D, 
	'SpinBox':SpinBox, 'SplitContainer':SplitContainer, 'SpotLight3D':SpotLight3D, 'SpringArm3D':SpringArm3D, 'SpringBoneCollision3D':SpringBoneCollision3D, 
	'SpringBoneCollisionCapsule3D':SpringBoneCollisionCapsule3D, 'SpringBoneCollisionPlane3D':SpringBoneCollisionPlane3D, 'SpringBoneCollisionSphere3D':SpringBoneCollisionSphere3D, 'SpringBoneSimulator3D':SpringBoneSimulator3D, 'Sprite2D':Sprite2D, 
	'Sprite3D':Sprite3D, 'SpriteFrames':SpriteFrames, 'StandardMaterial3D':StandardMaterial3D, 'StaticBody2D':StaticBody2D, 'StaticBody3D':StaticBody3D, 
	'StatusIndicator':StatusIndicator, 'StreamPeerBuffer':StreamPeerBuffer, 'StreamPeerExtension':StreamPeerExtension, 'StreamPeerGZIP':StreamPeerGZIP, 'StreamPeerTCP':StreamPeerTCP, 
	'StreamPeerTLS':StreamPeerTLS, 'StyleBox':StyleBox, 'StyleBoxEmpty':StyleBoxEmpty, 'StyleBoxFlat':StyleBoxFlat, 'StyleBoxLine':StyleBoxLine, 
	'StyleBoxTexture':StyleBoxTexture, 'SubViewport':SubViewport, 'SubViewportContainer':SubViewportContainer, 'SubtweenTweener':SubtweenTweener, 'SurfaceTool':SurfaceTool, 
	'SyntaxHighlighter':SyntaxHighlighter, 'SystemFont':SystemFont, 'TCPServer':TCPServer, 'TabBar':TabBar, 'TabContainer':TabContainer, 
	'TextEdit':TextEdit, 'TextLine':TextLine, 'TextMesh':TextMesh, 'TextParagraph':TextParagraph, 'TextServerAdvanced':TextServerAdvanced, 
	'TextServerDummy':TextServerDummy, 'TextServerExtension':TextServerExtension, 'TextServerManager':TextServerManager, 'Texture':Texture, 'Texture2D':Texture2D, 
	'Texture2DArray':Texture2DArray, 'Texture2DArrayRD':Texture2DArrayRD, 'Texture2DRD':Texture2DRD, 'Texture3D':Texture3D, 'Texture3DRD':Texture3DRD, 
	'TextureButton':TextureButton, 'TextureCubemapArrayRD':TextureCubemapArrayRD, 'TextureCubemapRD':TextureCubemapRD, 'TextureLayered':TextureLayered, 'TextureProgressBar':TextureProgressBar, 
	'TextureRect':TextureRect, 'Theme':Theme, 'ThemeDB':ThemeDB, 'Thread':Thread, 'TileData':TileData, 
	'TileMap':TileMap, 'TileMapLayer':TileMapLayer, 'TileMapPattern':TileMapPattern, 'TileSet':TileSet, 'TileSetAtlasSource':TileSetAtlasSource, 
	'TileSetScenesCollectionSource':TileSetScenesCollectionSource, 'Time':Time, 'Timer':Timer, 'TorusMesh':TorusMesh, 'TouchScreenButton':TouchScreenButton, 
	'Translation':Translation, 'TranslationDomain':TranslationDomain, 'TranslationServer':TranslationServer, 'Tree':Tree, 'TriangleMesh':TriangleMesh, 
	'TubeTrailMesh':TubeTrailMesh, 'Tween':Tween, 'UDPServer':UDPServer, 'UPNP':UPNP, 'UPNPDevice':UPNPDevice, 
	'UndoRedo':UndoRedo, 'UniformSetCacheRD':UniformSetCacheRD, 'VBoxContainer':VBoxContainer, 'VFlowContainer':VFlowContainer, 'VScrollBar':VScrollBar, 
	'VSeparator':VSeparator, 'VSlider':VSlider, 'VSplitContainer':VSplitContainer, 'VehicleBody3D':VehicleBody3D, 'VehicleWheel3D':VehicleWheel3D, 
	'VideoStream':VideoStream, 'VideoStreamPlayback':VideoStreamPlayback, 'VideoStreamPlayer':VideoStreamPlayer, 'VideoStreamTheora':VideoStreamTheora, 'ViewportTexture':ViewportTexture, 
	'VisibleOnScreenEnabler2D':VisibleOnScreenEnabler2D, 'VisibleOnScreenEnabler3D':VisibleOnScreenEnabler3D, 'VisibleOnScreenNotifier2D':VisibleOnScreenNotifier2D, 'VisibleOnScreenNotifier3D':VisibleOnScreenNotifier3D, 'VisualInstance3D':VisualInstance3D, 
	'VisualShader':VisualShader, 'VoxelGI':VoxelGI, 'VoxelGIData':VoxelGIData, 'WeakRef':WeakRef, 'WebRTCDataChannelExtension':WebRTCDataChannelExtension, 
	'WebRTCMultiplayerPeer':WebRTCMultiplayerPeer, 'WebRTCPeerConnection':WebRTCPeerConnection, 'WebRTCPeerConnectionExtension':WebRTCPeerConnectionExtension, 'WebSocketMultiplayerPeer':WebSocketMultiplayerPeer, 'WebSocketPeer':WebSocketPeer, 
	'Window':Window, 'World2D':World2D, 'World3D':World3D, 'WorldBoundaryShape2D':WorldBoundaryShape2D, 'WorldBoundaryShape3D':WorldBoundaryShape3D, 
	'WorldEnvironment':WorldEnvironment, 'X509Certificate':X509Certificate, 'XMLParser':XMLParser, 'ZIPPacker':ZIPPacker, 'ZIPReader':ZIPReader, 
}


## Listens for errors.
static var error_server := A2JErrorServer.new()

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
		for tr in translations:
			if tr is not String && tr is not StringName: continue
			message = message.replace('~~', tr)
		printerr(a2jError_+message)

	# Emit error.
	error_server.core_error.emit(error, message)


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
	# If type is primitive, return value unchanged (except when rules apply).
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
	if result is Dictionary:
		result = A2JUtil.type_dictionary(result, type_details)
	# Type array.
	elif result is Array:
		result = A2JUtil.type_array(result, type_details)
	# Type other.
	elif type_details.get('type') is int:
		result = type_convert(result, type_details.get('type'))
	# Return result.
	return result




## Returns whether or not the [param type] is excluded in the [param ruleset].
static func _type_excluded(type:String, ruleset:Dictionary) -> bool:
	# Get type exclusions & inclusions.
	var type_exclusions = ruleset.get('type_exclusions', [])
	var type_inclusions = ruleset.get('type_inclusions', [])
	# Return whether or not the type is excluded.
	if type_exclusions is Array && type_inclusions is Array:
		return type in type_exclusions or (type_inclusions.size() > 0 && type not in type_inclusions)

	# Throw error if is not an array.
	report_error(1)
	return true


## Returns whether or not the [param object_class] is excluded in the [param ruleset].
static func _class_excluded(object_class:String, ruleset:Dictionary) -> bool:
	# Get class exclusions & inclusions.
	var class_exclusions = ruleset.get('class_exclusions', [])
	var class_inclusions = ruleset.get('class_inclusions', [])
	# Return whether or not class is excluded.
	if class_exclusions is Array && class_inclusions is Array:
		return object_class in class_exclusions or (class_inclusions.size() > 0 && object_class not in class_inclusions)

	# Throw error if is not an array.
	report_error(2)
	return true


## Initialize data for all registered [code]type_handlers[/code], into the [code]_process_data[/code] variable.
static func _init_handler_data() -> void:
	for key:String in type_handlers:
		var handler:A2JTypeHandler = type_handlers[key]
		_process_data.merge(handler.init_data.duplicate(true), true)


## Calls all functions in [code]_process_next_pass_functions[/code] with the given [param value], [param result], & [param ruleset] (in that order).
## [param result] is changed to the return value of the last next pass function & [param result] is returned after all functions have been called.
static func _call_next_pass_functions(value, result, ruleset:Dictionary) -> Variant:
	for callable:Callable in _process_next_pass_functions:
		result = callable.call(value, result, ruleset)
	return result
