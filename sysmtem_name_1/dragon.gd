extends CharacterBody2D


const SPEED = 1000.0
const JUMP_VELOCITY = -400.0

@export var begin_moving_curve: Curve = null
@export_range(0.0, 1.0) var friction: float = 0.92
@export var accel_time: float = 1.0

var target_position: Vector2 = Vector2.ZERO
var begin_during: Vector2 = Vector2.ZERO

var _move_tween: Tween = null

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var curve = func(during: float): return begin_moving_curve.sample(during) if begin_moving_curve else 1.0
	if direction != Vector2.ZERO and _move_tween and _move_tween.is_running():
		_move_tween.kill()
	
	if direction.x != 0:
		var tx : float = clamp(begin_during.x / accel_time, 0.0, 1.0)
		velocity.x = direction.x * SPEED * curve.call(tx)
		begin_during.x += delta
	else:
		begin_during.x = 0.0
		velocity.x *= friction
	if direction.y != 0:
		var tx : float = clamp(begin_during.y / accel_time, 0.0, 1.0)
		velocity.y = direction.y * SPEED * curve.call(tx)
		begin_during.y += delta
	else:
		begin_during.y = 0.0
		velocity.y *= friction
	
	move_and_slide()

func move_to_mouse() -> void:
	velocity = Vector2.ZERO
	begin_during = Vector2.ZERO
	
	var distance: float = global_position.distance_to(target_position)
	var duration: float = distance / SPEED
	
	if _move_tween:
		_move_tween.kill()
	
	_move_tween = create_tween()
	_move_tween.set_trans(Tween.TRANS_CUBIC)      # 三次方过渡，手感自然
	_move_tween.set_ease(Tween.EASE_IN_OUT)       # 开始慢 → 中间快 → 结束慢

	# 4. 将 position 属性从当前值插值到目标值
	_move_tween.tween_property(self, "global_position", target_position, duration)
	

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			target_position = get_global_mouse_position()
			move_to_mouse()
