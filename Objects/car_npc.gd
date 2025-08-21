extends RigidBody3D

@onready var shape:ShapeCast3D = $CarShapeCast3D
@onready var explosion:AnimatedSprite3D = $AnimatedRealisticExplosion

func _process(delta: float) -> void:
	var collision_count:int = shape.get_collision_count()
	for i in collision_count:
		var collider:CharacterBody3D = shape.get_collider(i) as CharacterBody3D
		
		var collision_point = shape.get_collision_point(i)
		self.apply_impulse(collision_point.direction_to(position))
		self.apply_torque_impulse(shape.get_collision_normal(i))
		
		explosion.animation_finished.connect(func(): explosion.hide())
		explosion.show()
		explosion.play()
	
	
