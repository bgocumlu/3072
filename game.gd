extends Node2D

const Tile = preload("res://tile.tscn")

enum dir { LEFT, RIGHT, UP, DOWN }

var tiles = []
@export var move_speed = 2000

var target_size = Vector2(50, 50)
var current_size = Vector2(10, 10)
var scale_speed = 10

var tiles_moving = false
var update = false
var spawn_tile = false

var score = 0
var best_score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.max_fps = 144
	reset()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for t in tiles:
		var pos = get_pos(t, t.grid_pos)
		if pos != t.position:
			tiles_moving = true
			var direction = (pos - t.position).normalized()
			var distance = t.position.distance_to(pos)
			var movement = move_speed * delta
			if distance > movement:
				t.position += direction * movement
			else:
				t.position = pos
				tiles_moving = false
				
	if update and !tiles_moving:
		var i = 0
		while i < tiles.size():
			tiles[i].update()
			if tiles[i].dead:
				remove_child(tiles[i])
				tiles.pop_at(i)
			else:
				i += 1
		update = false
		
		if spawn_tile:
			var new_tile = generate_tile()
			tiles.append(new_tile)
			add_child(new_tile)
			spawn_tile = false
			print("tile generated! ", tiles.back().grid_pos)

func _input(event):
	var moved = false
	var merged = false
	if event.is_action_pressed("swipe_left"):
		if spawn_tile:
			cancel_animation()
		moved = move_tiles(dir.LEFT)
		merged = merge_tiles(dir.LEFT)
		move_tiles(dir.LEFT)
	elif event.is_action_pressed("swipe_right"):
		if spawn_tile:
			cancel_animation()
		moved = move_tiles(dir.RIGHT)
		merged = merge_tiles(dir.RIGHT)
		move_tiles(dir.RIGHT)
	elif event.is_action_pressed("swipe_up"):
		if spawn_tile:
			cancel_animation()
		moved = move_tiles(dir.UP)
		merged = merge_tiles(dir.UP)
		move_tiles(dir.UP)
	elif event.is_action_pressed("swipe_down"):
		if spawn_tile:
			cancel_animation()
		moved = move_tiles(dir.DOWN)
		merged = merge_tiles(dir.DOWN)
		move_tiles(dir.DOWN)
	elif event.is_action_pressed("my_action"):
		var line_to_print = ""
		for i in tiles:
			line_to_print += str(i.grid_pos % 4)
			line_to_print += " "
		print(line_to_print)
	elif event.is_action_pressed("reset_game"):
		reset()
	elif event.is_action_pressed("exit_game"):
		#get_tree().quit()
		pass
	if moved or merged:
		spawn_tile = true
	update = true

func compare_columns_asc(a, b):
	var cola = a.grid_pos % 4
	var colb = b.grid_pos % 4
	return cola < colb
	
func compare_columns_des(a, b):
	var cola = a.grid_pos % 4
	var colb = b.grid_pos % 4
	return cola > colb

func compare_rows_asc(a, b):
	var rowa = a.grid_pos / 4
	var rowb = b.grid_pos / 4
	return rowa < rowb
	
func compare_rows_des(a, b):
	var rowa = a.grid_pos / 4
	var rowb = b.grid_pos / 4
	return rowa > rowb

func get_pos(tile: Control, index: int, cols: int = 4):
	var row = index / cols
	var col = index % cols
	
	var pos0 = $GridContainer.position
	pos0.x += tile.get_node("border").size.x * col
	pos0.x -= ((tile.get_node("border").size.x - tile.get_node("inside").size.x) / 2) * col
	pos0.y += tile.get_node("border").size.y * row
	pos0.y -= ((tile.get_node("border").size.y - tile.get_node("inside").size.y) / 2) * row
	return pos0

func generate_pos():
	var index = 0
	var unique = false
	while !unique:
		index = randi_range(0, 15)
			
		unique = true
		for t in tiles:
			if index == t.grid_pos:
				unique = false
			
	return index

func generate_tile():
	var t = Tile.instantiate()
	var index = generate_pos()
	t.position = get_pos(t, index)
	t.set_grid_pos(index)
	if randf() < 0.1:
		t.set_value(6)
	else:
		t.set_value(3)
	return t

func find_tile(pos: int):
	for t in tiles:
		if t.grid_pos == pos:
			return t
	return null

