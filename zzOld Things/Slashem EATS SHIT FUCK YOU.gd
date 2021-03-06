extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 15
const SPEED = 150
const ACCELERATION = 30
const KNOCKBACK = 1010
const KNOCKBACKY = -185

var jump = -360
var motion = Vector2()
var damagearr = []

var target_direction = -1
var target_height = 0

onready var losttime = $LostTimer
var dumbvar = 0

onready var SlideTime = $SlideTime
enum STATES {IDLE, WALKING, TAKE_DAMAGE, DEFEATED, SWING, SLIDE, GETUP, DIEALREADY}
export(int) var state = STATES.WALKING
export(float) var max_health = 30

onready var health = max_health setget _set_health

export var Isaw = 0

var notice = 250
var direction = 1
var nextdir = 0
var nextdirtime = 0

export var busy = 0

var playerXdistance
var playerYdistance


func _ready():
	change_state(STATES.WALKING)
	direction = randi()%2 +1

	busy = 0
	ouch = 0
	Isaw = 0

func set_dir(target_direction):
	if nextdir != target_direction:
		nextdir = target_direction
		nextdirtime = OS.get_ticks_msec() + notice

func change_state(new_state):
	state = new_state


func _physics_process(delta):
	print("dumbvar:",dumbvar," Isaw:",Isaw)
	if dumbvar == 1:
		losttime.start()
	if losttime.is_stopped() && dumbvar == 1:
		$AnimationPlayer.play("Holster")
		dumbvar = 0
	if Isaw == 0:
		dumbvar = 0
	
	if direction == 2:
		direction = -1
	SlideTime.start()
	
	
	motion.y += GRAVITY
	var friction = false
	
	motion = move_and_slide(motion, UP)
	for body in damagearr:
		var type = "blue"
		body.take_damage(13, direction, type)

	if health <0:
		change_state(STATES.DEFEATED)

	if direction == 1:
		$Sprite.flip_h = false
		$HoleRay.position.x = 13.672
		$WallRay.position.x = 7.672
		$LedgeRay.position.x = 15.462
		$LedgeRay.rotation_degrees = 65
		$CollisionShape2D.position.x = 1.573
		$SwordArea/SwordCol.position.x = 20

	if direction == -1:
		$Sprite.flip_h = true
		$HoleRay.position.x = -13.672
		$WallRay.position.x = -7.672
		$LedgeRay.position.x = -15.462
		$LedgeRay.rotation_degrees = -65
		$CollisionShape2D.position.x = -1.573
		$SwordArea/SwordCol.position.x = -20



	match state:
		STATES.IDLE:
			unknowing()
		STATES.WALKING:
			slashem()
		STATES.DEFEATED:
			dead()
		STATES.TAKE_DAMAGE:
			pass#take_damage(damage, playerdirection, source, knock, type)
		STATES.SWING:
			Swing()
		STATES.SLIDE:
			Slide()
		STATES.GETUP:
			hurt()
		STATES.DIEALREADY:
			DIEALREADYCOMEON()


func slashem():

	if player.position.x < position.x - 10:
		set_dir(-1)
	elif player.position.x > position.x + 10:
		set_dir(1)
	else:
		set_dir(0)


	if OS.get_ticks_msec() > nextdirtime && Isaw == 1:
		direction = nextdir



	if direction == 0:
		motion.x = 0

	if is_on_floor() && busy == 0 && ouch == 0 && motion.x == 0:
		if Isaw == 1:
			$AnimationPlayer.play("IdleSword")
		elif Isaw == 0:
			$AnimationPlayer.play("Idle")

