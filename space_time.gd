extends Node3D

@onready var coin = preload("res://coin.tscn")
@onready var space = $space
@onready var player = $player
var level
var z_time_index = 0.0
var space_speed = 4
var vt
var player_time_index = 0.0
var max_level_time = 150
var rendering = true
var x_scale = 10
var y_scale = 10
var render_range = 40


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	level = space.get_children()[0]


func set_time_to_player():
	z_time_index = float(int(-player_time_index * 4))/4.0

func add_coin(loc):
	#z_time_index = -player_time_index
	z_time_index = float(int(-player_time_index * 4))/4.0
	var new_coin = coin.instantiate()
	new_coin.birth_date = player_time_index
	level.add_child(new_coin)
	new_coin.global_position.x = player.global_position.x * x_scale
	new_coin.global_position.y = -player.global_position.y * y_scale
	#new_coin.global_position.z = int(player.global_position.z)

func get_time_pos():
	return(float(int(-z_time_index * 4))/4.0)


func _physics_process(delta):
	if rendering:
		z_time_index += delta * space_speed
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(Engine.get_frames_per_second())
	player_time_index = player.global_position.z
	if z_time_index + player_time_index > render_range:
		rendering = false
	else:
		rendering = true


