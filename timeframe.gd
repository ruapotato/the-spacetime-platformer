extends Node2D

@onready var player_image = $player_image
var space_time
var space
var level
var player
# Called when the node enters the scene tree for the first time.
func _ready():
	space_time = get_space_time()
	space = space_time.find_child("space")
	level = space.get_children()[0]
	player = space_time.find_child("player")

func get_space_time(test=self):
	var momma = test.get_parent()
	if momma.name == "space_time":
		return(momma)
	else:
		return(get_space_time(momma))
func update_player_image():
	player_image.global_position.x = player.global_position.x * space_time.x_scale
	player_image.global_position.y = -player.global_position.y * space_time.y_scale + 10
	#print(player_image.global_position)
	#print(player)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_player_image()
	
#	print(level.name)
