@tool
extends Node

@export_tool_button('Generate') var button = callback
@export_file_path('*.txt') var output_path:String = 'res://registry_generator/OUT.txt'
@export var items_per_line:int = 1
## GDBuild file to use for deciding which classes to include in the generated registry.
## You can make a GDBuild by navigating to [code]Project -> Tools -> Engine Compilation Configuration Editor[/code] & selecting the classes you want.
## [br][br]
## NOTE: Only some features will be recognized when turned off. Here is the list:
## [br] - XR
## [br] - OpenXR
## [br] - Navigation2D
## [br] - Navigation3D
@export_file('*.gdbuild') var engine_compilation_configuration:String = ''
## Feature grouped classes to exclude in the generated registry.
@export_flags('Editor:1') var more_disabled_features:int = 0
## Classes to exclude in the generated registry.
@export var more_disabled_classes:Array[String] = []

const EDITOR_FEATURE_FLAG:int = 1


func callback() -> void:
	var disabled_features:Array[String] = []
	var disabled_classes:Array[String] = []

	# Open ECC file.
	var ecc_file := FileAccess.open(engine_compilation_configuration, FileAccess.READ)
	if ecc_file != null:
		var ecc = JSON.parse_string(ecc_file.get_as_text())
		assert(ecc is Dictionary, 'ECC file JSON could not be parsed.')
		ecc = ecc as Dictionary

		# Extract disabled features & classes.
		var _dbo = ecc.get('disabled_build_options')
		var _disabled_classes = ecc.get('disabled_classes')
		if _dbo is Dictionary:
			if _dbo.get('disable_xr') == true: disabled_features.append_array(['xr','openxr']) 
			elif _dbo.get('disable_openxr') == true: disabled_features.append('openxr')
			if _dbo.get('disable_navigation_2d') == true: disabled_features.append('nav2d')
			if _dbo.get('disable_navigation_3d') == true: disabled_features.append('nav3d')
		if _disabled_classes is Array:
			for item in _disabled_classes:
				if item is not String: continue
				disabled_classes.append(item)
				# Disable all inheriters of this class too.
				for child:String in ClassDB.get_inheriters_from_class(item):
					disabled_classes.append(child)

	# Generate registry.
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	var result := PackedStringArray()
	var count:int = 0
	for item:String in ClassDB.get_class_list():
		if not ClassDB.can_instantiate(item): continue
		if item in disabled_classes: continue
		if 'xr' in disabled_features && item.begins_with('XR'): continue
		if 'openxr' in disabled_features && item.begins_with('OpenXR'): continue
		if 'nav2d' in disabled_features && 'nav3d' in disabled_features && item.begins_with('Navigation'): continue
		else:
			if 'nav2d' in disabled_features && item.begins_with('Navigation') && item.ends_with('2D'): continue
			if 'nav3d' in disabled_features && item.begins_with('Navigation') && item.ends_with('3D'): continue
		if item in more_disabled_classes: continue
		if more_disabled_features & EDITOR_FEATURE_FLAG && item.begins_with('Editor'): continue
		count += 1
		result.append("'%s':%s, " % [item,item])
		if count == items_per_line:
			count = 0
			result.append('\n')

	# Store in output file.
	file.store_string('{\n' + ''.join(result).indent('	') + '\n}')
	file.close()
