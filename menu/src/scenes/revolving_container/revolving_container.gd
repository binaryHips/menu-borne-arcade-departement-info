extends HBoxContainer

@export var element_width: float = 450.0
@export var separation: int = 16
@export var transition_time: float = 0.3

var original_element_count: int
var currently_selected: Control
var min_element_count: int = 10 # we have to fill the screen for the effect to work

signal selected_changed(new_selected: Control)

@export var active: bool = false

@onready var center: float = get_viewport().get_visible_rect().size.x / 2 - (element_width) / 2
func _ready() -> void:
	add_theme_constant_override("separation", separation)
	setup_revolving()

## expected to be called after clearing and setting all the children in order to create the repetitions
func setup_revolving():
	if get_child_count() == 0:
		return
	
	original_element_count = get_child_count()
	var original_elements := get_children()
	
	while get_child_count() < min_element_count:
		for n in original_elements:
			var new: Control = n.duplicate()
			new.content = n.content
			add_child(new)
			
	position.x = - 0.5 * (get_child_count() * (separation + element_width)) + separation * 0.5
	
	# have to offset depending on evenness
	if get_child_count() % 2 == 1:
		position.x += 0.5 * (separation + element_width)
	position.x += center
	
	print("number of children : ", get_child_count())
	@warning_ignore("integer_division")
	currently_selected = get_child( get_child_count() / 2)

var tween:Tween
func _process(_delta: float) -> void:
	# reduce the thumbnail the farther away it's to the center. Looks good in revolving container
	#could be done with tweens but this aint so bad
	for node in get_children():
		var dst_to_center: float = abs(node.global_position.x - center )
		var scale_factor = lerpf(1.0, 0.6, clampf(dst_to_center, 0.0, 1000.0)/1000.0)
		node.panel_container.scale = Vector2(scale_factor, scale_factor)
	
	if not active or get_child_count() == 0: return
	
	if Input.is_action_pressed("joy_left"):
		previous()
	elif Input.is_action_pressed("joy_right"):
		next()

func previous():
	if tween && tween.is_running():
		return
	
	@warning_ignore("integer_division")
	currently_selected = get_child( get_child_count() / 2 - 1)
	
	selected_changed.emit(currently_selected)
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
	)

func next():
	if tween && tween.is_running():
		return
		
	@warning_ignore("integer_division")
	currently_selected = get_child( posmod(get_child_count() / 2 + 1 , get_child_count()))
	selected_changed.emit(currently_selected)
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
	)
