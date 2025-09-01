## Expression of a character, must have one AnimatedSprite2D Node as a child
## that animates the mouth.
@tool
class_name PoseExpression
extends Sprite2D

var mouth: AnimatedSprite2D

func _ready() -> void:
	get_mouth()
	if not self.texture:
		push_warning("Expression must have a texture")

func get_mouth():
	for node: Node in get_children():
		if node is AnimatedSprite2D:
			mouth = node
			break
			
	if not mouth:
		push_warning("Expression must have at least 1 AnimatedSprite2D Node.")
