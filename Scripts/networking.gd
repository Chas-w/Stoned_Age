extends Node
#code referenced from: https://github.com/MacIcyEngine/GodotSteamMultiplayer/blob/main/networking.gd
signal host_created()
const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 4

var peer: SteamMultiplayerPeer
var is_joining := false
var join_code : String

func _ready() -> void:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	Steam.join_requested.connect(on_join_requested)
	Steam.lobby_match_list.connect(_check_lobby_code)


func _process(delta: float) -> void:
	# Must be called every frame
	Steam.run_callbacks()

func host_lobby() -> void:
	# Will cause the "lobby_created" and "lobby_joined" signals to emit
	Steam.createLobby(LOBBY_TYPE, MAX_MEMBERS)

func join_lobby(code : String):
	if(code != " "):
		join_code = code
		Steam.requestLobbyList()
	else:
		print("Invalid Code")

# Called after creating a lobby locally
func on_lobby_created(connect: int, lobby_id: int) -> void:
	# We created the lobby, so we act as server host
	if connect == Steam.RESULT_OK:
		join_code = str(randi() % 100000).pad_zeros(5)
		Steam.setLobbyData(lobby_id, "join_code", join_code) #client to check before joining lobby
		
		print("Lobby created with id: " + str(join_code))
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()

func _check_lobby_code(lobbies : Array): #check through all valid IDs and see if current passed ID code is valid
	print("Attempting to join lobby")
	for lobby_id in lobbies:
		var code = Steam.getLobbyData(lobby_id, "join_code")
		if code == join_code:
			is_joining = true
			Steam.joinLobby(lobby_id)
			print("Joining lobby: " + str(lobby_id))
			return
	pass

# Called when joining a lobby (after creating the lobby or joining a friend)
func on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		# If we created the lobby, we are already hosting, so we should not create a new client peer
		if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
			print("USER is HOST")
			return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(lobby_id))
		multiplayer.multiplayer_peer = peer
		print("Lobby joined with id: " + str(lobby_id))

# Called when attempting to join from the Steam interface
func on_join_requested(lobby_id: int, steam_id: int) -> void:
	# Will cause the "lobby_joined" signal to emit
	Steam.joinLobby(lobby_id)
	print("Join lobby requested with ID: " + str(lobby_id))
