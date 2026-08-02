extends Node3D
#referenced this vid: https://youtu.be/rQ9mDxvuoeA?si=ReEoulqFMng0Djh8
const PLAYER_CONTROLLER = preload("uid://cs5uw5ng78niv")
@export var spawn_spot  : Marker3D
var players: Array[Node3D]

@onready var input_join_code = $"Menu UI/Menu/Room Code"
@onready var menu_ui = $"Menu UI"

func _ready() -> void:
	Networking.host_created.connect(on_host_created)

func on_host_created() -> void:
	# Spawn the server player
	spawn_player(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn_player)

# The server spawns the player that just connected
func spawn_player(peer_id: int) -> void:
	var new_player := PLAYER_CONTROLLER.instantiate() as Node3D
	new_player.name = str(peer_id)
	print("New Player Spawned with ID: " + str(peer_id))
	add_child(new_player)
	initialize_player(new_player)

func initialize_player(player: Node3D) -> void:
	player.position = spawn_spot.position
	for other in players:
		player.add_collision_exception_with(other)
	players.append(player)

func _on_host_pressed() -> void:
	Networking.host_lobby()
	menu_ui.visible = false

func _on_join_pressed():
	Networking.join_lobby(input_join_code.text)

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is Node3D:
		initialize_player(node)
