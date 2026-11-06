extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var black_sprite = $Stage/BlackFighter/AnimatedSprite
onready var red_sprite = $Stage/RedFighter/AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Hello world")
	black_sprite.play("idle")
	red_sprite.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
var black_attacking = false;
var red_attacking = false;
# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("p1_strike") and !black_attacking:
		black_attacking=true;
		black_sprite.frame=0
		black_sprite.play("straight_punch")
	if Input.is_action_just_pressed("p2_strike") and !red_attacking:
		red_attacking=true
		red_sprite.frame=0
		red_sprite.play("straight_punch")




func _on_red_AnimatedSprite_animation_finished():
	if red_sprite.animation=="straight_punch":
		red_sprite.play("idle")
		red_attacking=false


func _on_black_AnimatedSprite_animation_finished():
	if black_sprite.animation=="straight_punch":
		black_sprite.play("idle")
		black_attacking=false
