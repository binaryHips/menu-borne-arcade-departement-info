extends RefCounted
class_name GameData


var executable_path: String
var thumbnail: ImageTexture
var name: StringName
var should_show_name: bool #if name already on thumbnail, no ned to show it ourselves
var description: String
var credits: String

var primary_color: Color
var secondary_color: Color
