## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
## It uses signals to communicate.
tool
class_name Unit
extends Node2D

export var grid: Resource
export var skin: Texture setget set_skin
export var speed := 6
export var skin_offset := Vector2.ZERO setget set_skin_offset

onready var _sprite: Sprite = $Sprite
onready var _anim_player: AnimationPlayer = $AnimationPlayer

## Coordinates of the current cell the cursor moved to.
var cell := Vector2.ZERO setget set_cell
var is_selected := false setget set_is_selected


func _ready() -> void:
	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)
	_sprite.position = skin_offset


func set_cell(value: Vector2) -> void:
	if not grid.is_within_bounds(value):
		cell = grid.clamp(value)
	else:
		cell = value
	position = grid.calculate_map_position(cell)


func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")


func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		yield(self, "ready")
	_sprite.position = value
