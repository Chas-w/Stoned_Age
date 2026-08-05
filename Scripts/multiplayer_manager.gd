extends Node
const SERVER_PORT = 8000
const SERVER_IP = "127.0.0.1"

func _become_host():
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
func _join_game():
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP,SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
	print("Player joining")
func _add_player_to_game(id : int):
	print("Player %s joined the game!" % id)

func _del_player(id : int):
	print("Player %s left the game!" % id)