#	if  motion.y < -360 && !is_on_floor() && busy == 0:
#		$AnimationPlayer.play("JumpStart")

	if  motion.y < -310 && !is_on_floor() && busy == 0:
		$AnimationPlayer.play("Jump")

	if  motion.y > 1 && !is_on_floor() && busy == 0:
		$AnimationPlayer.play("JumpSwitch")

	if motion.y > 145 && !is_on_floor() && busy == 0:
		$AnimationPlayer.play("JumpFall")


		if is_on_floor():
			$AnimationPlayer.play("IdleSword")
			$Land.play



	var playerXdistance = position.x - player.position.x
	var playerYdistance = position.y - player.position.y

	if ouch == 0 && busy == 0:
		if abs(playerXdistance) < 240:
			if abs(playerYdistance) < 140:
				SeeEmCast.cast_to = player.position - position


		if SeeEmCast.is_colliding():# && Isaw == 0:
			var body = SeeEmCast.get_collider()
			if body.is_in_group("player"):
				dumbvar = 0
				direction = sign(player.position.x - position.x)
				if Isaw == 0:
					$AnimationPlayer.play("Draw")
				elif Isaw == 1:
					pass
			elif !body.is_in_group("player"):
				dumbvar = 1
		elif !SeeEmCast.is_colliding():
			if Isaw == 1:
				dumbvar = 1

	if Isaw == 1:

		if abs(playerXdistance) > 295:
			if abs(playerYdistance) > 195:
				$AnimationPlayer.play("Holster")
		
#			if dumbvar == 1:
#			losttime.start()
#		if losttime.is_stopped() && dumbvar == 1:
#			$AnimationPlayer.play("Holster")
#			busy = 1
#			Isaw = 0
		#dumbvar = 0



		var target_direction = sign(player.position.x - position.x)

		if abs(playerXdistance) < 30 && busy == 0 && ouch == 0:
			if abs(playerYdistance) < 10 && busy == 0 && ouch == 0:
				change_state(STATES.SWING)
				SlideTime.start()
				busy = 1

#		if abs(playerXdistance) > 55 && busy == 0 && direction != 0 && ouch == 0 && is_on_floor():
#			if abs(playerYdistance) < 15 && busy == 0 && direction != 0 && ouch == 0 && is_on_floor():
#				if is_on_floor() && SlideTime.is_stopped() && busy == 0:
#					change_state(STATES.SLIDE)
#					busy = 1

		if abs(playerXdistance) < 50 && busy == 0:
			if abs(playerYdistance) > 20 && busy == 0:
				if is_on_floor():
					busy = 1
					SlideTime.start()
					$AnimationPlayer.play("GonnaJump")


		if direction != 0 && ouch == 0 && busy == 0:
			if is_on_floor():
				motion.x = SPEED * direction
				$AnimationPlayer.play("WalkSword")







### # JUMPS # ###

		if is_on_floor() && $HeadRay.is_colliding() == false:# && motion.x != 0
			if $WallRay.is_colliding() == true:# && player.position.y < position.y:
				$AnimationPlayer.play("GonnaJump")

			if $HoleRay.is_colliding() == false && player.position.y < position.y:
				$AnimationPlayer.play("GonnaJump")
			elif player.position.y > position.y:
				pass

			if $LedgeRay.is_colliding() == true && player.position.y < position.y:
				$AnimationPlayer.play("GonnaJump")
		elif $HeadRay.is_colliding() == true:
			pass




onready var player = globalls.player

onready var SeeEmCast = $SeeEmCast

func unknowing():
	if Isaw == 0:
		motion.x = 0
		if is_on_floor():
			$AnimationPlayer.play("Idle")
		elif !is_on_floor():
			$AnimationPlayer.play("JumpFall")
	elif Isaw == 1:
		change_state(STATES.WALKING)


### # MOVEMENT # ###

var amrunningyoufuckingIDIOT = "Leftover, causes errors if not existant. Find where it still exists, and delete it"

func walknowidiot():
	motion.x = SPEED * direction

func stopmovingidiot():
	motion.x = 0

func nyooomm():
	motion.x = (jump * -1) * direction

func amgonnajump():
	motion.y = jump

### # ATTACK STATES # ###

