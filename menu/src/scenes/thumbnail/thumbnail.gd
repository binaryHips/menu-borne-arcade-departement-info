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
