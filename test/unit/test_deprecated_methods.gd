extends "res://addons/gut/test.gd"

var Gut = load('res://addons/Gut/gut.gd')

var _pass_count = 0
# Returns a new gut object, all setup for testing.
func get_a_gut():
	var g = Gut.new()
	g.set_yield_between_tests(false)
	g.set_log_level(g.LOG_LEVEL_ALL_ASSERTS)
	add_child(g)
	return g

# #############
# Seutp/Teardown
# #############
func prerun_setup():
	pass

func setup():
	pass

func teardown():
	pass

func postrun_teardown():
	pass

# #############
# Tests
# #############
func test_pending():
	pending()

func _assert_pass():
	pass
#
# # # see gut method
# func test_assert_eq(got, expected, text=""):
# 	gut.assert_eq(got, expected, text)
#

# # see gut method
# func test_assert_ne(got, not_expected, text=""):
# 	gut.assert_ne(got, not_expected, text)
#
# # see gut method
# func test_assert_gt(got, expected, text=""):
# 	gut.assert_gt(got, expected, text)
#
# # see gut method
# func test_assert_lt(got, expected, text=""):
# 	gut.assert_lt(got, expected, text)
#
# # see gut method
# func test_assert_true(got, text=""):
# 	gut.assert_true(got, text)
#
# # see gut method
# func test_assert_false(got, text=""):
# 	gut.assert_false(got, text)
#
# # see gut method
# func test_assert_between(got, expect_low, expect_high, text=""):
# 	gut.assert_between(got, expect_low, expect_high, text)
#
# # see gut method
# func test_assert_file_exists(file_path):
# 	gut.assert_file_exists(file_path)
#
# # see gut method
# func test_assert_file_does_not_exist(file_path):
# 	gut.assert_file_does_not_exist(file_path)
#
# # see gut method
# func test_assert_file_empty(file_path):
# 	gut.assert_file_empty(file_path)
#
# # see gut method
# func test_assert_file_not_empty(file_path):
# 	gut.assert_file_not_empty(file_path)
#
# # see gut method
# func test_assert_get_set_methods(obj, property, default, set_to):
# 	gut.assert_get_set_methods(obj, property, default, set_to)
#
# func test_assert_has(obj, element, text=""):
# 	gut.assert_has(obj, element, text)
#
# func test_assert_does_not_have(obj, element, text=""):
# 	gut.assert_does_not_have(obj, element, text)
#
# func watch_signals(object):
# 	gut.watch_signals(object)
#
# func test_assert_signal_emitted(object, signal_name, text=""):
# 	gut.assert_signal_emitted(object, signal_name, text)
#
# func test_assert_signal_emitted_with_parameters(object, signal_name, parameters, index=-1):
# 	gut.assert_signal_emitted_with_parameters(object, signal_name, parameters, index)
#
# func test_assert_signal_not_emitted(object, signal_name, text=""):
# 	gut.assert_signal_not_emitted(object, signal_name, text)
#
# func test_assert_signal_emit_count(object, signal_name, times, text=""):
# 	gut.assert_signal_emit_count(object, signal_name, times, text)
#
# func test_assert_has_signal(object, signal_name, text=""):
# 	gut.assert_has_signal(object, signal_name, text)
#
# func get_signal_parameters(object, signal_name, index=-1):
# 	return gut.get_signal_parameters(object, signal_name, index)
# #-------------------------------------------------------------------------------
# # Returns the number of times a signal was emitted.  -1 returned if the object
# # is not being watched.
# #-------------------------------------------------------------------------------
# func get_signal_emit_count(object, signal_name):
# 	return gut.get_signal_emit_count(object, signal_name)
#
# # see gut method
# func pending(text=""):
# 	gut.pending(text)
#
# # I think this reads better than set_yield_time, but don't want to break anything
# func yield_for(time, msg=''):
# 	return gut.set_yield_time(time, msg)
#
# func end_test():
# 	gut.end_yielded_test()
