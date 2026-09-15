extends CharacterBody2D


@export var speed := 200.0


# --------------------------------------------------
# ЩО ЗАРАЗ НЕСЕ ГРАВЕЦЬ
# --------------------------------------------------

var carried_bubble = null

# ""
# "drink"
# "ice"
var carried_product := ""

var last_direction := "down"


# --------------------------------------------------
# ВУЗЛИ
# --------------------------------------------------

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bubble_hold_point: Marker2D = $BubbleHoldPoint

@onready var carried_drink: Sprite2D = $CarriedDrink
@onready var carried_ice: Sprite2D = $CarriedIce


func _ready():

	add_to_group("player")

	# Готові продукти на початку приховані
	carried_drink.visible = false
	carried_ice.visible = false

	play_animation("idle_down")


func _physics_process(_delta):

	# --------------------------------------------------
	# РУХ
	# --------------------------------------------------

	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * speed

	move_and_slide()


	# --------------------------------------------------
	# АНІМАЦІЯ РУХУ
	# --------------------------------------------------

	if direction != Vector2.ZERO:

		if abs(direction.x) > abs(direction.y):

			if direction.x < 0:

				last_direction = "left"
				play_animation("walk_left")

			else:

				last_direction = "right"
				play_animation("walk_right")

		else:

			if direction.y < 0:

				last_direction = "up"
				play_animation("walk_up")

			else:

				last_direction = "down"
				play_animation("walk_down")

	else:

		play_animation(
			"idle_" + last_direction
	)


	# --------------------------------------------------
	# ГОТОВИЙ ПРЕДМЕТ СЛІДУЄ ЗА РУКОЮ
	# --------------------------------------------------

	update_carried_product_position()


# ==================================================
# АНІМАЦІЯ
# ==================================================

func play_animation(animation_name: String):

	if animated_sprite.animation != animation_name:

		animated_sprite.play(animation_name)


# ==================================================
# ПОЗИЦІЯ ГОТОВОГО ПРЕДМЕТА
# ==================================================

func update_carried_product_position():

	if carried_product == "drink":

		carried_drink.position = bubble_hold_point.position


	elif carried_product == "ice":

		carried_ice.position = bubble_hold_point.position


# ==================================================
# СТВОРИТИ НАПІЙ АБО ЛІД
# ==================================================

func set_carried_product(product_type: String):

	# --------------------------------------------------
	# Прибираємо стару бульбашку
	# --------------------------------------------------

	if carried_bubble != null:

		carried_bubble.queue_free()
		carried_bubble = null


	# --------------------------------------------------
	# Ховаємо попередній готовий предмет
	# --------------------------------------------------

	carried_drink.visible = false
	carried_ice.visible = false


	# --------------------------------------------------
	# Записуємо новий предмет
	# --------------------------------------------------

	carried_product = product_type


	# --------------------------------------------------
	# Показуємо потрібний
	# --------------------------------------------------

	match product_type:

		"drink":

			carried_drink.visible = true
			carried_drink.position = bubble_hold_point.position


		"ice":

			carried_ice.visible = true
			carried_ice.position = bubble_hold_point.position


		_:

			carried_product = ""


	print(
		"Player now carries: ",
		carried_product
	)


# ==================================================
# ПРИБРАТИ ГОТОВИЙ ПРЕДМЕТ
# ==================================================

func clear_carried_product():

	carried_product = ""

	carried_drink.visible = false
	carried_ice.visible = false
