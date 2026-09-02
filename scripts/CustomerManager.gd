extends Node2D

@export var customer_scene: PackedScene

# Ліва межа екрана
@export var spawn_position := Vector2(-650, 16)

# Вихід вниз
@export var exit_position := Vector2(-478, 380)

@export var min_spawn_time := 3.0
@export var max_spawn_time := 7.0

var spawn_timer: Timer

var current_customer = null


func _ready():

	randomize()

	add_to_group("customer_manager")

	spawn_timer = Timer.new()

	add_child(spawn_timer)

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	# Перший клієнт одразу
	spawn_customer()


func spawn_customer():

	# Якщо клієнт вже існує — нічого не робимо
	if current_customer != null:
		return

	if customer_scene == null:

		print("ERROR: Customer.tscn is not assigned!")

		return

	var customer = customer_scene.instantiate()

	add_child(customer)

	current_customer = customer

	customer.global_position = spawn_position

	customer.target_position = spawn_position + Vector2(170, 0)

	customer.exit_position = exit_position

	print("NEW CUSTOMER")


func _on_spawn_timer_timeout():

	spawn_timer.stop()

	spawn_customer()


func customer_left(customer):

	if current_customer != customer:
		return

	print("Customer completely left")

	current_customer = null

	# Тільки ТЕПЕР запускаємо очікування
	spawn_timer.wait_time = randf_range(
		min_spawn_time,
		max_spawn_time
	)

	spawn_timer.start()

	print(
		"Next customer in ",
		spawn_timer.wait_time,
		" seconds"
	)
