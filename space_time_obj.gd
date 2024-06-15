extends Node2D

@onready var ground_coloring = preload("res://native/gound.tres")

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
var reusable_timeline = []
var running = true
var last_speed
var static_body = null
var active_body = null
var space
var level
var z_time = 0
var last_z_time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	space_time =  get_space_time()
	space = space_time.find_child("space")
	level = space.get_children()[0]
	ttl = space_time.max_level_time

	#print(name)
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
	
	if body is StaticBody2D:
		static_body = StaticBody3D.new()
		var new_box_sin = MeshInstance3D.new()
		var new_box_shape = CollisionShape3D.new()
		new_box_sin.mesh = BoxMesh.new()
		new_box_shape.shape = BoxShape3D.new()
		
		
		new_box_sin.mesh.size.x = float(sprite.texture.width)/world_scale * 2
		new_box_sin.mesh.size.y = float(sprite.texture.height)/world_scale * 2
		new_box_sin.mesh.size.z = space_time.render_range * 2
		new_box_sin.set_surface_override_material(0,ground_coloring)
		
		new_box_shape.shape.size.x = float(sprite.texture.width)/world_scale * 2
		new_box_shape.shape.size.y = float(sprite.texture.height)/world_scale * 2
		new_box_shape.shape.size.z = space_time.render_range * 2
		print(sprite.texture.height/world_scale)
		
		
		static_body.add_child(new_box_sin)
		static_body.add_child(new_box_shape)
		level.add_child.call_deferred(static_body)

		
	else:
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
	#print(vt)


func get_space_time(test=self):
	var momma = test.get_parent()
	if momma.name == "space_time":
		return(momma)
	else:
		return(get_space_time(momma))

func draw_self():
	#if space_time.get_time_pos() in personal_timeline.keys():
	#	return
	var new_box_start_pos = Vector3()
	new_box_start_pos.x = global_position.x/space_time.x_scale
	new_box_start_pos.y = -global_position.y/space_time.y_scale
	new_box_start_pos.z = space_time.get_time_pos()
	var new_body
	
	if new_box_start_pos.z in personal_timeline.keys():
		new_body = personal_timeline[new_box_start_pos.z][-1]
		new_body.global_position = new_box_start_pos
	#	return
	else:
	#if new_box_start_pos.z in reusable_timeline: 
		new_body = active_body.duplicate()
		level.add_child(new_body)
		new_body.global_position = new_box_start_pos
	#new_body.set_deferred("global_position", new_box_start_pos)
	#level.add_child.call_deferred(new_body)
	
	record_time_index(new_box_start_pos, new_body)
	
	#print(new_box_start_pos)
	#print(new_box_end_pos)
	#print()

func get_best_time_index():
	var guess = float(int(space_time.player_time_index * 4))/4.0
	#print("time: " + str(guess))
	if guess not in personal_timeline.keys():
		#print("poo")
		return(personal_timeline.keys()[0])
	#return(personal_timeline.keys()[guess])
	return(guess)
	#print(guess)

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
		last_time_index -= 1
		return(get_best_time_index())
	while best_yet > space_time.player_time_index:
		last_time_index += 1
		if len(personal_timeline) <= last_time_index:
			break
		best_yet = personal_timeline.keys()[last_time_index]
	return(best_yet)

func draw_timeframe():
	#print(get_best_time_index())
	if not static_body:
		var timeframe_data = personal_timeline[get_best_time_index()]
		#print("FRAME!!!")
		#print(get_best_time_index())
		#print("FRAMEdone!!!")
		timeframe_sprite.global_position = timeframe_data[0]
	else:
		timeframe_sprite.global_position = global_position
	#print()
	#print(personal_timeline.keys())

func after(this_time_index, by=2):
	return(this_time_index - .25)
	var key_index = personal_timeline.keys().find(this_time_index)
	if key_index +by >= len(personal_timeline.keys()):
		return(after(this_time_index, by-1))
	return(personal_timeline.keys()[key_index +by])

func delete_timeline_forward():
	var time_index = after(get_best_time_index())
	time_index = personal_timeline.keys().find(time_index)
	last_time_index = time_index
	var data_to_remove = []
	for i in range(time_index,len(personal_timeline)):
		data_to_remove.append(personal_timeline.keys()[i])
		#print("Remove " + str(i))
	print("Delete from: ")
	print(data_to_remove)
	for dead_box in data_to_remove:
		reusable_timeline.append(dead_box)
		
		#personal_timeline[dead_box][-1].queue_free()
		#vt.do_box(personal_timeline[dead_box][-1][0], personal_timeline[dead_box][-1][1])
		#personal_timeline.erase(dead_box)

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
		body.state_data = point_data[3]
		#personal_timeline[z_time] = [body.global_position, body.global_rotation, body.velocity, voxel_box]




func record_time_index(pos, mesh_obj):
	z_time = pos.z
	var running_behind = z_time > last_z_time
	last_z_time = z_time
	#if len(personal_timeline) > 0:
		#print(z_time)
		#print(personal_timeline.keys()[-1])
		#print()
	if len(personal_timeline) > 0 and z_time > personal_timeline.keys()[-1]:
		if running_behind:
			print("Shreenk1")
			retore_point(get_best_time_index())
			delete_timeline_forward()
			print("Shreenk2")
	
	if body is StaticBody2D:
		#personal_timeline[z_time] = [body.global_position, body.global_rotation, Vector3(0,0,0), voxel_box]
		# Don't delete static bodies
		personal_timeline[z_time] = [body.global_position, body.global_rotation, Vector3(0,0,0), mesh_obj]
	if body is RigidBody2D:
		personal_timeline[z_time] = [body.global_position, body.global_rotation, body.linear_velocity, mesh_obj]
	if body is CharacterBody2D:
		personal_timeline[z_time] = [body.global_position, body.global_rotation, body.velocity, body.state_data.duplicate(true), mesh_obj]

func clean_up():
	for i in range(0,2):
		if reusable_timeline != []:
			var needs_removed = reusable_timeline.pop_front()
			print(needs_removed)
			needs_removed.global_position = Vector3(0,0,0)
			#if len(needs_removed) % 3 != 0:
			#	clean_up()


# Called every frame. 'delta' is the elapsed time since the previous frame.

func update_pos():
	#print(static_body.global_position)
	#static_body.glob
	static_body.set_deferred("global_position", Vector3(global_position.x/space_time.x_scale,-global_position.y/space_time.y_scale,space_time.player_time_index))
	#print(static_body.shape)
	#static_body.global_position.z = space_time.player_time_index

func _physics_process(delta):
	if static_body:
		update_pos()

	
func _process(delta):
	#print(personal_timeline.keys())
	if active_body:
		#clean_up()
		#if running:
		draw_self()
		draw_timeframe()
	if static_body:
		draw_timeframe()
