@tool
extends Node3D

@export var make_local := false:
	set(value):
		if value:
			#print("Making all instanced scenes local...")
			_make_all_local()
			make_local = false  # Reset toggle

func _make_all_local():
	for child in get_children():
		if child.scene_file_path != "":
			#print("Localizing:", child.name)
			var packed_scene = load(child.scene_file_path)
			if packed_scene:
				var instance = packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
				instance.name = child.name
				make_resources_local(instance)
				add_child(instance)
				instance.set_owner(get_owner())  # ensure it's saved with the scene
				remove_child(child)
				child.queue_free()

func make_resources_local(node: Node):
	for child in node.get_children():
		make_resources_local(child)

	if node is MeshInstance3D:
		if node.mesh and not node.mesh.is_local_to_scene():
			node.mesh = node.mesh.duplicate(true)
		
		if node.mesh:
			for i in node.mesh.get_surface_count():
				var material = node.mesh.surface_get_material(i)
				if material and not material.is_local_to_scene():
					node.mesh.surface_set_material(i, material.duplicate(true))
