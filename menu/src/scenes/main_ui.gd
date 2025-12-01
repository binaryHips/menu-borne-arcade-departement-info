extends Control

var selecting_game := false


@onready var big_event: Control = $BigEvent
@onready var revolving_events: HBoxContainer = $RevolvingEvents
@onready var revolving_games: HBoxContainer = $RevolvingGames
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	return
	for e in GameLoader.events:
		var new_thumbnail: Control = preload("res://src/scenes/thumbnail/thumbnail.tscn").instantiate()
		new_thumbnail.content = e
		revolving_events.add_child(new_thumbnail)
	revolving_games.setup_revolving()
	
	# call this once to initialize the second menu with games
	_on_revolving_events_selected_changed(revolving_events.currently_selected)
## switches the selection to the games of the curent event
func enter_event() -> void:
	
	# singular event thumbnail that will stay at the top
	big_event.content = revolving_events.currently_selected.content
	animation_player.play("event_selected")
	
	selecting_game = true

func exit_event() -> void:
	selecting_game = false
	animation_player.play_backwards("event_selected")
	
@onready var event_title: RichTextLabel = $EventData/Control/Title
@onready var event_date: RichTextLabel = $EventData/Control/Date
@onready var event_description: RichTextLabel = $EventData/Control/Description
func _on_revolving_events_selected_changed(new_selected: Control) -> void:
	var data: EventData = new_selected.content
	
	event_title.text = data.name
	event_date.text = data.time_information
	event_description.text = data.description
	
	# update the games
	for n in revolving_games.get_children():
		n.queue_free()
	
	for game in data.games:
		var new_thumbnail: Control = preload("res://src/scenes/thumbnail/thumbnail.tscn").instantiate()
		new_thumbnail.content = game
		revolving_games.add_child(new_thumbnail)
	revolving_games.setup_revolving()
	

@onready var game_title: RichTextLabel = $GameData/Control/Title
@onready var game_description: RichTextLabel = $GameData/Control/Description
@onready var game_credits: RichTextLabel = $GameData/Control/Credits
func _on_revolving_games_selected_changed(new_selected: Control) -> void:
	var data: GameData = new_selected.content
	
	#game_title.text = data.name
	#game_credits.text = data.time_information
	#game_description.text = data.description

@onready var particles: CPUParticles2D = $Particles
@onready var background: TextureRect = $background

func set_colors(col_1:Color, col_2:Color, col_3:Color) -> void:
	var color:String = "[color=#" + (col_2 as Color).to_html() + "]"
	
	particles.texture.gradient.colors[1] = col_2 * 0.7
	particles.texture.gradient.colors[2] = col_2 * 1.2
	particles.texture.gradient.colors[3] = col_2 * 0.7

func is_accept_input(event: InputEvent) -> bool:
	return (
		event.is_action_pressed("joy_down") or
		event.is_action_pressed("insert_coin") or
		event.is_action_pressed("select") or 
		event.is_action_pressed("start")
	)
func _input(event: InputEvent) -> void:
	if not selecting_game && is_accept_input(event):
		enter_event()
	elif selecting_game && is_accept_input(event):
		pass # launch game
	elif selecting_game && event.is_action_pressed("joy_up"):
		exit_event()
