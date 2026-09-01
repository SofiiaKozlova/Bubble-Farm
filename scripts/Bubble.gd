extends Area2D

@onready var polygon2d: Polygon2D = $Polygon2D
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

@export var radius: float = 20.0
@export var point_count: int = 40

var player_near := false
var carried := false
var current_shape := "circle"


func _ready():
	create_shape()


func create_shape():
	match current_shape:
		"circle":
			create_circle()

		"star":
			create_star()

		"heart":
			create_heart()

		"diamond":
			create_diamond()


func set_shape(points: PackedVector2Array):
	polygon2d.polygon = points
	collision.polygon = points


func create_circle():
	var points := PackedVector2Array()

	for i in range(point_count):
		var angle = TAU * i / point_count
		var point = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)

	set_shape(points)


func create_star():
	var points := PackedVector2Array()

	var outer_radius = radius
	var inner_radius = radius * 0.45

	for i in range(10):
		var angle = -PI / 2.0 + TAU * i / 10.0
		var current_radius = outer_radius if i % 2 == 0 else inner_radius

		var point = Vector2(cos(angle), sin(angle)) * current_radius
		points.append(point)

	set_shape(points)


func create_diamond():
	var points := PackedVector2Array()

	points.append(Vector2(0, -radius))
	points.append(Vector2(radius, 0))
	points.append(Vector2(0, radius))
	points.append(Vector2(-radius, 0))

	set_shape(points)


func create_heart():
	var points := PackedVector2Array()

	for i in range(30):
		var t = TAU * i / 30.0

		var x = 16.0 * pow(sin(t), 3)
		var y = -(
			13.0 * cos(t)
			- 5.0 * cos(2.0 * t)
			- 2.0 * cos(3.0 * t)
			- cos(4.0 * t)
		)

		var point = Vector2(x, y) * (radius / 17.0)
		points.append(point)

	set_shape(points)


func change_shape(shape: String):
	# Змінюємо тільки форму
	# radius залишається тим самим
	current_shape = shape
	create_shape()


func change_color(new_color: Color):
	# Змінюємо колір вже існуючої бульбашки
	polygon2d.color = new_color


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false


func pick_up():
	print("Trying to pick up")

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player not found")
		return

	if player.carried_bubble != null:
		print("Player already has bubble")
		return

	print("Bubble picked")

	player.carried_bubble = self
	carried = true

	reparent(player)
	position = player.get_node("BubbleHoldPoint").position


func _process(_delta):
	if carried:
		var player = get_tree().get_first_node_in_group("player")

		if player:
			position = player.get_node("BubbleHoldPoint").position

		return

	if player_near and Input.is_action_just_pressed("interact"):
		pick_up()
