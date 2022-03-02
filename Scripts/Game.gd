extends Node2D

enum State {EMPTY, O, X}

const websocket_url = "ws://ttt-echo.herokuapp.com/echo/websocket"
var _client = WebSocketClient.new()

onready var checker := [
	[0,1,2], [3,4,5], [6,7,8],
	[0,3,6], [1,4,7], [2,5,8],
	[0,4,8], [2,4,6],
]

onready var fields = [
	get_node("0"), get_node("1"), get_node("2"),
	get_node("3"),  get_node("4"), get_node("5"),
	get_node("6"), get_node("7"), get_node("8"),
]

onready var text_output = get_node("Label")

var data = [
	State.EMPTY, State.EMPTY, State.EMPTY,
	State.EMPTY, State.EMPTY, State.EMPTY,
	State.EMPTY, State.EMPTY, State.EMPTY,
]

var current_player = State.X
var winner = State.EMPTY
var winning_fields = []

func _process(_delta: float) -> void:
	_client.poll()
	if Input.is_key_pressed(KEY_ENTER):
		reset_data_store()
		_client.get_peer(1).put_packet("reset".to_utf8()) 

func _ready() -> void:
	reset_data_store()
	update_ui()
	connect_ws()

func check_winner() -> void:
	for line in checker:
		var a = data[line[0]]
		var b = data[line[1]]
		var c = data[line[2]]
		
		if a == b and b == c:
			winner = a
			winning_fields = line
			break

func update_ui() -> void:
	for i in range(len(fields)):
		var field = fields[i]
		var state = data[i]
		
		if state == State.EMPTY:
			field.reset_field()
		elif state == State.O:
			field.play_o()
		elif state == State.X:
			field.play_x()
	update_label()
	mark_winning_fields()
		
func mark_winning_fields() -> void:
	if winner != State.EMPTY:
		for i in winning_fields:
			var f = fields[i]
			f.mark_as_won()

func update_label() -> void:
	if winner != State.EMPTY:
		var winner_str: String = "X" if winner == State.X else "O"
		text_output.set_text("Gewonnen hat Spieler '" + winner_str + "'!\nNeustart: Enter drücken")
	else:
		var current_player_str: String = "X" if current_player == State.X else "O"
		text_output.set_text("Aktiver Spieler: '" + current_player_str + "'")

func reset_data_store() -> void:
	winner = State.EMPTY
	winning_fields = []
	for i in range(len(fields)):
		data[i] = State.EMPTY
	update_ui()

func clicked_on(field_no: int, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_client.get_peer(1).put_packet(("TTT.State:" + String(data) + "||TTT.Click:" + String(field_no) + "||TTT.Player:" + String(current_player)).to_utf8()) 

func _on_0_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	clicked_on(0, event)

func _on_1_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	clicked_on(1, event)

func _on_2_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	clicked_on(2, event)

func _on_3_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	clicked_on(3, event)

func _on_4_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	clicked_on(4, event)

func _on_5_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	clicked_on(5, event)

func _on_6_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	clicked_on(6, event)

func _on_7_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	clicked_on(7, event)

func _on_8_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	clicked_on(8, event)


func connect_ws() -> void:
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	_client.get_peer(1).put_packet("Test packet".to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var res = _client.get_peer(1).get_packet().get_string_from_utf8()
	print("Got data from server: ", res)
	if res == "reset":
		reset_data_store()

	var regex = RegEx.new()
	regex.compile("[^|]+")
	var results = []
	for result in regex.search_all(res):
		results.push_back(result.get_string())
	if len(results) == 3:
		var regex2 = RegEx.new()
		regex2.compile("[^:]+")
		var new_state = regex2.search_all(results[0])[1].get_string()
		var res_click = regex2.search_all(results[1])[1].get_string()
		var res_player = regex2.search_all(results[2])[1].get_string()
		current_player = int(res_player)
		var regex3 = RegEx.new()
		regex3.compile("\\d")
		var found_states = regex3.search_all(new_state)
		for i in len(found_states):
			data[i] = int(found_states[i].get_string())
		if winner == State.EMPTY and data[int(res_click)] == State.EMPTY:
			if current_player == State.X:
				data[int(res_click)] = State.X
				current_player = State.O
			else: 
				data[int(res_click)] = State.O
				current_player = State.X
			check_winner()
			update_ui()

