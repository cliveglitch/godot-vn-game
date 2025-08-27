@icon("res://Assets/Icons/command handler.svg")
extends Node
## Manages commands and command groups. 
## Must be direct child of a Console Node.
class_name CommandHandler

## Put the node that has a script with the functions you will use for your commands
@export var node_with_funcions: Node

## Valid commands to use { string : Node }
## Node can be Command or CommandGroup
var commands: Dictionary

func _ready() -> void:
	assert(not node_with_funcions == null, "Command Module needs a Node that contains a script with the functions to run for each command.")
	load_commands(self)

func load_commands(node: Node):
	var console_nodes = node.get_children()
	
	for child in console_nodes:
		var command_namespace: String = child.get_namespace()
		if child is Command:
			if commands.has(command_namespace): 
				push_warning("Command \"{0}\" already exists. Only one command will be saved.".format([command_namespace.replace(".", " ")]))
			commands[command_namespace] = child
		elif child is CommandGroup:
			if commands.has(command_namespace): 
				push_warning("Command \"{0}\" already exists. Only one command will be saved.".format([command_namespace.replace(".", " ")]))
			commands[command_namespace] = child
			load_commands(child)
		else:
			if node is CommandHandler:
				assert(false, "CommandHandler can only have Command or CommandGroup Nodes")
			elif node is CommandGroup:
				assert(false, "CommandGroup can only have Command or CommandGroup Nodes")

func run_command(command: Command, args: Array):
	node_with_funcions.callv(command.function_name, args)

## Finds a Command Node from the console input string.
## The leftover string contains the arguments
func get_command_from_string(input: String):
	var split_input = input.split(" ", false, 1)
	if not split_input.size() > 0:
		return
	
	var command: Command = null
	var command_group: CommandGroup = null
	var command_string: String = split_input[0]
	while command == null:
		if commands.has(command_string):
			if commands[command_string] is Command:
				command = commands[command_string]
			else:
				command_group = commands[command_string]
		
		if not split_input.size() > 1:
			break
		
		if command != null:
			break
			
		var split = split_input[1].split(" ", false, 1)
		split_input = split
			
		command_string += ".{0}".format([split_input[0]])
	
	return {
		"command": command,
		"command_group": command_group,
		"leftover": split_input,
	}

## Gets an array of arguments from a string and returns it
func get_arguments_from_string(input: String) -> Array[String]:
	var input_arguments: Array[String] = []
	
	var split_input_args = input.split(" ", false)
	var quoted_string = null
	
	for word: String in split_input_args:
		if quoted_string != null:
			if word.ends_with("\""):
				input_arguments.append("{0} {1}".format([quoted_string, word.trim_suffix("\"")]))
				quoted_string = null
			else:
				quoted_string += " {0}".format([word])
		elif word.begins_with("\""):
			quoted_string = word.trim_prefix("\"")
		else:
			input_arguments.append(word)
	
	## If the input is one word
	if quoted_string:
		return [quoted_string.trim_suffix("\"")]
	
	return input_arguments

## Parse arguments to be ready when the command function runs.
func parse_arguments(command: Command, input_args: Array[String]):
	var parsed_args: Array = []
	var errors: Array[String] = []
	
	for i in command.arguments.size():
		match command.argument_types[i]:
			command.ArgummentType.INT:
				if input_args[i].is_valid_int():
					parsed_args.append(int(input_args[i]))
				else:
					errors.append("Argument <{0}> must be an INT".format([command.arguments[i]]))
			
			command.ArgummentType.FLOAT:
				if input_args[i].is_valid_float():
					parsed_args.append(float(input_args[i]))
				else:
					errors.append("Argument <{0}> must be a FLOAT".format([command.arguments[i]]))
			
			command.ArgummentType.BOOLEAN:
				if input_args[i].to_lower() == "true" or input_args[i].to_lower() == "false":
					parsed_args.append(input_args[i].to_lower() == "true")
				else:
					errors.append("Argument <{0}> must be a BOOLEAN (true/false)".format([command.arguments[i]]))
			
			_:
				parsed_args.append(input_args[i])
	
	return {
		"args": parsed_args,
		"errors": errors,
	}
