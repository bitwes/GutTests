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
func test_assert_eq_pass():
	gut.assert_eq(1, 1)

func test_assert_eq_fail():
	gut.assert_eq(1, 2)

func test_assert_true_pass():
	gut.assert_true(true)

func test_assert_true_fail():
	gut.assert_true(false)
