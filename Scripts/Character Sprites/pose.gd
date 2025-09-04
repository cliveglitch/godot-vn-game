## Pose of a character, must have at least 1 PoseExpression Node as a child
## that shows a sprite with an animated mouth
@tool
class_name Pose
extends Node2D

var expressions: Dictionary[String, PoseExpression]
var expressionNames: PackedStringArray = []

var currentExpression: PoseExpression:
	set(newExpression):
		currentExpression = newExpression
		refresh_expressions()

func _ready() -> void:
	if not expressions:
		get_expressions()
	if not expressions.size() > 0:
		push_warning("Pose must have at least 1 Expression node.")

func get_expressions():
	for child in get_children():
		if child is PoseExpression:
			expressions[child.name] = child
			currentExpression = child
			expressionNames.append(child.name)

func refresh_expressions() -> void:
	for expression in expressions:
		expressions[expression].visible = false
	if currentExpression:
		currentExpression.visible = true
