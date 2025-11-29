extends Node


const EVENT_CONFIG_FILE: String = "event.cfg"
const GAME_CONFIG_FILE: String = "game.cfg"

const GAME_DEFAULT_PRIMARY_COLOR: String = "#f03f52"
const GAME_DEFAULT_SECONDARY_COLOR: String = "#84b7d3"

var events: Array[EventData]


func get_event_count() -> int:
	return events.size()


func get_event(p_index: int) -> EventData:
	return events[p_index]


func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("No event folder provided")
		return
	var event_file: String = args[0]
	import_folder(event_file)


func import_folder(p_folder_path: String) -> void:
	var folder := DirAccess.open(p_folder_path)
	if not folder:
		push_error("Could not open folder: ", p_folder_path, " ; error: ", error_string(DirAccess.get_open_error()))
		return
	
	for event_path: String in folder.get_directories():
		import_event(p_folder_path.path_join(event_path))


func import_event(p_event_path: String) -> void:
	var event_dir := DirAccess.open(p_event_path)
	if not event_dir:
		push_error("Could not open folder: ", p_event_path, " ; error: ", error_string(DirAccess.get_open_error()))
		return
	
	# Read event config
	if not event_dir.file_exists(EVENT_CONFIG_FILE):
		push_error("Event at ", p_event_path, " is missing the ", EVENT_CONFIG_FILE, " file.")
		return
	
	var event_index: int = events.size()
	
	var event := EventData.new()
	event.directory_path = p_event_path
	
	var config_path: String = p_event_path.path_join(EVENT_CONFIG_FILE)
	var config := ConfigFile.new()
	
	if config.load(config_path) != OK:
		push_error("Could not open event file ", config_path)
		return
	if not config.has_section("event"):
		push_error("Event config file ", config_path, " does not have an event section")
		return
	
	if not config.has_section_key("event", "name"):
		push_error("Event file ", config_path, " missing a `name` property")
		return
	if not config.has_section_key("event", "thumbnail"):
		push_error("Event file ", config_path, " missing a `thumbnail` property")
		return
	if not config.has_section_key("event", "description"):
		push_error("Event file ", config_path, " missing a `description` property")
		return
	if not config.has_section_key("event", "date"):
		push_error("Event file ", config_path, " missing a `date` property")
		return
	
	event.name = config.get_value("event", "name")
	event.thumbnail = ImageTexture.create_from_image(Image.load_from_file(
		p_event_path.path_join(config.get_value("event", "thumbnail"))
	))
	event.description = config.get_value("event", "description")
	event.time_information = config.get_value("event", "date")
	
	events.push_back(event)
	
	# Add games into the event
	for game_path: String in event_dir.get_directories():
		import_game(event_index, p_event_path.path_join(game_path))


func import_game(p_event_index: int, p_game_path: String) -> void:
	var game_dir := DirAccess.open(p_game_path)
	if not game_dir:
		push_error("Could not open folder: ", p_game_path, " ; error:", error_string(DirAccess.get_open_error()))
		return
	
	if not game_dir.file_exists(GAME_CONFIG_FILE):
		push_error("Game at ", p_game_path, " is missing the ", GAME_CONFIG_FILE, " file.")
		return
	
	var game := GameData.new()
	
	var config_path: String = p_game_path.path_join(GAME_CONFIG_FILE)
	var config := ConfigFile.new()
	
	if config.load(config_path) != OK:
		push_error("Could not open event file ", config_path)
		return
	if not config.has_section("game"):
		push_error("Game config file ", config_path, " does not have an event section")
		return
	
	if not config.has_section_key("game", "executable"):
		push_error("Game file ", config_path, " missing a `executable` property")
		return
	if not config.has_section_key("game", "name"):
		push_error("Game file ", config_path, " missing a `name` property")
		return
	if not config.has_section_key("game", "description"):
		push_error("Game file ", config_path, " missing a `description` property")
		return
	if not config.has_section_key("game", "credits"):
		push_error("Game file ", config_path, " missing a `credits` property")
		return
	
	game.executable_path = p_game_path.path_join(config.get_value("game", "executable"))
	if not FileAccess.file_exists(game.executable_path):
		push_error("Game executable ", game.executable_path, " does not exist")
		return
	
	game.name = config.get_value("game", "name")
	game.thumbnail = ImageTexture.create_from_image(Image.load_from_file(
		p_game_path.path_join(config.get_value("game", "thumbnail"))
	))
	game.description = config.get_value("game", "description")
	game.credits = config.get_value("game", "credits")
	
	game.primary_color = Color.html(
		config.get_value("game", "primary_color", GAME_DEFAULT_PRIMARY_COLOR)
	)
	game.secondary_color = Color.html(
		config.get_value("game", "secondary_color", GAME_DEFAULT_SECONDARY_COLOR)
	)
	game.should_show_name = config.get_value("game", "should_show_name", true)
	
	var event: EventData = events[p_event_index]
	event.games.push_back(game)
