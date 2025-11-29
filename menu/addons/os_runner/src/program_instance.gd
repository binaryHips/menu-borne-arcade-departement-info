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
extends Node


const AsyncReader: Script = preload("async_reader.gd")


signal stdout_line_printed(p_line: String)
signal stderr_line_printed(p_line: String)
signal exited(p_code: int)


var program_path: String
var arguments: PackedStringArray

var pid: int

var stdio: FileAccess
var stdout_reader: AsyncReader

var stderr: FileAccess
var stderr_reader: AsyncReader


func _init() -> void:
	set_process(false)
	set_process_input(false)
	set_process_internal(false)
	set_process_shortcut_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	set_physics_process(false)
	set_physics_process_internal(false)


func run() -> Error:
	if is_running():
		return ERR_ALREADY_IN_USE
	
	if program_path.is_empty():
		return ERR_FILE_BAD_PATH
	
	var pipes: Dictionary = OS.execute_with_pipe(program_path, arguments)
	
	if pipes.is_empty():
		return ERR_CANT_CREATE
	
	pid = pipes[&"pid"]
	set_process(true)
	
	stdio = pipes[&"stdio"]
	stdout_reader = AsyncReader.new(stdio, stdout_line_printed.emit)
	stdout_reader.run()
	
	stderr = pipes[&"stderr"]
	stderr_reader = AsyncReader.new(stderr, stderr_line_printed.emit)
	stderr_reader.run()
	
	return OK


func _process(_p_delta: float) -> void:
	if not is_running():
		var exit_code: int = OS.get_process_exit_code(pid)
		join()
		set_process(false)
		exited.emit(exit_code)


func send(p_buffer: PackedByteArray) -> void:
	if not is_running():
		return
	stdio.store_buffer(p_buffer)


func send_string(p_string: String) -> void:
	if not is_running():
		return
	stdio.store_string(p_string)


func is_running() -> bool:
	return OS.is_process_running(pid)


func kill() -> void:
	if is_running():
		OS.kill(pid)
	if is_instance_valid(stdout_reader) and stdout_reader.is_running():
		stdout_reader.kill()
	if is_instance_valid(stderr_reader) and stderr_reader.is_running():
		stderr_reader.kill()


func join() -> void:
	if is_instance_valid(stdout_reader):
		stdout_reader.join()
	if is_instance_valid(stderr_reader):
		stderr_reader.join()
