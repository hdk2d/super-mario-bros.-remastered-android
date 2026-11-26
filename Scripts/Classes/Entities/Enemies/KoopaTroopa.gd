extends Enemy

const MOVE_SPEED := 32
@export var winged := false
@export_file("*.tscn") var shell_scene = ""

@onready var starting_position := global_position

var fly_wave := PI

var dead := false

var times_kicked := 0 ## For anti-infinite scoring in Challenge mode

func _ready() -> void:
	if has_meta("fly_2"):
		fly_wave = 0
	if winged:
		if has_meta("is_red") or has_meta("fly_2"):
			play_animation("Fly")
		else:
			play_animation("Hop")

func _physics_process(delta: float) -> void:
	if winged and (has_meta("is_red") or has_meta("fly_2")):
		handle_fly_movement(delta)
	else:
		$BasicEnemyMovement.bounce_on_land = winged
		if winged:
			if is_on_floor():
				play_animation("Hop")
		else:
			play_animation("Walk")
		$BasicEnemyMovement.handle_movement(delta)
	%Wing.visible = winged
	$Sprite.scale.x = direction

func handle_fly_movement(delta: float) -> void:
	velocity = Vector2.ZERO
	fly_wave += delta
	var old_x = global_position.x
	play_animation("Fly")
	if has_meta("fly_2"):
		global_position.x = starting_position.x + (cos(fly_wave) * 48) - 48
		global_position.y = starting_position.y + (sin(fly_wave * 4) * 2)
		direction = sign(global_position.x - old_x + 0.001)
	else:
		global_position.y = starting_position.y + (cos(fly_wave) * 48) + 48

func play_animation(animation_name := "") -> void:
	if $Sprite.sprite_frames.has_animation(animation_name):
		if $Sprite.animation != animation_name:
			$Sprite.play(animation_name)
	elif $Sprite.animation != "Walk":
		$Sprite.play("Walk")

func stomped_on(player: Player) -> void:
	if dead:
		return
	player.enemy_bounce_off()
	AudioManager.play_sfx("enemy_stomp", global_position)
	if winged:
		DiscoLevel.combo_meter = 100
		DiscoLevel.combo_amount += 1
		velocity.y = 0
		winged = false
		var direction_to_change = sign(player.global_position.x - global_position.x)
		if direction_to_change != 0:
			direction = direction_to_change
		return
	dead = true
	await get_tree().physics_frame
	summon_shell(not is_on_floor(), false)
	queue_free()

func block_bounced() -> void:
	summon_shell(true, true)
	queue_free()

func summon_shell(flipped := false, launch := false) -> void:
	if is_queued_for_deletion():
		return
	DiscoLevel.combo_amount += 1
	var shell = load(shell_scene).instantiate()
	shell.flipped = flipped
	shell.times_kicked = times_kicked
	shell.old_entity = self.duplicate()
	shell.direction = direction
	var source_setter = $Sprite.get_node_or_null("ResourceSetterNew")
	var target_setter = shell.get_node_or_null("Sprite/ResourceSetterNew")
	if source_setter != null and target_setter != null:
		for meta_name in source_setter.get_meta_list():
			target_setter.set_meta(meta_name, source_setter.get_meta(meta_name))
	if launch:
		AudioManager.play_sfx("kick", global_position)
		shell.can_air_kick = true
		shell.velocity = Vector2(50 * direction, -150)
	shell.global_position = global_position
	if $TrackJoint.is_attached:
		get_parent().owner.add_sibling(shell)
	else:
		add_sibling(shell)
