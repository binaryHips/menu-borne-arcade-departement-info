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
extends RefCounted


const Self: Script = preload("async_reader.gd")


var file_access: FileAccess
var buffer: PackedByteArray
var callback: Callable

var thread: Thread
var mutex: Mutex

var running: bool = false
var finished: bool = false
var should_exit: bool = false


func _init(p_file_access: FileAccess, p_callback: Callable) -> void:
	thread = Thread.new()
	mutex = Mutex.new()
	file_access = p_file_access
	callback = p_callback


func run() -> Error:
	if is_running() or is_finished():
		return ERR_ALREADY_EXISTS
	if should_exit:
		return ERR_CANT_CREATE
	if not is_instance_valid(file_access):
		return ERR_CANT_CREATE
	
	return thread.start(_thread_run)


func is_running() -> bool:
	mutex.lock()
	var result: bool = running
	mutex.unlock()
	return result


func is_finished() -> bool:
	mutex.lock()
	var result: bool = finished
	mutex.unlock()
	return result


func kill() -> void:
	mutex.lock()
	should_exit = true
	mutex.unlock()


func join() -> void:
	thread.wait_to_finish()


func flush() -> void:
	mutex.lock()
	if not buffer.is_empty():
		callback.call_deferred(buffer.get_string_from_utf8())
		buffer.clear()
	mutex.unlock()


func _thread_run() -> void:
	mutex.lock()
	running = true
	mutex.unlock()
	
	while true:
		var buffer_length = file_access.get_length()
		var eof: bool = false
		
		# Read inputs
		for i: int in buffer_length:
			var byte: int = file_access.get_8()
			if byte == 0x00: # Reached the end of the file
				eof = true
				break
			elif byte == 0x0A: # Line feed
				flush()
			else:
				mutex.lock()
				buffer.push_back(byte)
				mutex.unlock()
		
		# Check for if we should exit
		mutex.lock()
		var exit: bool = should_exit
		mutex.unlock()
		
		if exit or eof:
			flush()
			break
		
		if buffer_length == 0: # Wait a bit before checking the contents of the pipe
			OS.delay_msec(2)
	
	mutex.lock()
	running = false
	finished = true
	mutex.unlock()
