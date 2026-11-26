class_name Hammer
extends Projectile

var can_rotate := true

func _ready() -> void:
	velocity.y = -200
	if can_rotate:
		$Animations.play("Rotate")
	if Settings.file.audio.extra_sfx == 1:
		AudioManager.play_sfx("hammer_throw", global_position)

func _physics_process(delta: float) -> void:
	$Sprite.flip_h = direction == 1
	$Animations.speed_scale = -direction
	handle_movement(delta)
