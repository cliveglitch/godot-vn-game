## Pose of a character, must have at least 1 Pose Node as a child
class_name Character
extends Node2D

@export var isTalking: = false:
	set(newIsTalking):
		isTalking = newIsTalking
		refresh_talking()

var poses: Dictionary

var currentPose: Pose:
	set(newPose):
		currentPose = newPose
		refresh_pose()
		currentPose.refresh_expressions()
		refresh_talking()

func _ready() -> void:
	get_poses()
	if poses.size() > 0:
		refresh_pose()
	else:
		push_warning("Character must have at least 1 Pose node.")

func get_poses():
	for child in get_children():
		if child is Pose:
			poses[child.name] = child
			currentPose = child

func refresh_pose() -> void:
	for pose in poses:
		poses[pose].visible = false
	currentPose.visible = true
	
func refresh_talking() -> void:
	if currentPose.currentExpression:
		if isTalking:
			currentPose.currentExpression.mouth.play()
		else:
			currentPose.currentExpression.mouth.stop()
		
func change_pose_by_name(pose_name: String) -> void:
	currentPose = poses[pose_name]
			
func change_expression_by_name(expression_name: String) -> void:
	currentPose.currentExpression = currentPose.expressions[expression_name]
	refresh_talking()
