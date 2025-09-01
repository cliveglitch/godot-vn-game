extends Node2D

@onready var console: Console = $ConsoleCanvas/MarginContainer/Console

var select_pose_index_name: Dictionary
var select_expression_index_name: Dictionary

func _ready() -> void:
	Dialogic.start('test')

func change_character_command(character: String, pose: String, expression: String, isTalking: bool):
	var character_node: Character = get_node(character)
	
	if character_node == null:
		console.print_line("Invalid Character.")
		return
	
	character_node.change_pose_by_name(pose)
	character_node.change_expression_by_name(expression)
	character_node.isTalking = isTalking
