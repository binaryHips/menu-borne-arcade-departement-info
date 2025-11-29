extends HBoxContainer

@export var element_width: float = 450.0
@export var separation: int = 16
@export var transition_time: float = 0.3

var original_element_count: int
var currently_selected: Control
var min_element_count: int = 7 # we have to fill the screen for the effect to work

var active: bool = false

func _ready() -> void:
	add_theme_constant_override("separation", separation)
	
	original_element_count = get_child_count()
	while get_child_count() < min_element_count:
		for n in get_children():
			add_child(n.duplicate())
	
	position.x = - 0.5 * (get_child_count() * (separation + element_width)) - 0.5 * (element_width)
	position += size * 0.5
	
	currently_selected = get_child( get_child_count() / 2)

var tween:Tween
func _process(delta: float) -> void:
	if not active: return
	
	if Input.is_action_pressed("joy_left"):
		previous()
	elif Input.is_action_pressed("joy_right"):
		next()
	if currently_selected:
		print(currently_selected.get_node("PanelContainer/Fade/NameText").text)
	
func previous():
	if tween && tween.is_running():
		return;
	tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"position:x",
		position.x + (element_width + separation),
		transition_time
	).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(
		func ():
			position.x -= (element_width + separation)
			move_child(get_child(-1), 0)
			currently_selected = get_child( get_child_count() / 2)
	)

func next():
	if tween && tween.is_running():
		return;
	tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"position:x",
		position.x - (element_width + separation),
		transition_time
	).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(
		func ():
			position.x += (element_width + separation)
			move_child(get_child(0), -1)
			currently_selected = get_child( get_child_count() / 2)
	)
