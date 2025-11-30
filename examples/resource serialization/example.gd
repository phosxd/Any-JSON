@tool
extends Node

@export var color_pallete: ColorPalette
@export var cone: CylinderMesh
@export_category('Print AJSON serialization')
@export_tool_button('Print this scene as AJSON') var print_scene = print_scene_callback
@export_tool_button('Print "color_pallete" as AJSON') var print_color_pallete = print_color_pallete_callback
@export_tool_button('Print "cone" as AJSON') var print_cone = print_cone_callback
@export_category('Encryption & saving')
@export var encryption_file_path:String = 'res://encrypted_ajson.dat'
@export var encryption_passkey:String = 'super secret key'
@export_tool_button('Encrypt & print last result') var test_encrypt = test_encrypt_callback
@export_tool_button('Decrypt & print file.') var test_decrypt = test_decrypt_callback

var last_result
## Using this as an example of how circular references are accounted for. The "self" value in this array should get printed as a reference in the scene example.
var something_with_a_self_ref = [1,2,3,self]


func print_scene_callback() -> void:
	print_rich('[color=yellow][b]Converting [code]%s[/code] scene to AJSON (excluding attached script & "last_result")...' % self.name)
	# Use ruleset to set the script property as a reference that we can apply a value to during serialiation back to a Node. Doing this because I don't want to print the whole script source code in this example.
	var ruleset := A2J.default_ruleset_to.duplicate(true)
	# Set "script" property as a reference.
	ruleset.property_references.set('Node', {'script':'script'})
	ruleset.set('references', {'script': self.get_script()})
	ruleset.property_exclusions.merge({'Node': ['last_result']}) # Exclude "last_result" property.
	# Serialize & print results.
	last_result = A2J.to_json(self, ruleset)
	print_rich('[b]Result:[/b] ', last_result)
	print_rich('[color=green][b]Converting result back to original object...')
	var result_back:Node = A2J.from_json(last_result, ruleset)
	print_rich(
		'[b]Result back:[/b]',
		'\n- full object: [code]%s[/code]' % result_back,
		'\n- color_pallete: [code]%s[/code]' % result_back.color_pallete,
		'\n- cone: [code]%s[/code]' % result_back.cone,
		'\n- something_with_a_self_ref: [code]%s[/code]' % str(result_back.something_with_a_self_ref),
	)


func print_color_pallete_callback() -> void:
	print_rich('[color=yellow][b]Converting exported [code]color_pallete[/code] variable to AJSON...')
	last_result = A2J.to_json(color_pallete)
	print_rich('[b]Result:[/b] ', last_result)
	print_rich('[color=green][b]Converting result back to original object...')
	var result_back = A2J.from_json(last_result)
	result_back = result_back as ColorPalette
	print_rich(
		'[b]Result back:[/b]',
		'\n- colors: [code]%s[/code]' % result_back.colors,
	)


func print_cone_callback() -> void:
	print_rich('[color=yellow][b]Converting exported [code]cone[/code] variable to AJSON...')
	last_result = A2J.to_json(cone)
	print_rich('[b]Result:[/b] ', last_result)
	print_rich('[color=green][b]Converting result back to original object...')
	var result_back = A2J.from_json(last_result)
	result_back = result_back as CylinderMesh
	print_rich(
		'[b]Result back:[/b]',
		'\n- top_radius: [code]%s[/code]' % result_back.top_radius,
		'\n- bottom_radius: [code]%s[/code]' % result_back.bottom_radius,
		'\n- height: [code]%s[/code]' % result_back.height,
		'\n- radial_segments: [code]%s[/code]' % result_back.radial_segments,
	)


func test_encrypt_callback() -> void:
	print_rich('[color=yellow][b]Encrypting & storing last result to [code]%s[/code] using passkey "%s"...' % [encryption_file_path, encryption_passkey])
	var file = FileAccess.open_encrypted_with_pass(encryption_file_path, FileAccess.WRITE, encryption_passkey)
	print(error_string(FileAccess.get_open_error()))
	file.resize(0)
	if file == null: return
	file.store_string(JSON.stringify(last_result))
	file.close()
	print_rich('[b]Output (printing as bytes, file is not UTF-8 compatible):[/b] %s' % FileAccess.get_file_as_bytes(encryption_file_path))


func test_decrypt_callback() -> void:
	print_rich('[color=yellow][b]Decrypting file at [code]%s[/code] using passkey "%s"...' % [encryption_file_path, encryption_passkey])
	var file = FileAccess.open_encrypted_with_pass(encryption_file_path, FileAccess.READ, encryption_passkey)
	if file == null: return
	print_rich('[b]Output:[/b] %s' % file.get_as_text())
	file.close()
