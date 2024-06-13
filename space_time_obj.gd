extends Node2D

var space_time
var voxels
var vt
var sprite
var timeframe_sprite
var timeframe
var world_scale = 40
var personal_timeline = {}
var body
var ttl = 100000
var last_time_index = 0
var spaces_to_remove = []
var running = true
var last_speed
# Called when the node enters the scene tree for the first time.
func _ready():
	space_time =  get_space_time()
	ttl = space_time.max_level_time
	voxels = space_time.make_voxel_space()
	vt = voxels.get_voxel_tool()
	print(name)
	if "Sprite2D" in name:
		sprite = self
		body = get_parent()
	else:
		sprite = find_child("Sprite2D")
		body = self
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
	var new_box_start_pos = Vector3()
	new_box_start_pos.x = global_position.x/space_time.x_scale
	new_box_start_pos.y = -global_position.y/space_time.y_scale
	new_box_start_pos.z = space_time.get_time_pos()
	
	
	var new_box_end_pos = new_box_start_pos
	new_box_end_pos.x -= sprite.texture.width/world_scale
	new_box_end_pos.y -= sprite.texture.height/world_scale
	new_box_end_pos.z -= .5
	vt.mode = VoxelTool.MODE_ADD
	
	
	new_box_start_pos.x += sprite.texture.width/world_scale
	new_box_start_pos.y += sprite.texture.height/world_scale
	vt.do_box(new_box_start_pos, new_box_end_pos)
	
	record_time_index(new_box_start_pos.z, [new_box_start_pos, new_box_end_pos])
	
	#print(new_box_start_pos)
	#print(new_box_end_pos)
	#print()

func get_best_time_index():
	if last_time_index not in personal_timeline.keys():
		if last_time_index == 0:
			#draw_self()
			return(personal_timeline.keys()[-1])
		last_time_index = 0
		return(get_best_time_index())
	var best_yet = personal_timeline.keys()[last_time_index]
	if best_yet < space_time.player_time_index:
		if last_time_index == 0:
			return(personal_timeline.keys()[0])
		last_time_index -= 1
		return(get_best_time_index())
	while best_yet > space_time.player_time_index:
		last_time_index += 1
		if len(personal_timeline) <= last_time_index:
			break
		best_yet = personal_timeline.keys()[last_time_index]
	return(best_yet)

func draw_timeframe():
	var timeframe_data = personal_timeline[get_best_time_index()]
	timeframe_sprite.global_position = timeframe_data[0]
	#print()
	#print(personal_timeline.keys())

func just_before(this_time_index):
	var key_index = personal_timeline.keys().find(this_time_index)
	return(personal_timeline.keys()[key_index -1])

func delete_timeline_forward():
	var time_index = just_before(get_best_time_index())
	last_time_index = time_index
	time_index = personal_timeline.keys().find(time_index)
	var data_to_remove = []
	for i in range(time_index,len(personal_timeline)):
		data_to_remove.append(personal_timeline.keys()[i])
		#print("Remove " + str(i))
	#print("Delete from: ")
	#print(data_to_remove)
	vt.mode = VoxelTool.MODE_REMOVE
	for dead_box in data_to_remove:
		spaces_to_remove.append(personal_timeline[dead_box][-1])
		#vt.do_box(personal_timeline[dead_box][-1][0], personal_timeline[dead_box][-1][1])
		personal_timeline.erase(dead_box)

func retore_point(point_to_restore):
	var point_data = personal_timeline[point_to_restore]
	
	# Not needed on staticbodys
	#if body is StaticBody2D:
		#personal_timeline[z_time] = [body.global_position, body.global_rotation, Vector3(0,0,0), voxel_box]
		# Don't delete static bodies
	#	personal_timeline[z_time] = [body.global_position, body.global_rotation, Vector3(0,0,0), [Vector3(0,0,0),Vector3(0,0,0)]]
	if body is RigidBody2D:
		body.global_position = point_data[0]
		body.global_rotation =  point_data[1]
		body.linear_velocity =  point_data[2]
		#personal_timeline[z_time] = [body.global_position, body.global_rotation, body.linear_velocity, voxel_box]
	if body is CharacterBody2D:
		body.global_position = point_data[0]
		body.global_rotation =  point_data[1]
		body.velocity =  point_data[2]
		#personal_timeline[z_time] = [body.global_position, body.global_rotation, body.velocity, voxel_box]

func record_time_index(z_time, voxel_box):
	if len(personal_timeline) > 0 and z_time > personal_timeline.keys()[-1]:
		retore_point(get_best_time_index())
		delete_timeline_forward()
		print("Shreenk")
	
	if body is StaticBody2D:
		#personal_timeline[z_time] = [body.global_position, body.global_rotation, Vector3(0,0,0), voxel_box]
		# Don't delete static bodies
		personal_timeline[z_time] = [body.global_position, body.global_rotation, Vector3(0,0,0), [Vector3(0,0,0),Vector3(0,0,0)]]
	if body is RigidBody2D:
		personal_timeline[z_time] = [body.global_position, body.global_rotation, body.linear_velocity, voxel_box]
	if body is CharacterBody2D:
		personal_timeline[z_time] = [body.global_position, body.global_rotation, body.velocity, voxel_box]

func clean_up():
	for i in range(0,2):
		if spaces_to_remove != []:
			var needs_removed = spaces_to_remove.pop_front()
			vt.mode = VoxelTool.MODE_REMOVE
			vt.do_box(needs_removed[0], needs_removed[1])
			#if len(needs_removed) % 3 != 0:
			#	clean_up()


func stop_if_too_far():
	if running and not space_time.rendering:
		running = false
		if body is RigidBody2D:
			last_speed = body.linear_velocity
			body.linear_velocity = Vector2(0,0)
		if body is CharacterBody2D:
			last_speed = body.velocity
			body.velocity = Vector2(0,0)
	if not running and space_time.rendering:
		running = true
		if body is RigidBody2D:
			body.linear_velocity = last_speed
		if body is CharacterBody2D:
			body.velocity = last_speed
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _physics_process(delta):
	stop_if_too_far()
func _process(delta):

	#body.set_physics_process(space_time.rendering)
	#stop_if_too_far()
	#ttl -= delta
	#if ttl < 0:
	#	draw_timeframe()
	#	return
	clean_up()
	#if running:
	draw_self()
	draw_timeframe()
