@icon("uid://b4e1f62upntch")
extends RigidBody3D
##quick link to top of script
func _back_to_vars():
	pass

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 10
const SENSITIVITY = 0.004

#fov variables
const BASE_FOV = 75.0
const SPRINT_F_CHANGE = 2
const WALK_F_CHANGE = 1.5
var fov_change := 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8
var grounded : bool
@export var ground_cast : RayCast3D
@export var use_fov_change : bool
@export var use_headbob : bool
#bob variables
var t_bob = 0.0
@export_range(0,3,.1) var bob_freq
@export_range(0,.5,.01) var bob_amp

@onready var head = %Head
@onready var camera = %Camera3D
@onready var p_cam = %PhantomCamera3D

@export_category("Multiplayer")
@export var player_id : int
@export var multiplayer_name : Label3D
@export var body_mesh : MeshInstance3D
@export var vc_output : AudioStreamPlayer3D
##this is the player that this instance is controlling
var main_player := true

func _load_in():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
	speed = WALK_SPEED
	set_multiplayer_authority(name.to_int())

func _enter_tree():
	_load_in()

func _setup_local_player():
	player_id = get_multiplayer_authority()
	print("player id " + str(player_id))
	print("multiplayer id " + str(multiplayer.get_unique_id()))
	if(multiplayer.get_unique_id() == player_id):
		%Camera3D.make_current()
		%SubViewportContainer.visible = true
		%PhantomCamera3D.visible = true
		multiplayer_name.text = Steam.getPersonaName()
		#cull these from main camera
		body_mesh.set_layer_mask_value(20,true)
		body_mesh.set_layer_mask_value(1,false)
		multiplayer_name.set_layer_mask_value(20,true)
		multiplayer_name.set_layer_mask_value(1,false)
	else:
		%Camera3D.visible = false
		main_player = false
		# We get the index of the "Record" bus.


func _ready():
	_setup_local_player()

func _unhandled_input(event):
	if event is InputEventMouseMotion && main_player:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		p_cam.rotate_x(-event.relative.y * SENSITIVITY)
		p_cam.rotation.x = clamp(p_cam.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _process(delta):
	pass

func _physics_process(delta):
	if(main_player):
		#movement
		grounded = ground_cast.is_colliding()
		_handle_movement(delta)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos

func _handle_movement(delta):
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	body_mesh.rotation.y = head.rotation.y
		# Add the gravity.
	if !grounded:
		linear_velocity.y -= gravity * delta
		linear_velocity.x = lerp(linear_velocity.x, direction.x * speed, delta * 3.0)
		linear_velocity.z = lerp(linear_velocity.z, direction.z * speed, delta * 3.0)
	else:
		#jump
		if(Input.is_action_just_pressed("jump")):
			linear_velocity.y = JUMP_VELOCITY
		#TODO sprint
		if(Input.is_action_pressed("sprint")):
			speed = SPRINT_SPEED
			fov_change = SPRINT_F_CHANGE
		else:
			speed = WALK_SPEED
			fov_change = WALK_F_CHANGE
		#move
		if direction:
			linear_velocity.x = direction.x * speed
			linear_velocity.z = direction.z * speed
		else:
			linear_velocity.x = lerp(linear_velocity.x, direction.x * speed, delta * 7.0)
			linear_velocity.z = lerp(linear_velocity.z, direction.z * speed, delta * 7.0)
	
	if(use_headbob):
		# Head bob
		t_bob += delta * abs(sqrt((linear_velocity.x ** 2 )+ (linear_velocity.z) ** 2)) * float(grounded)
		p_cam.transform.origin = _headbob(t_bob)
	if(use_fov_change):
		# FOV
		var velocity_clamped = clamp(abs(sqrt((linear_velocity.x ** 2 )+ (linear_velocity.z) ** 2)), 0.5, SPRINT_SPEED * 2)
		var target_fov = BASE_FOV + fov_change * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
