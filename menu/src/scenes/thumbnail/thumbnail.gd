extends Control
@onready var panel_container: PanelContainer = $PanelContainer

var content: RefCounted: 
	set(v):
		content = v
		# checks if the value is valid AND if we're already readied
		if not is_instance_valid(v):
			return
		
		if v is not GameData and v is not EventData:
			push_error("Thumbnail content should be game or event data ! (found ", v, ")")
			return
		
		$PanelContainer/ThumbNail.texture = v.thumbnail
