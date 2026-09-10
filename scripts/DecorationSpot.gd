extends Node2D


const PRICE := 30

var player_near := false
var purchased := false


@onready var point: Sprite2D = $Point
@onready var flowers: Sprite2D = $Flowers
@onready var coin: Sprite2D = $Coin
@onready var price_label: Label = $Label

@onready var interaction_area: Area2D = $InteractionArea
@onready var flower_barrier: StaticBody2D = $FlowerBarrier


func _ready():

	# Квіти спочатку приховані
	flowers.visible = false

	# Ціна
	price_label.text = str(PRICE)

	# -------------------------
	# РОЗТАШУВАННЯ ЦІНИ І МОНЕТКИ
	# -------------------------

	# Цифра зліва
	price_label.position = Vector2(-45, -12)
	price_label.size = Vector2(60, 24)

	# Вирівнюємо число вправо
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Монетка завжди в одному місці
	coin.position = Vector2(25, 0)


	# -------------------------
	# КВІТИ
	# -------------------------

	flowers.visible = false


	# -------------------------
	# БАР'ЄР
	# -------------------------

	# Спочатку бар'єр вимкнений
	flower_barrier.visible = false

	flower_barrier.set_collision_layer_value(1, false)
	flower_barrier.set_collision_mask_value(1, false)


	# -------------------------
	# INTERACTION AREA
	# -------------------------

	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)


func _process(_delta):

	if player_near and not purchased:

		if Input.is_action_just_pressed("interact"):
			buy_decoration()


func buy_decoration():

	if purchased:
		return


	# -------------------------
	# ЗАБИРАЄМО 30 ЄВРО
	# -------------------------

	GameManager.money -= PRICE

	print("Decoration purchased!")
	print("Money: ", GameManager.money)


	# Позначаємо як куплене
	purchased = true


	# -------------------------
	# ХОВАЄМО ЦІНУ
	# -------------------------

	point.visible = false
	coin.visible = false
	price_label.visible = false


	# -------------------------
	# ПОКАЗУЄМО КВІТИ
	# -------------------------

	flowers.visible = true


	# -------------------------
	# ВМИКАЄМО БАР'ЄР
	# -------------------------

	flower_barrier.visible = true

	flower_barrier.set_collision_layer_value(1, true)
	flower_barrier.set_collision_mask_value(1, true)


func _on_interaction_area_body_entered(body):

	if body.is_in_group("player"):

		player_near = true

		print("Player near decoration")


func _on_interaction_area_body_exited(body):

	if body.is_in_group("player"):

		player_near = false

		print("Player left decoration")
