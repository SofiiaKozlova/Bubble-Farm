extends Node2D

const GAP := 20.0

@onready var money_label: Label = $MoneyLabel
@onready var coin: Sprite2D = $Coin


func _ready():

	money_label.text = str(GameManager.money)

	# Вирівнюємо цифри по правому краю
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Область Label
	money_label.size = Vector2(80, 24)

	# Чорні цифри
	money_label.add_theme_color_override(
		"font_color",
		Color.BLACK
	)

	# Розмір самих цифр
	money_label.add_theme_font_size_override(
		"font_size",
		25
	)

	update_money_position()


func _process(_delta):

	money_label.text = str(GameManager.money)

	update_money_position()


func update_money_position():

	# Правий край Label на 20 px лівіше від Coin
	money_label.position.x = (
		coin.position.x
		- GAP
		- money_label.size.x
	)
	money_label.position.y = -20
