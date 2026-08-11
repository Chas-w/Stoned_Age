extends Node
@onready var multiplayer_hud = %"Multiplayer HUD"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func attempt_host():
	print("Host pressed")
	MultiplayerManager._become_host()
	multiplayer_hud.hide()

func attempt_join_as_client():
	print("Join Pressed")
	MultiplayerManager._join_game()
	multiplayer_hud.hide()

func use_steam():
	%"Steam HUD".show()
	%"Multiplayer HUD".hide()
	SteamManager.init_steam()
	
func list_steam_lobbies():
	print("LISTING LOBBIES...")
	pass
