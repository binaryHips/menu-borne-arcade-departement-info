extends Control
@onready var thumb_nail: TextureRect = $PanelContainer/ThumbNail

var content:
	set(v):
		if v is not GameData and v is not EventData:
			push_error("Thumbnail content should be game or event data ! (found ", v, ")")
			return
			
		content = v
		thumb_nail.texture = v.thumbnail
		
		if v.should_show_name:
				pass
