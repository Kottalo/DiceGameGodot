extends Control

class_name Dice

@onready var Main = get_node("/root/Main")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if !Main.controllable or !selectable: return
			
			if Main.selectedDice != null: Main.selectedDice.selected = false
			Main.selectedDice = self if Main.selectedDice != self else null
	pass # Replace with function body.

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
		
		$Sprite2D.frame = diceValue - 1
	
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


func _on_resized():
	var spriteSize = $Sprite2D.get_rect().size
	
	var offset = size / 2
	
	var scaleX = size.x / spriteSize.x
	var scaleY = size.y / spriteSize.y
	
	$Sprite2D.scale = Vector2(scaleX, scaleY)
	$Sprite2D.position = offset
	
	print($Sprite2D.scale)
	pass # Replace with function body.
