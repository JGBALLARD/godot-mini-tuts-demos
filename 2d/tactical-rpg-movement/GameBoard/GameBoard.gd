## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

signal unit_selected(unit)

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _selected_unit: Unit
var _walkable_cells := []

onready var _cursor: Cursor = $Cursor
onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _unit_path: UnitPath = $UnitPath


func _ready() -> void:
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if _selected_unit and event.is_action_pressed("ui_cancel"):
		_deselect_unit()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


## Returns `true` if the cell is occupied.
func is_occupied(grid_position: Vector2) -> bool:
	return true if _units.has(grid_position) else false


func get_walkable_cells(unit: Unit) -> Array:
	var out := []
	_flood_fill(out, unit, unit.cell, unit.speed)
	return out


## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		if not child is Unit:
			continue
		var coordinates: Vector2 = grid.calculate_grid_coordinates(child.position)
		_units[coordinates] = child


## Fills the `array` with coordinates of walkable cells based on the `max_distance`.
func _flood_fill(array: Array, unit: Unit, cell: Vector2, max_distance: int) -> void:
	# While arrays are supposed to be passed by reference,
	# the condition below produces strange results.
	# Without it though, the array contains duplicates.
#	if cell in array:
#		return
	if max_distance == 0:
		return
	if cell != unit.cell and is_occupied(cell):
		return

	array.append(cell)
	for direction in DIRECTIONS:
		var neighbor_cell: Vector2 = cell + direction
		if not grid.is_within_bounds(neighbor_cell):
			continue
		_flood_fill(array, unit, neighbor_cell, max_distance - 1)


func _move_unit(unit: Unit, new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	# warning-ignore:return_value_discarded
	_units.erase(unit.cell)
	_units[new_cell] = unit
	unit.cell = new_cell
	_deselect_unit()


func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return
	var unit: Unit = _units[cell]
	_selected_unit = unit
	unit.is_selected = true
	_walkable_cells = get_walkable_cells(unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)


func _deselect_unit() -> void:
	_selected_unit.is_selected = false
	_selected_unit = null
	_walkable_cells = []
	_unit_overlay.clear()
	_unit_path.stop()


func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _selected_unit:
		_select_unit(cell)
	else:
		_move_unit(_selected_unit, cell)


func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _selected_unit:
		_unit_path.draw(_selected_unit.cell, new_cell)