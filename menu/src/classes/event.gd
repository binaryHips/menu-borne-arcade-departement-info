extends RefCounted
class_name EventData

var directory_path: String
var thumbnail: ImageTexture
var name: StringName
var description: String
var time_information: String # Could be a date, or like "November 2025"

var games: Array[GameData]
