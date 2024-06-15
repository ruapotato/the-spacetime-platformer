extends Area2D

@onready var sprite = $Sprite2D
@onready var body = $"."

var space_time
var voxels
var vt

var timeframe_sprite
var timeframe
var world_scale = 40
var personal_timeline = {}
var ttl = 100000
var last_time_index = 0
var birth_date = null
var found_date = null
var active_body = null
var space
var level
var spaces_to_remove = []
# Called when the node enters the scene tree for the first time.
func _ready():
	space_time =  get_space_time()
	space = space_time.find_child("space")
	level = space.get_children()[0]
	ttl = space_time.max_level_time
	active_body = StaticBody3D.new()
	var new_box_sin = MeshInstance3D.new()
	var new_box_shape = CollisionShape3D.new()
	new_box_sin.mesh = BoxMesh.new()
	new_box_shape.shape = BoxShape3D.new()
	
	
	new_box_sin.mesh.size.x = float(sprite.texture.width)/world_scale * 2
	new_box_sin.mesh.size.y = float(sprite.texture.height)/world_scale * 2
	new_box_sin.mesh.size.z = 1
	new_box_shape.shape.size.x = float(sprite.texture.width)/world_scale * 2
	new_box_shape.shape.size.y = float(sprite.texture.height)/world_scale * 2
	new_box_shape.shape.size.z = 1
	print(sprite.texture.height/world_scale)
	
	
	active_body.add_child(new_box_sin)
	active_body.add_child(new_box_shape)
	level.add_child.call_deferred(active_body)
	
	timeframe = space_time.find_child("timeframe")
	timeframe_sprite = sprite.duplicate()
	timeframe_sprite.script = null
	# Not sure why the scale is .5
	timeframe_sprite.scale = Vector2(.5,.5)
	timeframe.add_child.call_deferred(timeframe_sprite)
	#print(vt)


func get_space_time(test=self):
	var momma = test.get_parent()
	if momma.name == "space_time":
		return(momma)
	else:
		return(get_space_time(momma))

func draw_self():
	if birth_date < space_time.get_time_pos():
		return
	if found_date and found_date > space_time.get_time_pos():
		return
	var new_box_start_pos = Vector3()
	new_box_start_pos.x = global_position.x/space_time.x_scale
	new_box_start_pos.y = -global_position.y/space_time.y_scale
	new_box_start_pos.z = space_time.get_time_pos()
	
	var new_body = active_body.duplicate()
	level.add_child(new_body)
	new_body.global_position = new_box_start_pos
	
	record_time_index(new_box_start_pos, new_body)
	
	#print(new_box_start_pos)
	#print(new_box_end_pos)
	#print()

func get_best_time_index():
	#if last_time_index > len(personal_timeline.keys()):
	#	last_time_index -= 1
	#	return(get_best_time_index())
	if last_time_index >= len(personal_timeline.keys()):
		if last_time_index == 0:
			#draw_self()
			return(personal_timeline.keys()[-1])
		last_time_index -= 1
		return(get_best_time_index())
	var best_yet = personal_timeline.keys()[last_time_index]
	if best_yet < space_time.player_time_index:
		if last_time_index == 0:
			return(personal_timeline.keys()[0])
		#last_time_index /= 2
		last_time_index -= 1
		return(get_best_time_index())
	while best_yet > space_time.player_time_index:
		last_time_index += 1
		if len(personal_timeline) <= last_time_index:
			break
		best_yet = personal_timeline.keys()[last_time_index]
	return(best_yet)

func draw_timeframe():
	if len(personal_timeline) == 0:
		return
	var timeframe_data = personal_timeline[get_best_time_index()]
	timeframe_sprite.global_position = timeframe_data[0]
	#print()
	#print(personal_timeline.keys())

func just_before(this_time_index):
	var key_index = personal_timeline.keys().find(this_time_index)
	return(personal_timeline.keys()[key_index -1])

func just_after(this_time_index):
	var key_index = personal_timeline.keys().find(this_time_index)
	return(personal_timeline.keys()[key_index +1])

func delete_timeline_forward():
	var time_index = just_before(get_best_time_index())
	last_time_index = personal_timeline.keys().find(time_index)
	time_index = personal_timeline.keys().find(time_index)
	var data_to_remove = []
	for i in range(time_index,len(personal_timeline)):
		data_to_remove.append(personal_timeline.keys()[i])
		#print("Remove " + str(i))
	#print("Delete from: ")
	#print(data_to_remove)
	#data_to_remove.pop_back()
	#data_to_remove.pop_back()
	for dead_box in data_to_remove:
		spaces_to_remove.append(personal_timeline[dead_box][-1])
		#vt.do_box(personal_timeline[dead_box][-1][0], personal_timeline[dead_box][-1][1])
		personal_timeline.erase(dead_box)

func retore_point(point_to_restore):
	var point_data = personal_timeline[point_to_restore]
	
	# Not needed on staticbodys
	body.global_position = point_data[0]
	body.global_rotation =  point_data[1]
	#body.linear_velocity =  point_data[2]
		#personal_timeline[z_time] = [body.global_position, body.global_rotation, body.linear_velocity, voxel_box]


func record_time_index(pos, mesh_obj):
	var z_time = pos.z
	if len(personal_timeline) > 0 and z_time > personal_timeline.keys()[-1]:
		retore_point(get_best_time_index())
		delete_timeline_forward()
		#print("Shreenk")
	personal_timeline[z_time] = [body.global_position, body.global_rotation, Vector3(0,0,0), mesh_obj]

func clean_up():
	for i in range(0,2):
		if spaces_to_remove != []:
			var needs_removed = spaces_to_remove.pop_front()
			needs_removed.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if not space_time.rendering:
	#body.set_physics_process(space_time.rendering)
	#print(space_time.rendering)
	#ttl -= delta
	#if ttl < 0:
	#	draw_timeframe()
	#	return
	if birth_date > space_time.player_time_index:
		print()
		print(found_date)
		print(space_time.player_time_index)
		if found_date < space_time.player_time_index:
			draw_timeframe()
		else:
			timeframe_sprite.global_position = Vector2(-1000,-10000)
	clean_up()
	draw_self()

