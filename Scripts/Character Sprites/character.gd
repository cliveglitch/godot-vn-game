## Pose of a character, must have at least 1 Pose Node as a child
@tool
class_name Character
extends DialogicPortrait

@export var isTalking: = false:
	set(newIsTalking):
		isTalking = newIsTalking
		refresh_talking()
## Must match exactly
@export var currentPoseName: String:
	set(newName):
		currentPoseName = newName
		if poses and poses.has(newName):
			change_pose_by_name(currentPoseName)
## Must match exactly
@export var currentExpressionName: String:
	set(newName):
		currentExpressionName = newName
		if currentPose and currentPose.expressions.has(newName):
			change_expression_by_name(newName)
	
var poses: Dictionary[String, Pose]

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
		if "Text" in Dialogic:
			Dialogic.Text.text_finished.connect(_on_text_finished)
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
	if currentPose and currentPose.currentExpression:
		if isTalking:
			currentPose.currentExpression.mouth.play()
		else:
			currentPose.currentExpression.mouth.stop()
		
func change_pose_by_name(pose_name: String) -> void:
	currentPose = poses[pose_name]
			
func change_expression_by_name(expression_name: String) -> void:
	currentPose.currentExpression = currentPose.expressions[expression_name]
	refresh_talking()

#region: Dialogic2 Override Methods
func _get_covered_rect() -> Rect2:
	return currentPose.currentExpression.get_rect()

func _highlight() -> void:
	isTalking = true
	
func _on_text_finished(_character) -> void:
	isTalking = false
#endregion
