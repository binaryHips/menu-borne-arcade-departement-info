extends Control
@onready var thumb_nail: TextureRect = $PanelContainer/ThumbNail
@onready var name_text: RichTextLabel = $PanelContainer/Fade/NameText
@onready var panel_container: PanelContainer = $PanelContainer

var content:
	set(v):
		if v is not GameData and v is not EventData:
			push_error("Thumbnail content should be game or event data ! (found ", v, ")")
			return
			
		content = v
		thumb_nail.texture = v.thumbnail
		
		if v.should_show_name:
				name_text.text = v.name

@onready var center: float = get_viewport().get_visible_rect().size.x / 2 - size.x / 2
func _process(delta: float) -> void:
	print(center)
	# reduce the thumbnail the farther away it's to the center. Looks good in revolving container
	#could be done with tweens but this aint so bad
	var dst_to_center: float = abs(global_position.x - center )
	var scale_factor = lerpf(1.0, 0.6, clampf(dst_to_center, 0.0, 1000.0)/1000.0)
	panel_container.scale = Vector2(scale_factor, scale_factor)
