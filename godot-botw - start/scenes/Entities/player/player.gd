extends CharacterBody3D

@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var skin =$Godette_skin

@export var base_speed = 4.0
@export var run_speed = 10.0
@export var defend_speed := 2.0
var speed_modifier := 1.0
var movement_input =Vector2.ZERO

var defend := false:
	set(value):
		if not defend and value:
			skin.defend(true)
		if defend and not value:
			skin.defend(false)
		defend = value
		
var weapon_active:= false
		

@onready var camera: Camera3D = $CameraController/Camera3D

func _physics_process(delta: float) -> void:
	move_logic(delta)
	jump_logic(delta)
	ability_logic()
	if Input.is_action_just_pressed("get_hit"):
		hit()
	move_and_slide()

func move_logic(delta)-> void:
	movement_input = Input.get_vector("left","right","forward","backward").rotated(-camera.global_rotation.y)
	
	var vel_2d = Vector2(velocity.x,velocity.z)
	var is_running: bool = Input.is_action_pressed("run")
	
	if movement_input != Vector2.ZERO:
		var speed = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed
		
		
		vel_2d += movement_input * speed * delta * 8.0
		vel_2d = vel_2d.limit_length(speed) * speed_modifier
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		skin.set_move_state("Running_C")
		var target_angle = -movement_input.angle() + PI/2
		skin.rotation.y = rotate_toward(skin.rotation.y,target_angle, 6.0 *delta)
				
	else : 
		vel_2d = vel_2d.move_toward(Vector2.ZERO, base_speed * 4.0 * delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		skin.set_move_state("Idle")

	
func jump_logic(delta) -> void :
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_velocity
			do_squash_and_stretch(1.2, 0.15)
			
	else: skin.set_move_state("Jump_Idle")
			
	
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta
	

func ability_logic() -> void: 
	#actual attack
	if Input.is_action_just_pressed("ability"):
		if weapon_active:
			skin.attack()
		else:
			skin.spell_shoot()	
			stop_movement(0.3,0.8)
		
	#defend	
	defend = Input.is_action_pressed("block")
	
	#switch between weapon/magic
	if Input.is_action_just_pressed("switch weapon") and not skin.attacking:
		weapon_active = not weapon_active
		skin.switch_weapon(weapon_active)
		do_squash_and_stretch(1.2, 0.15)
		
		
func stop_movement(start_duration: float, end_duration: float):
	var tween = create_tween()
	tween.tween_property(self,"speed_modifier", 0.0, start_duration)
	tween.tween_property(self,"speed_modifier", 1.0, end_duration)


func hit():
	skin.hit()
	stop_movement(0.3,0.3)

func do_squash_and_stretch(value: float, duration: float = 0.1):
	var tween = create_tween()
	tween.tween_property(skin,"squash_and_stretch", value,duration)
	tween.tween_property(skin,"squash_and_stretch", 1.0, duration * 2.8).set_ease(tween.EASE_OUT)
	
	
