extends Node
# ref this vid: https://youtu.be/V4a_J38XdHk?si=ClrCrIg6yETg3cAW
const SERVER_PORT = 8000
const SERVER_IP = "127.0.0.1"
var player_scene = preload("res://Scenes/Player/Player Controller.tscn")
var _players_spawn_node 

func _become_host():
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")

	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	_add_player_to_game(1)
func _join_game():
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP,SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
	print("Player joining")

func _add_player_to_game(id : int):
	print("Player %s joined the game!" % id)
	var player_to_add = player_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add,true)
func _del_player(id : int):
	print("Player %s left the game!" % id)