func reset():
	for t in tiles:
		remove_child(t)
	tiles.clear()
	
	spawn_tile = 0
	
	if score > best_score:
		best_score = score
		$BestScore/Score.text = str(best_score)
		
	score = 0
	$Score/Score.text = str(score)
	
	for i in 2:
		var new_tile = generate_tile()
		tiles.append(new_tile)
	for t in tiles:
		add_child(t)

func cancel_animation():
	for t in tiles:
		var pos = get_pos(t, t.grid_pos)
		if pos != t.position:
			t.position = pos
			tiles_moving = false
				
	if update and !tiles_moving:
		var i = 0
		while i < tiles.size():
			tiles[i].update()
			if tiles[i].dead:
				remove_child(tiles[i])
				tiles.pop_at(i)
			else:
				i += 1
		update = false
		
		if spawn_tile:
			var new_tile = generate_tile()
			tiles.append(new_tile)
			add_child(new_tile)
			spawn_tile = false
			print("tile generated! ", tiles.back().grid_pos)

func move_tile(direction: dir, cols = 4):
	var row = 0
	var col = 0
	var moved = false
	var next_tile = -1
	
	for t in tiles:
		row = t.grid_pos / cols
		col = t.grid_pos % cols
		
		match direction:
			dir.LEFT:
				if col != 0:
					next_tile = row * cols + (col - 1)
				else:
					continue
					
			dir.RIGHT:
				if col != cols - 1:
					next_tile = row * cols + (col + 1)
				else:
					continue
			dir.UP:
				if row != 0:
					next_tile = (row - 1) * cols + col
				else:
					continue
			dir.DOWN:
				if row != cols - 1:
					next_tile = (row + 1) * cols + col
				else:
					continue
		var can_move = true
		for n in tiles:
			if n == t:
				continue
			if n.grid_pos == next_tile and !n.dead:
				can_move = false
		if can_move:
			t.grid_pos = next_tile
			moved = true
	return moved

func move_tiles(direction: dir, cols = 4):
	var moved = false
	while true:
		var cont = false
		for t in tiles:
			if move_tile(direction, cols):
				cont = true
		if not cont:
			break
		moved = true
	return moved

func merge_tiles(direction: dir, cols = 4):
	var row = 0
	var col = 0
	var next_tile = -1
	var merged = false
	match direction:
		dir.LEFT:
			tiles.sort_custom(compare_columns_asc)
		dir.RIGHT:
			tiles.sort_custom(compare_columns_des)
		dir.UP:
			tiles.sort_custom(compare_rows_asc)
		dir.DOWN:
			tiles.sort_custom(compare_rows_des)
	for t in tiles:
		row = t.grid_pos / cols
		col = t.grid_pos % cols
		match direction:
			dir.LEFT:
				if col != 0:
					next_tile = row * cols + (col - 1)
				else:
					continue
			dir.RIGHT:
				if col != cols - 1:
					next_tile = row * cols + (col + 1)
				else:
					continue
			dir.UP:
				if row != 0:
					next_tile = (row - 1) * cols + col
				else:
					continue
			dir.DOWN:
				if row != cols - 1:
					next_tile = (row + 1) * cols + col
				else:
					continue
		var to_merge = find_tile(next_tile)
		if to_merge:
			if t.value == to_merge.value:
				t.set_value(t.value * 2)
				score += t.value
				$Score/Score.text = str(score)
				t.grid_pos = next_tile
				to_merge.dead = true
				t.z_index = 100
				merged = true
	return merged

func _on_button_pressed():
	reset()
	
func _on_camera_2d_swipe_detected(direction):
	print("swpie ", direction)
	var moved = false
	var merged = false
	match direction:
		"left":
			moved = move_tiles(dir.LEFT)
			merged = merge_tiles(dir.LEFT)
			move_tiles(dir.LEFT)
		"right":
			moved = move_tiles(dir.RIGHT)
			merged = merge_tiles(dir.RIGHT)
			move_tiles(dir.RIGHT)
		"up":
			moved = move_tiles(dir.UP)
			merged = merge_tiles(dir.UP)
			move_tiles(dir.UP)
		"down":
			moved = move_tiles(dir.DOWN)
			merged = merge_tiles(dir.DOWN)
			move_tiles(dir.DOWN)
	if moved or merged:
		spawn_tile = true
	update = true
