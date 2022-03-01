extends Node2D

enum State {EMPTY, O, X}

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
	if Input.is_key_pressed(KEY_ENTER):
		reset_data_store()
		update_ui()

func _ready() -> void:
	reset_data_store()
	update_ui()

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

func clicked_on(field_no: int, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and winner == State.EMPTY:
		if current_player == State.X:
			data[field_no] = State.X
			current_player = State.O
		else: 
			data[field_no] = State.O
			current_player = State.X
		check_winner()
		update_ui()

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
