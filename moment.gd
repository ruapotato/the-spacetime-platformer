extends Sprite3D
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
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.z = space_time.player_time_index
