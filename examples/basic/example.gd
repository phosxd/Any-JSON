@tool
extends Node
@export var color_pallete: ColorPalette
@export var cone: CylinderMesh
@export var my_res: MyRes
@export_tool_button('Print this scene as AJSON') var print_scene = print_scene_callback
@export_tool_button('Print "color_pallete" as AJSON') var print_color_pallete = print_color_pallete_callback
@export_tool_button('Print "cone" as AJSON') var print_cone = print_cone_callback
@export_tool_button('Print "my_res" as AJSON') var print_my_res = print_my_res_callback

## Using this as an example of how circular references are accounted for. The "self" value in this array should get printed as a reference in the scene example.
var something_with_a_self_ref:Array = [1,2,3,self]


func _ready() -> void:
	A2J.object_registry.merge({
		'my_res': MyRes,
	})


func print_scene_callback() -> void:
	print_rich('[color=yellow][b]Converting [code]%s[/code] scene to AJSON (excluding attached script & "last_result")...' % self.name)
	# Use ruleset to set the script property as a reference that we can apply a value to during serialiation back to a Node. Doing this because I don't want to print the whole script source code in this example.
	var ruleset := A2J.default_ruleset_to.duplicate(true)
	# Set "script" property as a reference.
	ruleset.property_references.set('Node', {'script':'script'})
	ruleset.set('references', {'script': self.get_script()})
	# Serialize & print results.
	var result = A2J.to_json(self, ruleset)
	print_rich('[b]Result:[/b] ', result)
	print_rich('[color=green][b]Converting result back to original object...')
	var result_back:Node = A2J.from_json(result, ruleset)
	print_rich(
		'[b]Result back:[/b]',
		'\n- full object: [code]%s[/code]' % result_back,
		'\n- color_pallete: [code]%s[/code]' % result_back.color_pallete,
		'\n- cone: [code]%s[/code]' % result_back.cone,
		'\n- something_with_a_self_ref: [code]%s[/code]' % str(result_back.something_with_a_self_ref),
	)


func print_color_pallete_callback() -> void:
	print_rich('[color=yellow][b]Converting exported [code]color_pallete[/code] variable to AJSON...')
	var result = A2J.to_json(color_pallete)
	print_rich('[b]Result:[/b] ', result)
	print_rich('[color=green][b]Converting result back to original object...')
	var result_back := A2J.from_json(result) as ColorPalette
	print_rich(
		'[b]Result back:[/b]',
		'\n- colors: [code]%s[/code]' % result_back.colors,
	)


func print_cone_callback() -> void:
	print_rich('[color=yellow][b]Converting exported [code]cone[/code] variable to AJSON...')
	var result = A2J.to_json(cone)
	print_rich('[b]Result:[/b] ', result)
	print_rich('[color=green][b]Converting result back to original object...')
	var result_back := A2J.from_json(result) as CylinderMesh
	print_rich(
		'[b]Result back:[/b]',
		'\n- top_radius: [code]%s[/code]' % result_back.top_radius,
		'\n- bottom_radius: [code]%s[/code]' % result_back.bottom_radius,
		'\n- height: [code]%s[/code]' % result_back.height,
		'\n- radial_segments: [code]%s[/code]' % result_back.radial_segments,
	)


func print_my_res_callback() -> void:
	print_rich('[color=yellow][b]Converting exported [code]my_res[/code] variable to AJSON...')
	var result = A2J.to_json(my_res)
	print_rich('[b]Result:[/b] ', result)
	print_rich('[color=green][b]Converting result back to original object...')
	var result_back := A2J.from_json(result) as MyRes
	print_rich(
		'[b]Result back:[/b]',
		'\n', result_back,
	)
