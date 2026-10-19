extends SceneTree
var checks: int = 0
var failures: int = 0
var game: Node3D
var actor: FPSController
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	game = load("res://scenes/startup.tscn").instantiate()
	root.add_child(game)
	actor = game.get_node("Player")
	await _frames(20)
	_expect(game.has_node("Surroundings/TerrainBank") and game.has_node("OutdoorAssets/Buildings/Cargo offen"), "Existing outpost gains a small connected border area")
	_expect(game.get_node("IndustrialKiste") is RigidBody3D and game.has_node("Target") and game.has_node("Switch"), "Existing physical props, target and interaction remain")
	await _capture("arrival")
	var query := PhysicsRayQueryParameters3D.create(Vector3(24,5,0),Vector3(24,-2,0),1)
	var result: Dictionary = game.get_world_3d().direct_space_state.intersect_ray(query)
	_expect(not result.is_empty() and result.position.y > 0.6 and result.position.y < 1.0, "Baked terrain mesh has matching raised collision")
	actor.position = Vector3(18,0.05,9)
	actor.rotation.y = -PI*0.5
	actor.velocity = Vector3.ZERO
	await _frames(10)
	Input.action_press("move_forward")
	await _frames(60)
	Input.action_release("move_forward")
	_expect(actor.position.x > 22 and actor.is_on_floor() and actor.position.y > 0.2, "South opening connects smoothly to the rising service path")
	actor.rotation.y = PI*0.5
	await _frames(8)
	await _capture("ridge_view")
	actor.rotation.y = 0
	Input.action_press("move_forward")
	await _frames(235)
	Input.action_release("move_forward")
	_expect(actor.position.z < -8 and actor.is_on_floor(), "Raised path can be followed to the northern opening")
	await _capture("service_path")
	actor.rotation.y = PI*0.5
	Input.action_press("move_forward")
	await _frames(80)
	Input.action_release("move_forward")
	_expect(actor.position.x < 19 and actor.is_on_floor(), "North opening returns to the original yard without jumping")
	actor.position = Vector3(32,1.25,0)
	actor.rotation.y = -PI*0.5
	actor.velocity = Vector3.ZERO
	await _frames(10)
	Input.action_press("move_forward")
	await _frames(60)
	Input.action_release("move_forward")
	_expect(actor.position.x < 33.8 and actor.is_on_floor(), "Visible fence contains the raised playable area")
	for path: String in ["Surroundings/TerrainBank", "Surroundings/MaintenanceTrail", "Surroundings/WorkApron"]:
		var mesh: MeshInstance3D = game.get_node(path).find_children("*","MeshInstance3D",true,false)[0]
		var material: StandardMaterial3D = mesh.get_active_material(0)
		_expect(material != null and material.albedo_texture != null and material.albedo_texture.get_image().has_mipmaps(), path + ": textured with mipmaps")
	if OS.get_cmdline_user_args().has("--capture"):
		var camera := Camera3D.new()
		game.add_child(camera)
		camera.position = Vector3(43,36,43)
		camera.look_at(Vector3(5,0,0))
		camera.current = true
		await _capture("layout")
	game.queue_free()
	await process_frame
	print("Outpost expansion checks: %d passed, %d failed" % [checks-failures,failures])
	quit(1 if failures else 0)
func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame
func _capture(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"):return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/expansion")
	_expect(root.get_texture().get_image().save_png("res://.godot/checks/expansion/%s.png" % label)==OK,"Rendered "+label)
func _expect(value: bool, label: String) -> void:
	checks += 1
	if value:print("PASS: "+label)
	else:
		failures += 1
		push_error("FAIL: "+label)
