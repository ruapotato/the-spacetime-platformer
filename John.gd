extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = 6

var direction = 1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var just_hit = 0
var ttl

var space_time
var space
# Called when the node enters the scene tree for the first time.
func _ready():
	space_time = get_space_time()
	ttl = space_time.max_level_time
	space = space_time.find_child("space")

func get_space_time(test=self):
	var momma = test.get_parent()
	if momma.name == "space_time":
		return(momma)
	else:
		return(get_space_time(momma))

func _physics_process(delta):
	if not space_time.rendering:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func check_if_about_to_fall():
	if direction > 0:
		if len($ground_right_Area2D.get_overlapping_bodies()) == 0:
			#print("need to flip!!!")
			direction *= -1
			return
	else:
		if len($ground_left_Area2D.get_overlapping_bodies()) == 0:
			#print("need to flip!!!")
			direction *= -1
			return

func _process(delta):
	if not space_time.rendering:
		return
	ttl -= delta
	if ttl < 0:
		return
	#check_if_about_to_fall()
	if just_hit > 0:
		just_hit -= delta

#func _on_hit_box_area_2d_area_entered(area):
#	if "gooman" in area.name:
#		if just_hit <= 0:
#			direction *= -1
#			area.get_parent().direction = direction * -1
#			area.get_parent().just_hit = 1
#			just_hit = 1

func _on_coin_search_area_2d_area_exited(area):
	# Handle jump.
	print(area.name)
	if "birth_date" in area:
		print("coin")
		#print(-area.birth_date)
		#print(space_time.z_time_index)
		if -area.birth_date > space_time.z_time_index:
			return
		if is_on_floor():
			var jump_velocity = float(area.global_position.y - global_position.y)
			jump_velocity = jump_velocity / 1
			print(global_position.y)
			print(area.global_position.y)
			print(jump_velocity * JUMP_VELOCITY)
			velocity.y = jump_velocity * JUMP_VELOCITY
