extends Node2D


@onready var polygon: Polygon2D = $Polygon2D


var radius := 16.0
var point_count := 40

var current_shape := "circle"
var current_color := "blue"


func _ready():
	update_bubble()


func set_order(size_name: String, shape_name: String, color_name: String):

	# Розмір
	match size_name:
		"small":
			radius = 9.0

		"medium":
			radius = 14.0

		"large":
			radius = 19.0

	# Форма
	current_shape = shape_name

	# Колір
	current_color = color_name

	update_bubble()


func update_bubble():

	create_shape()
	update_color()


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

	polygon.polygon = points


func create_circle():

	var points := PackedVector2Array()

	for i in range(point_count):

		var angle = TAU * i / point_count

		var point = Vector2(
			cos(angle),
			sin(angle)
		) * radius

		points.append(point)

	set_shape(points)


func create_star():

	var points := PackedVector2Array()

	var outer_radius = radius
	var inner_radius = radius * 0.45

	for i in range(10):

		var angle = -PI / 2.0 + TAU * i / 10.0

		var current_radius = (
			outer_radius
			if i % 2 == 0
			else inner_radius
		)

		var point = Vector2(
			cos(angle),
			sin(angle)
		) * current_radius

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


func update_color():

	match current_color:

		"blue":
			polygon.color = Color("#4FC3F7")

		"green":
			polygon.color = Color("#66BB6A")

		"yellow":
			polygon.color = Color("#FDD835")

		"red":
			polygon.color = Color("#EF5350")
