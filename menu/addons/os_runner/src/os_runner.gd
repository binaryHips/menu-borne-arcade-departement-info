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


const ProgramInstance: Script = preload("program_instance.gd")


func run(p_path: String, p_args: PackedStringArray) -> ProgramHandle:
	var instance: ProgramInstance = ProgramInstance.new()
	instance.program_path = p_path
	instance.arguments = p_args
	add_child(instance)
	
	var handle: ProgramHandle = ProgramHandle.new(instance)
	
	instance.exited.connect(func(_p_exit_code: int) -> void:
		instance.queue_free()
	)
	return handle


func execute_command(p_command: String, p_arguments: PackedStringArray) -> bool:
	var program_handle: ProgramHandle = run(
		p_command, p_arguments
	)
	program_handle.stdout_line_printed.connect(func(p_line: String): print(p_line)) 
	program_handle.stderr_line_printed.connect(func(p_line: String): printerr(p_line))
	
	print_rich("\n=> [b]Running: ", program_handle, "[/b]\n")
	var launch_status: Error = program_handle.launch()
	if launch_status != OK:
		print("Could not launch program: ", program_handle)
		return false
	
	var exit_code: int = await program_handle.exited
	return exit_code == 0
