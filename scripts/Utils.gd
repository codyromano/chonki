extends Node

# Simple throttle function that discards excessive requests
func throttle(request_id: String, callable_to_run: Callable, delay: float = 0.3) -> void:
	# Check if we're still in cooldown period
	if has_meta(request_id):
		return  # Discard this request
	
	# Execute immediately
	callable_to_run.call()
	
	# Set cooldown flag
	set_meta(request_id, true)
	
	# Create timer to clear cooldown
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = delay
	timer.one_shot = true
	timer.timeout.connect(func(): 
		remove_meta(request_id)
		timer.queue_free()
	, CONNECT_ONE_SHOT)
	timer.start()
