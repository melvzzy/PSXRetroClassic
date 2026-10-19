extends Node3D
## Isolated inspection camera; no player, weapons, collision or shared input actions.
const CENTERS: Array[Vector3] = [Vector3(0, 1, 0), Vector3(-6, 2, -10), Vector3(-6, 0, 14), Vector3(25, 2, 8), Vector3(16, 1, -8)]
const DISTANCES: Array[float] = [65.0, 25.0, 30.0, 13.0, 14.0]
const TITLES: Array[String] = ["Gesamtauswahl", "Gebäude / Cargo", "Straßenmodule", "Sommervegetation", "Industrie / Nutzobjekte"]
var target := Vector3(0, 1, 0)
var distance: float = 65.0
var yaw: float = 0.55
var pitch: float = 0.55
@onready var camera: Camera3D = $Camera3D
func _ready() -> void:
	focus_group(0)
func focus_group(index: int) -> void:
	target = CENTERS[index]
	distance = DISTANCES[index]
	$HUD/Title.text = "ASSET-PRÜFUNG · " + TITLES[index]
	_update_camera()
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode >= KEY_0 and event.physical_keycode <= KEY_4:
			focus_group(event.physical_keycode - KEY_0)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x * 0.006
		pitch = clampf(pitch + event.relative.y * 0.006, 0.08, 1.35)
		_update_camera()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = maxf(3.0, distance * 0.88)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = minf(100.0, distance / 0.88)
		_update_camera()
func _update_camera() -> void:
	camera.position = target + Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
	camera.look_at(target)
