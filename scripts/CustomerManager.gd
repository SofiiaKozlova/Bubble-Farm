extends Node2D

@export var customer_scene: PackedScene

@export var spawn_position := Vector2(0, -100)
@export var counter_position := Vector2(-695, 325)
@export var exit_position := Vector2(700, 300)

@export var min_spawn_time := 3.0
@export var max_spawn_time := 7.0

var spawn_timer: Timer


func _ready():
	randomize()

	spawn_timer = Timer.new()
	add_child(spawn_timer)

	spawn_timer.timeout.connect(spawn_customer)

	spawn_customer()
	set_next_spawn_time()


func set_next_spawn_time():
	spawn_timer.wait_time = randf_range(
		min_spawn_time,
		max_spawn_time
	)

	spawn_timer.start()


func spawn_customer():
	if customer_scene == null:
		print("ERROR: Customer.tscn is not assigned!")
		return

	var customer = customer_scene.instantiate()

	add_child(customer)

	customer.global_position = spawn_position
	customer.target_position = counter_position
	customer.exit_position = exit_position

	set_next_spawn_time()