func Swing():
	if is_on_floor():
		$AnimationPlayer.play("Swing")
	elif !is_on_floor():
		$AnimationPlayer.play("AirSwing")

func Slide():
	SlideTime.start()
	busy = 1
	$AnimationPlayer.play("Slide")
	if !is_on_floor():
		change_state(STATES.WALKING)
		busy = 0

### # HEALTHIES # ###

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health :
		if health == 0:
				change_state(STATES.DEFEATED)

export var ouch = 0

func take_damage(damage, playerdirection, source, knock, type):
	#ouch = 1
	busy = 1
	change_state(STATES.TAKE_DAMAGE)

	if health > 0 && ouch != 1:
		_set_health(health - damage)
		if type == "blue":
			ouch = 1
			motion.y = (KNOCKBACKY)
			motion.x = sign((self.position.x - source.position.x)) * knock * 2
			direction = sign((self.position.x - source.position.x)) * -1
			change_state(STATES.GETUP)



		elif type == "red":
			change_state(STATES.TAKE_DAMAGE)
			change_state(STATES.WALKING)
			motion.y = (KNOCKBACKY)
			direction = sign((self.position.x - source.position.x) * -1)



		elif type == "yellow":
			ouch = 0
			change_state(STATES.TAKE_DAMAGE)
			$AnimationPlayer.play("Stomped")
			motion.y = 0
			motion.x = 0
			$HitEmArea/HitEmCol.disabled = true



		else:
			motion.y = (KNOCKBACKY)
			motion.x = sign((self.position.x - source.position.x)) * knock
			direction = sign((self.position.x - source.position.x)) * -1
			change_state(STATES.GETUP)

	if health <= 0:
		#make kaboom here, animation later whatever
		change_state(STATES.DEFEATED)

func hurt():
	change_state(STATES.GETUP)
	SlideTime.start()
	if !is_on_floor():
		$AnimationPlayer.play("Hit2")
	if is_on_floor():
		$AnimationPlayer.play("Hurt")


func stomped():
	change_state(STATES.TAKE_DAMAGE)
	$AnimationPlayer.play("Stomped")
	motion.y = 0
	motion.x = 0
	$HitEmArea/HitEmCol.disabled = true

func dead():
	$AnimationPlayer.play("Bye3")
	motion.x == (direction * KNOCKBACK) * 300
	if is_on_floor():
		change_state(STATES.DIEALREADY)
#		$AnimationPlayer.play("Byed")

func DIEALREADYCOMEON():
	motion.x /= 1.05
	$AnimationPlayer.play("Byed")
	if !is_on_floor():
		$AnimationPlayer.play("ByedAir")
	elif is_on_floor():
		motion.x /= 1.2
#		change_state(STATES.DEFEATED)


### # STINKY AREAS AND EFFECTS # ###

func _on_HitEmArea_body_entered(body):
	if body.is_in_group("player"):
		if !damagearr.has(body):
			damagearr.push_back(body)

func _on_HitEmArea_body_exited(body):
	if body.is_in_group("player"):
		if damagearr.has(body):
			damagearr.erase(body)

func _on_SwordArea_body_entered(body):
	if body.is_in_group("player"):
		if !damagearr.has(body):
			damagearr.push_back(body)

func _on_SwordArea_body_exited(body):
	if body.is_in_group("player"):
		if damagearr.has(body):
			damagearr.erase(body)

const kaboom = preload("res://Entities/Effects/Explod.tscn")
func kaboom():
	var kaboominstance = kaboom.instance()
	kaboominstance.position = (position+Vector2(0,18))
	get_parent().add_child(kaboominstance)

const body = preload("res://Entities/Body.tscn")
func body():
	var bodyinstance = body.instance()
	bodyinstance.position = (position+Vector2(0,15))
	bodyinstance.slashem = true
	bodyinstance.direction = direction
	get_parent().add_child(bodyinstance)
