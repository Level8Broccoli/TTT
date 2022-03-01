extends Area2D

onready var hover_sprite : Sprite = get_node("HoverSprite")
onready var x_o_sprite : Sprite = get_node("X-O")
onready var winner_rect : ColorRect = get_node("Winner")
onready var x = preload("res://Icons/xmark-solid.svg")
onready var o = preload("res://Icons/circle-solid.svg")

func _ready() -> void:
	hover_sprite.hide()

func _on_Field_mouse_entered() -> void:
	var t = x_o_sprite.get_texture()
	if t == null:
		hover_sprite.show()

func _on_Field_mouse_exited() -> void:
	hover_sprite.hide()

func play_x() -> void:
	x_o_sprite.set_texture(x)
	hover_sprite.hide()
	
func play_o() -> void:
	x_o_sprite.set_texture(o)
	hover_sprite.hide()
	
func reset_field() -> void:
	x_o_sprite.set_texture(null)
	winner_rect.hide()

func mark_as_won() -> void:
	winner_rect.show()
