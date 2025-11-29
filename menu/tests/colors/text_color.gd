extends ColorRect


@onready var text: Label = $Label
@onready var text_settings: LabelSettings = text.label_settings


func _on_color_picker_color_changed(p_color: Color) -> void:
	color = p_color
	var color_vec := Vector3(
		color.ok_hsl_h,
		color.ok_hsl_s,
		color.ok_hsl_l,
	)
	
	var text_color := Vector3()
	text_color.x = fmod(0.5 + color_vec.x, 1.0)
	text_color.y = 0.8 - 0.5 * color_vec.y if color_vec.y > 0.02 else 0.0
	text_color.z = 0.15 if color_vec.z > 0.5 else 0.85
	
	text_settings.font_color = Color.from_ok_hsl(text_color.x, text_color.y, text_color.z)
