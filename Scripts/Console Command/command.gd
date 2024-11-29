@icon("res://Assets/Icons/command icon.svg")
extends Node
## Command to be executed. 
## Parent must be of class CommandGroup or CommandHandler
class_name Command

enum ArgummentType {
	STRING,
	BOOLEAN,
	INT,
	FLOAT,
}

@export var command_name: String:
	set(new_name):
		command_name = new_name.to_snake_case()
## Exact name of the function to be executed from the Node's Script that
## you inserted in the CommandHandler Node
@export var function_name: String
@export var description: String
@export var arguments: Array[String]:
	set(new_args):
		var args: Array[String] = []		
		for arg: String in new_args:
			args.append(arg.to_snake_case())
		
		arguments = args
@export var argument_types: Array[ArgummentType]

func _ready() -> void:
	assert(arguments.size() == argument_types.size(), "Array of arguments must be equal in size to array of argumetn types")

## Gets how deep the command is relative to the CommandHandler
## It returns a string that looks like:
## "{Group}.{Group}...{Command}"
## For example: scene.character.move
func get_namespace() -> String:
	var command_namespace_array: PackedStringArray
	var command_namespace: String = ""
	var node = self
	
	while node is not CommandHandler:
		if node is Command:
			command_namespace_array.insert(0, node.command_name)
		elif node is CommandGroup:
			command_namespace_array.insert(0, node.group_name)
		else:
			assert(node is not CommandHandler, "Command is nested incorrectly, a Command node must be descendant of one CommandHandler with the option of only having Command Groups in between")
			break
		node = node.get_parent()
	
	if command_namespace_array.size() > 0:
		command_namespace += "{0}".format([command_namespace_array[0]])
		for idx in command_namespace_array.size() - 1:
			command_namespace += ".{0}".format([command_namespace_array[idx + 1]])
	
	return command_namespace

## Returns a string that describes the command
## Param <level> is used to insert tabs to show how deep is the command
func make_help_string(level: int = 0) -> String:
	var message = ""
	
	for i in level:
		message += "\t"
		
	message += "\t - [i]{0}[/i]".format([self.command_name])
	for i: int in self.arguments.size():
		message += " <{0}, {1}>".format([arguments[i], ArgummentType.keys()[argument_types[i]].to_lower()])
	message += " {0}\n".format([self.description])
	
	return message
