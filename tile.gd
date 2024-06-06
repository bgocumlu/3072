extends Control

@onready var value_label = $value
@onready var inside = $inside
@onready var border = $border

@export var value: int = 0
var grid_pos = 0
var dead = false

const BORDER_SIZE = Vector2(112, 112)
const INSIDE_SIZE = Vector2(99, 99)
const FONT_SIZE = Vector2(36, 36)

const colors = [
	Color("#111b25"), Color("#121f37"), Color("#0d4e86"), 
	Color("#0a6a9c"), Color("#0983a0"), Color("#09a1c4"),
	Color("#12308d"), Color("#12339e"), Color("#1237af"),
	Color("#123ac0"), Color("#123dd1"), Color("#c1c6cc"),
]

# Called when the node enters the scene tree for the first time.
func _ready():
	update()
	
func update():
	if value == 0:
		value_label.text = ""
		inside.color = Color("#333f4c")
		return
		
	value = abs(value)
	value_label.text = str(value)
	
	var to_log = value / 3
	inside.color = colors[int(log(to_log) / log(2))]
			
	border.hide()

func set_value(val: int):
	value = val
	
func set_grid_pos(val: int):
	grid_pos = val
