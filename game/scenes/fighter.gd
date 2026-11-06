extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite=$Visuals/AnimatedSprite

var attacking = false
export(String) var strike_action = ""
export(String) var left_action = ""
export(String) var right_action = ""
export(String) var up_action = ""
export(NodePath) var opponent_path


var velocity = Vector2.ZERO
var gravity = 3000.0
var move_speed = 300.0
var jump_speed = 1100.0

onready var opponent = get_node(opponent_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	print("READY!", strike_action)
	pass # Replace with function body.



func _physics_process(delta):
	velocity.y+=gravity*delta
	if Input.is_action_just_pressed(strike_action) and !attacking:
		attacking=true
		sprite.play("straight_punch")
	if is_on_floor() and Input.is_action_just_pressed(up_action) and !attacking:
		velocity.y=-jump_speed

	var direction = Input.get_action_strength(right_action)-Input.get_action_strength(left_action)
	velocity.x=direction*move_speed
	velocity=move_and_slide(velocity,Vector2.UP)
	if !attacking:
		if !is_on_floor():
			if velocity.y<0:
				sprite.play("jump_ascent")
			else:
				sprite.play("fall_descent")
		else:
			if direction:
				sprite.play("step_walk")
			if direction == 0:
				sprite.play("idle")
		var on_left = opponent.global_position.x<global_position.x
		if on_left:
			sprite.flip_h=true
		else:
			sprite.flip_h=false
	
	


func _on_AnimatedSprite_animation_finished():
	if sprite.animation=="straight_punch":
		attacking=false
		sprite.play("idle")
