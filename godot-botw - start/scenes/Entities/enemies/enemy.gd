class_name Enemy

extends CharacterBody3D
@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_animation = $AnimationTree.get_tree_root().get_node("AttackAnimation")

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var skin = get_node("skin")

@export var walk_speed := 3.0
@export var notice_radius := 30.0
@export var attack_radius := 3.0

var rng = RandomNumberGenerator.new()

func move_to_player(delta):
	if position.distance_to(player.position) < notice_radius:
		var target_dir = (player.position - position).normalized()
		var target_vector2D = Vector2(target_dir.x, target_dir.z)
		var target_angle = -target_vector2D.angle() + PI/2
		rotation.y =rotate_toward(rotation.y,target_angle, delta * 6.0)
		
		if position.distance_to(player.position) > attack_radius:
		#velocity determines how quick the enemy will chase player
			velocity = Vector3(target_vector2D.x,0,target_vector2D.y) * walk_speed
			move_state_machine.travel("walk")
		else:
			velocity = Vector3.ZERO
			move_state_machine.travel("idle")
		
		move_and_slide()
	
