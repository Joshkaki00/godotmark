extends Node
## ThreadedLoader - Manages asynchronous resource loading
## Provides a clean interface for loading multiple resources in background threads

# Dictionary of resources being loaded: path -> status
var _loading_resources = {}
# Dictionary of loaded resources: path -> Resource
var _loaded_resources = {}

func queue_resource(path: String) -> void:
	"""Queue a resource for threaded loading"""
	if not ResourceLoader.exists(path):
		push_error("[ThreadedLoader] Resource does not exist: %s" % path)
		return
	
	if _loading_resources.has(path) or _loaded_resources.has(path):
		# Already queued or loaded
		return
	
	var error = ResourceLoader.load_threaded_request(path)
	if error != OK:
		push_error("[ThreadedLoader] Failed to queue resource: %s (error: %d)" % [path, error])
		return
	
	_loading_resources[path] = {
		"progress": 0.0,
		"status": ResourceLoader.THREAD_LOAD_IN_PROGRESS
	}
	print("[ThreadedLoader] Queued: %s" % path)

func update_progress() -> void:
	"""Update loading progress for all queued resources"""
	var paths_to_remove = []
	
	for path in _loading_resources.keys():
		var progress_array = []
		var status = ResourceLoader.load_threaded_get_status(path, progress_array)
		
		_loading_resources[path]["status"] = status
		_loading_resources[path]["progress"] = progress_array[0] if progress_array.size() > 0 else 0.0
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			# Resource finished loading
			var resource = ResourceLoader.load_threaded_get(path)
			_loaded_resources[path] = resource
			paths_to_remove.append(path)
			print("[ThreadedLoader] Loaded: %s" % path)
		elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("[ThreadedLoader] Failed to load: %s (status: %d)" % [path, status])
			paths_to_remove.append(path)
	
	# Remove completed/failed resources from loading queue
	for path in paths_to_remove:
		_loading_resources.erase(path)

func get_overall_progress() -> float:
	"""Get overall loading progress (0.0 to 1.0)"""
	if _loading_resources.is_empty():
		return 1.0
	
	var total_progress = 0.0
	for resource_data in _loading_resources.values():
		total_progress += resource_data["progress"]
	
	return total_progress / float(_loading_resources.size())

func is_loading_complete() -> bool:
	"""Check if all queued resources have finished loading"""
	return _loading_resources.is_empty()

func get_resource(path: String) -> Resource:
	"""Get a loaded resource by path"""
	if _loaded_resources.has(path):
		return _loaded_resources[path]
	
	push_warning("[ThreadedLoader] Resource not loaded yet: %s" % path)
	return null

func get_loading_count() -> int:
	"""Get number of resources currently loading"""
	return _loading_resources.size()

func get_loaded_count() -> int:
	"""Get number of resources successfully loaded"""
	return _loaded_resources.size()

func clear() -> void:
	"""Clear all loading and loaded resources"""
	_loading_resources.clear()
	_loaded_resources.clear()
	print("[ThreadedLoader] Cleared all resources")

func _exit_tree() -> void:
	"""Cleanup on node exit"""
	clear()
