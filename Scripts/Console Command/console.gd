@icon("res://Assets/Icons/command console icon.svg")
extends PanelContainer
class_name Console

@onready var input_bar: LineEdit = $VBoxContainer/InputBar
@onready var display: RichTextLabel = $VBoxContainer/Display

var command_handlers: Array[Node]
var history = CommandHistoryQueue.new()
var commands_trie: Trie

func _ready() -> void:
	command_handlers = get_children().filter(
		func(node: Node):
			return node is CommandHandler
	)
	input_bar.keep_editing_on_text_submit = true
	input_bar.caret_force_displayed = true
	
	_fill_command_trie()

func _fill_command_trie():
	commands_trie = Trie.new()
	commands_trie.separator_character = "."
	
	for node: Node in command_handlers:
		if not node is CommandHandler:
			continue
		
		for command_namespace in node.commands:
			commands_trie.insert_word(command_namespace)

func _on_command_submitted(input: String) -> void:
	write_line("> " + input)
	var command: Command
	var command_group: CommandGroup
	
	for node: Node in command_handlers:
		if not node is CommandHandler:
			continue
		var command_handler = node as CommandHandler
		
		var command_leftover = command_handler.get_command_from_string(input)
		if not command_leftover:
			return
			
		command = command_leftover["command"]
		var leftover: PackedStringArray = command_leftover["leftover"] 
		
		if command_leftover["command_group"]:
			command_group = command_leftover["command_group"]
		
		if not command:
			continue
		
		var input_args: Array[String] = []
		if leftover.size() > 1:
			input_args = command_handler.get_arguments_from_string(leftover[1])
		
		var args_size = command.arguments.size()
		if not input_args.size() >= command.arguments.size():
			write(command.make_help_string())
			write_line("\t\tCommand \"{0}\" needs {1} argument{2}.\n".format([command.command_name, args_size, "s" if args_size > 1 else "" ]))
			break
		
		input_args.resize(command.arguments.size())
		var result = command_handler.parse_arguments(command, input_args)
		var errors: Array[String] = result["errors"]
		var parsed_args: Array = result["args"]
		
		if errors.size() > 0:
			write(command.make_help_string())
			for error: String in errors:
				write_line("\t\t{0}".format([error]))
			break
		
		command_handler.run_command(command, parsed_args)
		break
	
	if not command and not command_group:
		write_line("Command not found, use [i]help[/i] to check all the available commands.\n")
	elif not command and command_group:
		write_line("Command not found from group named [i]{0}[/i]. {1}".format([command_group.group_name, command_group.make_help_string()]))
		
	history.push(input)
	input_bar.clear()
	input_bar.call_deferred("grab_focus")

func _input(event: InputEvent) -> void:
	input_bar.caret_blink = false
	input_bar.call_deferred("grab_focus")
	
	# Toggle Console
	if event.is_action_pressed("open_console"):
		self.visible = !self.visible
		input_bar.grab_focus()
	elif event.is_action_released("ui_up"):
		input_bar.text = history.next()
		input_bar.caret_column = input_bar.text.length()
	elif event.is_action_released("ui_down"):
		input_bar.text = history.prev()
		input_bar.caret_column = input_bar.text.length()
	elif event.is_action_released("ui_text_completion_replace"):
		var next_command = autocomplete_command(input_bar.text)
		if next_command:
			input_bar.text = next_command
			input_bar.caret_column = input_bar.text.length()
	elif visible and event is not InputEventKey:
		get_viewport().set_input_as_handled()
	
	input_bar.caret_blink = true

func autocomplete_command(command: String):
	var namespace_command = command.replace(" ", ".")
	var autocompleted_command = commands_trie.get_word_with_unique_prefix(namespace_command)
	
	if autocompleted_command:
		autocompleted_command = autocompleted_command.replace(".", " ")
	
	return autocompleted_command

## Write a new line into the display with
func write_line(text: String):
	display.append_text("{0}\n".format([text]))

## Write into the display
func write(text: String):
	display.append_text("{0}".format([text]))

## Clears the display
func clear():
	display.clear()

## Write a string into the display that describes all of the avaliable commands
func write_help_string():
	var message := "[b]List of commands: [/b]\n"
	for command_handler in command_handlers:
		if not command_handler is CommandHandler:
			continue
			
		for node: Node in command_handler.get_children():
			if node is Command:
				message += node.make_help_string(0)
			elif node is CommandGroup:
				message += node.make_help_string(0)
					
	write_line(message)

## Inner Class that manages the console history queue.
class CommandHistoryQueue:
	const HISTORY_LIMIT = 100
	
	var history_queue: Array[String]
	var selected: int = -1
	
	## Push the string to the queue.
	func push(command: String):
		selected = -1
		history_queue.push_front(command)
		
		if history_queue.size() > HISTORY_LIMIT:
			history_queue.pop_back()
	
	## Get the next command from the queue, if there are no commands returns current.
	func next():
		selected = min(selected + 1, history_queue.size() - 1)
		if selected == -1:
			return ""
		return history_queue[selected]
	
	## Get the prev command from the queue, if there are no commands returns an empty string.
	func prev():
		selected = max(selected - 1, -1)
		if selected == -1:
			return ""
		return history_queue[selected]
