extends Node2D


@export var price := 10

var remaining_price := 0
var player_near := false
var purchased := false


@onready var point: Sprite2D = $Point
@onready var flowers: Sprite2D = $Flowers
@onready var coin: Sprite2D = $Coin
@onready var price_label: Label = $Label

@onready var interaction_area: Area2D = $InteractionArea
@onready var flower_barrier: StaticBody2D = $FlowerBarrier


func _ready():

	# Початкова сума, яку треба заплатити
	remaining_price = price

	# Квіти приховані
	flowers.visible = false

	# Показуємо, скільки ще треба заплатити
	price_label.text = str(remaining_price)

	# Напис
	price_label.position = Vector2(-55, -12)
	price_label.size = Vector2(60, 24)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Монетку НЕ рухаємо.
	# Вона залишається там, де ти поставила її в сцені.


	# Бар'єр спочатку вимкнений
	flower_barrier.visible = false

	flower_barrier.set_collision_layer_value(1, false)
	flower_barrier.set_collision_mask_value(1, false)


	# InteractionArea
	interaction_area.body_entered.connect(
		_on_interaction_area_body_entered
	)

	interaction_area.body_exited.connect(
		_on_interaction_area_body_exited
	)


func _process(_delta):

	if player_near and not purchased:

		if Input.is_action_just_pressed("interact"):
			buy_decoration()


func buy_decoration():

	if purchased:
		return


	# Якщо грошей немає
	if GameManager.money <= 0:
		print("No money to pay")
		return


	# Скільки можемо заплатити зараз
	var payment = min(
		GameManager.money,
		remaining_price
	)


	# Віднімаємо гроші у гравця
	GameManager.money -= payment

	# Зменшуємо залишок ціни
	remaining_price -= payment


	print("Paid: ", payment)
	print("Money left: ", GameManager.money)
	print("Remaining price: ", remaining_price)


	# Оновлюємо напис
	price_label.text = str(remaining_price)


	# Якщо все оплачено
	if remaining_price <= 0:

		remaining_price = 0

		purchased = true

		print("Decoration fully paid!")


		# Ховаємо покупку
		point.visible = false
		coin.visible = false
		price_label.visible = false


		# Показуємо квіти
		flowers.visible = true


		# Вмикаємо бар'єр
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
