extends Node

@export var console: Console

func _ready() -> void:
	if console == null:
		push_error("Command Handler must have a Console Node.")

func echo_command(text: String):
	console.write_line("{0}".format([text]))

func clear_command():
	console.clear()

func help_command():
	console.write_help_string()

func test_command(text: String, x: int, y: float):
	print(text)
	print(x)
	print(y)
