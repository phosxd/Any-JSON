@tool
extends Node

@export var color_pallete: ColorPalette
@export var cone: CylinderMesh
@export_tool_button('Print "color_pallete" as AJSON') var print_color_pallete = print_color_pallete_callback
@export_tool_button('Print "cone" as AJSON') var print_cone = print_cone_callback


func print_color_pallete_callback() -> void:
	print_rich('[color=yellow][b]Converting exported [code]color_pallete[/code] variable to AJSON...')
	var result = A2J.to_json(color_pallete)
	print_rich('[b]Result:[/b] ', result)
	print_rich('[color=green][b]Converting result back to original object...')
	var result_back = A2J.from_json(result)
	result_back = result_back as ColorPalette
	print_rich(
		'[b]Result back:[/b]',
		'\n- colors: [code]%s' % result_back.colors,
	)


func print_cone_callback() -> void:
	print_rich('[color=yellow][b]Converting exported [code]cone[/code] variable to AJSON...')
	var result = A2J.to_json(cone)
	print_rich('[b]Result:[/b] ', result)
	print_rich('[color=green][b]Converting result back to original object...')
	var result_back = A2J.from_json(result)
	result_back = result_back as CylinderMesh
	print_rich(
		'[b]Result back:[/b]',
		'\n- top_radius: [code]%s' % result_back.top_radius,
		'\n- bottom_radius: [code]%s' % result_back.bottom_radius,
		'\n- height: [code]%s' % result_back.height,
		'\n- radial_segments: [code]%s' % result_back.radial_segments,
	)
