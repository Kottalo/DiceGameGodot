extends Sprite2D

class_name Dice

@onready var Main = get_node("/root/Main")
var colliding_container
var container

# Called when the node enters the scene tree for the first time.
func _ready():
	var rectangleShape = $Area2D/CollisionShape2D.shape as RectangleShape2D
	
	rectangleShape.size = get_rect().size
	
	  # Set the width to 100 and height to 50
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		position = get_viewport().get_mouse_position()
	
	pass

#func _on_control_gui_input(event):
	#if event is InputEventMouseButton:
		#if event.pressed:
			#if !Main.controllable or !selectable: return
			#
			#if Main.selectedDice != null: Main.selectedDice.selected = false
			#Main.selectedDice = self if Main.selectedDice != self else null
			#
		#if event.is_released():
			#print("Released")
	#pass # Replace with function body.

var selectable: bool = true:
	set(newValue):
		selectable = newValue
		
		if selectable == false:
			selected = selectable
	get:
		return selectable

var selected: bool:
	set(newValue):
		selected = newValue
		
		$Line2D.visible = selected
	get:
		return selected

var diceValue: int:
	set(newValue):
		diceValue = newValue
		
		frame = diceValue - 1
	
	get:
		return diceValue

var diceTypeData: DiceTypeData:
	set(newValue):
		diceTypeData = newValue
	
		self_modulate = diceTypeData.color
	get:
		return diceTypeData

func Roll():
	diceValue = randf_range(1, 7)


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		if !Main.controllable or !selectable: return
		
		if Main.selectedDice != null: Main.selectedDice.selected = false
		Main.selectedDice = self if Main.selectedDice != self else null
		
		if Main.targetContainer != null:
			Main.targetContainer.JoinDice(self)
		else:
			Main.diceLobbyDiceContainer.JoinDice(self)
	
	#if event.is_action_released("click"):
		#print("Released")
	
	pass # Replace with function body.
