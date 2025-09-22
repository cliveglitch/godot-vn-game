## Pose of a character, must have at least 1 Pose Node as a child
@tool
class_name Character
extends DialogicPortrait

@export var isTalking := false:
	set(newIsTalking):
		isTalking = newIsTalking
		refresh_talking()

@export var dialogic_name: String = ""

var currentPoseName: String:
	set(newName):
		currentPoseName = newName
		if not poses:
			get_poses()
		if poses.has(newName):
			change_pose_by_name(currentPoseName)
			notify_property_list_changed()
var currentExpressionName: String:
	set(newName):
		currentExpressionName = newName
		if not currentPose:
			return
		if not currentPose.expressions:
			currentPose.get_expressions()
		if currentPose.expressions.has(newName):
			change_expression_by_name(newName)
	
var poses: Dictionary[String, Pose]
var poseNames: PackedStringArray = []

var currentPose: Pose:
	set(newPose):
		currentPose = newPose
		refresh_pose()
		currentPose.refresh_expressions()
		refresh_talking()
		if currentPose and currentPose.currentExpression:
			currentExpressionName = currentPose.currentExpression.name

func _ready() -> void:
	if not poses:
		get_poses()
	if poses.size() > 0:
		if currentPose:
			currentPoseName = currentPose.name
		refresh_pose()
		if poses.has(currentPoseName):
			change_pose_by_name(currentPoseName)
		if currentPose.expressions.has(currentExpressionName):
			change_expression_by_name(currentExpressionName)
		if "Text" in Dialogic:
			Dialogic.Text.text_started.connect(_on_text_start)
			Dialogic.Text.text_finished.connect(_on_text_finished)
	else:
		push_warning("Character must have at least 1 Pose node.")

func _get_property_list() -> Array:
	var propsList: Array = []

	propsList.append({
		"name": "currentPoseName",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(Array(poseNames))
	})
	@warning_ignore("incompatible_ternary")
	var localCurrentExpressions = currentPose.expressionNames if currentPose != null else []
	
	propsList.append({
		"name": "currentExpressionName",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(Array(localCurrentExpressions))
	})
	return propsList

func get_poses():
	for child in get_children():
		if child is Pose:
			poses[child.name] = child
			currentPose = child
			poseNames.append(child.name)

func refresh_pose() -> void:
	for pose in poses:
		poses[pose].visible = false
	currentPose.visible = true
	
func refresh_talking() -> void:
	if currentPose and currentPose.currentExpression:
		if not currentPose.currentExpression.mouth:
			currentPose.currentExpression.get_mouth()
		if isTalking:
			currentPose.currentExpression.mouth.play()
		else:
			currentPose.currentExpression.mouth.stop()
		
func change_pose_by_name(pose_name: String) -> void:
	currentPose = poses[pose_name]
			
func change_expression_by_name(expression_name: String) -> void:
	if not currentPose.expressions.has(expression_name):
		return
	currentPose.currentExpression = currentPose.expressions[expression_name]
	refresh_talking()

#region: Dialogic2 Override Methods
func _get_covered_rect() -> Rect2:
	return Rect2(Vector2(0, -1150), Vector2(1200, 1150) * currentPose.scale)

func _on_text_start(_data) -> void:
	# Dialogic2 character name must match the Node name
	var character_who_will_talk = Dialogic.Text.get_character_name_parsed(_data.character)
	var isCharacterText = character_who_will_talk.to_upper() == dialogic_name.to_upper()
	isTalking = isCharacterText
	
func _on_text_finished(_character) -> void:
	isTalking = false
#endregion
