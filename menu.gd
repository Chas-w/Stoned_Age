extends Control
#ref this video: https://youtu.be/EeH4jzBbtfU?si=brc4LSlfIfXZbnzi

const STEAM_APP_ID = 480 #must be changed later currently using dev app ID

@onready var test_lobby_id = $"Room Code"

var join_code : String
var peer : SteamMultiplayerPeer
var is_joining := false
# Called when the node enters the scene tree for the first time.
func _ready():
	var steam_init := Steam.steamInit(STEAM_APP_ID, true) #connects to steam i think
	if(steam_init):
		print("Steam initialized")
		Steam.initRelayNetworkAccess()
		Steam.lobby_created.connect(_lobby_created) #connects this _lobby to steam lobby created
		Steam.lobby_match_list.connect(_check_lobby_code)
		Steam.lobby_joined.connect(_join_lobby)
	else:
		print("Steam did not initialize")

# Called every fram0e. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Steam.run_callbacks() #enables application to recieve steamworks callbacks

func _add_player(id : int = 1):
	print("Player joined with id: " + str(id))

func _remove_player(id : int):
	print("Player left with id: " + str(id))

func _on_host_pressed():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 4) #default to public and 4 max players, can be changed later

func _lobby_created(result : int, lobby_id : int):
	if(result == Steam.Result.RESULT_OK): #lobby succesfully created
		join_code = str(randi() % 100000).pad_zeros(5)
		Steam.setLobbyData(lobby_id, "join_code", join_code) #client to check before joining lobby
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		peer.connect_to_lobby(lobby_id)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		
		_add_player() #only being run on the host button
		
		print("lobby created with code: " + str(join_code))
		print("Steam Lobby ID: " + str(lobby_id))

func _on_join_pressed():
	join_code = test_lobby_id.text
	Steam.requestLobbyList()

func _check_lobby_code(lobbies : Array): #check through all valid IDs and see if current passed ID code is valid
	for lobby_id in lobbies:
		var code = Steam.getLobbyData(lobby_id, "join_code")
		if code == join_code:
			is_joining = true
			Steam.joinLobby(lobby_id)
			return
	pass

func _join_lobby(lobby_id : int, _permissions : int, _locked : bool, _response : int):
	if (!is_joining):
		return
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	peer.connect_to_lobby(lobby_id)
	multiplayer.multiplayer_peer = peer
	print("Joined Lobby: " + str(lobby_id))
	is_joining = false
