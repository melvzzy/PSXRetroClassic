extends SceneTree
var checks: int=0
var failures: int=0
var game: Node3D
var actor: FPSController
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	game=load("res://scenes/startup.tscn").instantiate()
	root.add_child(game)
	actor=game.get_node("Player")
	await _frames(20)
	var details: Node3D=game.get_node("FoundationDetails")
	_expect(details.has_node("WorkbenchTop") and details.has_node("WorkshopBottles") and details.has_node("ShelfStorageBox"),"Cargo has a purposeful workshop and storage interior")
	for title: String in ["WorkshopHammer","WorkshopBottles","WorkshopBin"]:
		var meshes: Array[Node] = details.get_node(title).find_children("*", "MeshInstance3D", true, false)
		var valid: bool = not meshes.is_empty()
		for mesh: MeshInstance3D in meshes:
			var material: StandardMaterial3D=mesh.get_active_material(0)
			valid=valid and material!=null and material.albedo_texture!=null and mesh.is_visible_in_tree()
		_expect(valid,title+": original model and texture render")
	_expect(details.get_node("WorkshopLight").light_energy<=1.5,"Restrained local workshop light")
	actor.position=Vector3(6,0.12,-7.4)
	actor.rotation.y=PI*0.5
	actor.velocity=Vector3.ZERO
	await _frames(10)
	Input.action_press("move_forward")
	await _frames(35)
	Input.action_release("move_forward")
	_expect(actor.position.x>5.4 and actor.position.x<5.9,"Workbench has matching collision outside the central passage")
	actor.position=Vector3(6,0.12,-9.3)
	actor.rotation.y=-PI*0.5
	actor.velocity=Vector3.ZERO
	await _frames(10)
	Input.action_press("move_forward")
	await _frames(35)
	Input.action_release("move_forward")
	_expect(actor.position.x<6.8,"Shelf collision matches its visible boards")
	actor.position=Vector3(6,0.12,-5)
	actor.rotation.y=0
	actor.velocity=Vector3.ZERO
	await _frames(8)
	await _capture("workshop")
	actor.position=Vector3(27,1.25,0)
	actor.rotation.y=-PI*0.5
	actor.velocity=Vector3.ZERO
	await _frames(10)
	Input.action_press("move_forward")
	await _frames(65)
	Input.action_release("move_forward")
	_expect(actor.position.x>30 and actor.is_on_floor(),"New clearing connects to the existing raised path")
	actor.rotation.y=PI
	await _frames(8)
	await _capture("clearing")
	actor.position=Vector3(32,1.25,0)
	actor.rotation.y=-PI*0.5
	actor.velocity=Vector3.ZERO
	await _frames(8)
	Input.action_press("move_forward")
	await _frames(65)
	Input.action_release("move_forward")
	_expect(actor.position.x > 33.0 and actor.position.x < 33.8 and actor.is_on_floor(),"Relocated visible fence safely bounds the clearing")
	for i: int in range(6):
		var rock: StaticBody3D=details.get_node("RockGroup"+str(i))
		var collider: CollisionShape3D=rock.find_children("*","CollisionShape3D",true,false)[0]
		_expect(rock.scale.is_equal_approx(Vector3.ONE) and collider.shape is ConvexPolygonShape3D,"Rock %d has valid unscaled convex collision"%i)
	if OS.get_cmdline_user_args().has("--capture"):
		var camera:=Camera3D.new()
		game.add_child(camera)
		camera.position=Vector3(43,31,32)
		camera.look_at(Vector3(6,0,0))
		camera.current=true
		await _capture("overview")
	game.queue_free()
	await process_frame
	print("Final area checks: %d passed, %d failed"%[checks-failures,failures])
	quit(1 if failures else 0)
func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame
func _capture(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"):return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/final_area")
	_expect(root.get_texture().get_image().save_png("res://.godot/checks/final_area/%s.png"%label)==OK,"Rendered "+label)
func _expect(value: bool,label: String) -> void:
	checks+=1
	if value:print("PASS: "+label)
	else:
		failures+=1
		push_error("FAIL: "+label)
