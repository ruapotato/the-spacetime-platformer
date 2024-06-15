extends CharacterBody3D

@onready var piv = $piv
@onready var spring_arm = $piv/SpringArm3D
const SPEED = 8.0
const JUMP_VELOCITY = 7

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = .0035
var max_zoom = 4.75
var min_zoom = 0

var space_time

func _ready():
	space_time = get_space_time()

func get_space_time(test=self):
	var momma = test.get_parent()
	if momma.name == "space_time":
		return(momma)
	else:
		return(get_space_time(momma))


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotate_x(event.relative.y * -mouse_sensitivity)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/2, PI/2)
		piv.rotate_y(event.relative.x * -mouse_sensitivity)
	if Input.is_action_just_pressed("zoom_out"):
		#print(find_child("SpringArm3D").spring_length)
		if max_zoom >= spring_arm.spring_length + .25:
			spring_arm.spring_length += .25
	
	if Input.is_action_just_pressed("zoom_in"):
		#print(find_child("SpringArm3D").spring_length)
		if min_zoom <= spring_arm.spring_length - .25:
			spring_arm.spring_length -= .25
			
	if Input.is_action_just_pressed("add"):
		space_time.add_coin(global_position)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (piv.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
