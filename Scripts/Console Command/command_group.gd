@icon("res://Assets/Icons/command group icon.svg")
extends Node
## Use this class to categorize Commands.
## Parent must be of class CommandGroup or CommandHandler
class_name CommandGroup

@export var group_name: String:
	set(new_name):
		group_name = new_name.to_snake_case()
@export var description: String

## Returns a string that describes the group and its commands
## Param <level> is used to insert tabs to show how deep is the command group
func make_help_string(level: int = 0) -> String:
	var message := ""
	var children = get_children()
	
	message += "\n"
	
	for i in level:
		message += "\t"
		
	message += "\t[b][i] + {0} [/i][/b]".format([self.group_name])
	message += "{0}\n".format([self.description])
	
	for node in children:
		if node is Command:
			message += node.make_help_string(level + 1)
		elif  node is CommandGroup:
			message += "{0}".format([node.make_help_string(level + 1)])
	
	return message

func get_namespace() -> String:
	var command_namespace_array: PackedStringArray
	var command_namespace: String = ""
	var node = self
	
	while node is not CommandHandler:
		if node is CommandGroup:
			command_namespace_array.insert(0, node.group_name)
		else:
			assert(node is not CommandHandler, "Command is nested incorrectly, a CommandGroup node must be descendant of one CommandHandler with the option of only having Command Groups in between")
			break
		node = node.get_parent()
	
	if command_namespace_array.size() > 0:
		command_namespace += "{0}".format([command_namespace_array[0]])
		for idx in command_namespace_array.size() - 1:
			command_namespace += ".{0}".format([command_namespace_array[idx + 1]])
	
	return command_namespace
