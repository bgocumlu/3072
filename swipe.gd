extends Camera2D

var length = 100
var startPos: Vector2
var curPos: Vector2
var swiping = false

# Minimum swipe distance to consider it a valid swipe
var threshold = 10

@onready var swipe_area_reference = $"../../SwipeArea"
# Define the swipe detection area as a Rect2 (position and size)
var swipe_area: Rect2

signal swipe_detected(direction: String)

func _ready():
	print(swipe_area_reference.get_rect())
	swipe_area = swipe_area_reference.get_rect()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		var mouse_pos = get_global_mouse_position()
		if !swiping and swipe_area.has_point(mouse_pos):
			swiping = true
			startPos = mouse_pos
			
	if Input.is_action_pressed("left_click"):
		if swiping:
			curPos = get_global_mouse_position()
			if startPos.distance_to(curPos) >= length:
				var swipe_vector = curPos - startPos
				if abs(swipe_vector.x) > abs(swipe_vector.y):
					# Horizontal swipe
					if swipe_vector.x > threshold:
						emit_signal("swipe_detected", "right")
					elif swipe_vector.x < -threshold:
						emit_signal("swipe_detected", "left")
				else:
					# Vertical swipe
					if swipe_vector.y > threshold:
						emit_signal("swipe_detected", "down")
					elif swipe_vector.y < -threshold:
						emit_signal("swipe_detected", "up")
				swiping = false
	else:
		swiping = false
