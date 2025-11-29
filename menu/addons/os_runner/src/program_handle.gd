# ------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                     #
#                                                                                                                     #
#                                                /\                    ^__                                            #
#                                               /#*\  /\              /##@>                                           #
#                                              <#* *> \/         _^_  \\    _^_                                       #
#                                               \##/            /###\ \è\  /###\                                      #
#                                                \/ /\         /#####n/xx\n#####\                                     #
#                   Ferdinand                       \/         \###^##xXXx##^###/                                     #
#                        Souchet                                \#/ V¨\xx/¨V \#/                                      #
#                     (aka. @Khusheete)                          V     \c\    V                                       #
#                                                                       //                                            #
#                                                                     \o/                                             #
#                                                                      v                                              #
#                                                                                                                     #
#                                                                                                                     #
#                                                                                                                     #
#                                                                                                                     #
# Copyright 2025 Ferdinand Souchet (aka. @Khusheete)                                                                  #
#                                                                                                                     #
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated        #
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation the #
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to     #
# permit persons to whom the Software is furnished to do so, subject to the following conditions:                     #
#                                                                                                                     #
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of    #
# the Software.                                                                                                       #
#                                                                                                                     #
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO    #
# THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE      #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, #
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE      #
# SOFTWARE.                                                                                                           #
#                                                                                                                     #
# ------------------------------------------------------------------------------------------------------------------- #


@tool
class_name ProgramHandle
extends RefCounted


signal stdout_line_printed(p_line: String)
signal stderr_line_printed(p_line: String)
signal exited(p_code: int)


const ProgramInstance: Script = preload("program_instance.gd")


var instance: ProgramInstance

var program_path: String
var arguments: PackedStringArray

var exit_code: int = -1


func _init(p_instance: ProgramInstance) -> void:
	instance = p_instance
	
	if is_instance_valid(instance):
		instance.stdout_line_printed.connect(stdout_line_printed.emit)
		instance.stderr_line_printed.connect(stderr_line_printed.emit)
		instance.exited.connect(exited.emit)
		
		instance.exited.connect(func(p_exit_code: int) -> void:
			exit_code = p_exit_code
		)
		
		program_path = instance.program_path
		arguments = instance.arguments


func send(p_buffer: PackedByteArray) -> void:
	if not is_running():
		return
	instance.send(p_buffer)


func send_string(p_string: String) -> void:
	if not is_running():
		return
	instance.send_string(p_string)


func launch() -> Error:
	if is_instance_valid(instance):
		return instance.run()
	else:
		return ERR_INVALID_DATA


func kill() -> void:
	if is_instance_valid(instance) and is_instance_of(instance, ProgramInstance):
		instance.kill()
		instance.join()
		instance.queue_free()


func is_running() -> bool:
	return is_instance_valid(instance) and instance.is_running()


func get_exit_code() -> int:
	return exit_code


func _notification(p_what: int) -> void:
	match p_what:
		NOTIFICATION_PREDELETE:
			if is_instance_valid(self):
				kill()


func _to_string() -> String:
	return str(
		program_path, " ",
		" ".join(arguments)
	)
