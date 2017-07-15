extends "res://addons/gut/test.gd"

var Test = load('res://addons/Gut/test.gd')

# Constants so I don't get false pass/fail with misspellings
const SIGNALS = {
	NO_PARAMETERS = 'no_parameters',
	ONE_PARAMETER = 'one_parameter',
	TWO_PARAMETERS = 'two_parameters',
	SOME_SIGNAL = 'some_signal'
}

# ####################
# A class that can emit all the signals in SIGNALS
# ####################
class SignalObject:
	func _init():
		add_user_signal(SIGNALS.NO_PARAMETERS)
		add_user_signal(SIGNALS.ONE_PARAMETER, [
			{'name':'something', 'type':TYPE_INT}
		])
		add_user_signal(SIGNALS.TWO_PARAMETERS, [
			{'name':'num', 'type':TYPE_INT},
			{'name':'letters', 'type':TYPE_STRING}
		])
		add_user_signal(SIGNALS.SOME_SIGNAL)

# GlobalReset(gr) variables to be used by tests.
# The values of these are reset in the setup or
# teardown methods.
var gr = {
	test = null,
    signal_object = null
}

# convinience method to assert the number of failures on the gr.test_gut object.
func assert_fail(count=1, msg=''):
	assert_eq(gr.test.get_fail_count(), count, 'failures:  ' + msg)
	if(gr.test.get_fail_count() != count):
		print_test_gut_info()

# convinience method to assert the number of passes on the gr.test_gut object.
func assert_pass(count=1, msg=''):
	assert_eq(gr.test.get_pass_count(), count, 'passes:  ' + msg)
	if(gr.test.get_pass_count() != count):
		print_test_gut_info()

# #############
# Seutp/Teardown
# #############
func prerun_setup():
	pass

func setup():
	gr.test = Test.new()
	gr.signal_object = SignalObject.new()

func teardown():
	gr.test.free()
	gr.test = null

	gr.signal_object = null

func postrun_teardown():
	pass

# ------------------------------
# Number tests
# ------------------------------
func test_assert_eq_number_not_equal():
	gr.test.assert_eq(1, 2)
	assert_fail(1, "Should fail.  1 != 2")

func test_assert_eq_number_equal():
	gr.test.assert_eq('asdf', 'asdf')
	assert_pass(1, "Should pass")

func test_assert_ne_number_not_equal():
	gr.test.assert_ne(1, 2)
	assert_pass(1, "Should pass, 1 != 2")

func test_assert_ne_number_equal():
	gr.test.assert_ne(1, 1, "Should fail")
	assert_fail(1, '1 = 1')

func test_assert_gt_number_with_gt():
	gr.test.assert_gt(2, 1, "Should Pass")
	assert_pass(1, '2 > 1')

func test_assert_gt_number_with_lt():
	gr.test.assert_gt(1, 2, "Should fail")
	assert_fail(1, '1 < 2')

func test_assert_lt_number_with_lt():
	gr.test.assert_lt(1, 2, "Should Pass")
	assert_pass(1, '1 < 2')

func test_assert_lt_number_with_gt():
	gr.test.assert_lt(2, 1, "Should fail")
	assert_fail(1, '2 > 1')

func test_between_with_number_between():
	gr.test.assert_between(2, 1, 3, "Should pass, 2 between 1 and 3")
	assert_pass(1, "Should pass, 2 between 1 and 3")

func test_between_with_number_lt():
	gr.test.assert_between(0, 1, 3, "Should fail")
	assert_fail(1, '0 not between 1 and 3')

func test_between_with_number_gt():
	gr.test.assert_between(4, 1, 3, "Should fail")
	assert_fail(1, '4 not between 1 and 3')

func test_between_with_number_at_high_end():
	gr.test.assert_between(3, 1, 3, "Should pass")
	assert_pass(1, '3 is between 1 and 3')

func test_between_with_number_at_low_end():
	gr.test.assert_between(1, 1, 3, "Should pass")
	assert_pass(1, '1 between 1 and 3')

func test_between_with_invalid_number_range():
	gr.test.assert_between(4, 8, 0, "Should fail")
	assert_fail(1, '8 is starting number and is not less than 0')

# ------------------------------
# float tests
# ------------------------------
func test_float_eq():
	gr.test.assert_eq(1.0, 1.0)
	assert_pass(1)

func test_float_eq_fail():
	gr.test.assert_eq(.19, 1.9)
	assert_fail(1)

func test_float_ne():
	gr.test.assert_ne(0.9, .009)
	assert_pass(1)

func test_cast_float_eq_pass():
	gr.test.assert_eq(float('0.92'), 0.92)
	assert_pass(1)

func test_fail_compare_float_cast_as_int():
	# int cast will make it 0
	gr.test.assert_eq(int(0.5), 0.5)
	assert_fail(1)

func test_cast_int_math_eq_float():
	var i = 2
	gr.test.assert_eq(5 / float(i), 2.5)
	assert_pass(1)





# ------------------------------
# string tests
# ------------------------------

func test_assert_eq_string_not_equal():
	gr.test.assert_eq("one", "two", "Should Fail")
	assert_fail()

func test_assert_eq_string_equal():
	gr.test.assert_eq("one", "one", "Should Pass")
	assert_pass()

func test_assert_ne_string_not_equal():
	gr.test.assert_ne("one", "two", "Should Pass")
	assert_pass()

func test_assert_ne_string_equal():
	gr.test.assert_ne("one", "one", "Should Fail")
	assert_fail()

func test_assert_gt_string_with_gt():
	gr.test.assert_gt("b", "a", "Should Pass")
	assert_pass()

func test_assert_gt_string_with_lt():
	gr.test.assert_gt("a", "b", "Sould Fail")
	assert_fail()

func test_assert_lt_string_with_lt():
	gr.test.assert_lt("a", "b", "Should Pass")
	assert_pass()

func test_assert_lt_string_with_gt():
	gr.test.assert_lt("b", "a", "Should Fail")
	assert_fail()

func test_between_with_string_between():
	gr.test.assert_between('b', 'a', 'c', "Should pass, 2 between 1 and 3")
	assert_pass()

func test_between_with_string_lt():
	gr.test.assert_between('a', 'b', 'd', "Should fail")
	assert_fail()

func test_between_with_string_gt():
	gr.test.assert_between('z', 'a', 'c', "Should fail")
	assert_fail()

func test_between_with_string_at_high_end():
	gr.test.assert_between('c', 'a', 'c', "Should pass")
	assert_pass()

func test_between_with_string_at_low_end():
	gr.test.assert_between('a', 'a', 'c', "Should pass")
	assert_pass()

func test_between_with_invalid_string_range():
	gr.test.assert_between('q', 'z', 'a', "Should fail")
	assert_fail()
# ------------------------------
# boolean tests
# ------------------------------
func test_assert_true_with_true():
	gr.test.assert_true(true, "Should pass, true is true")
	assert_pass()

func test_assert_true_with_false():
	gr.test.assert_true(false, "Should fail")
	assert_fail()

func test_assert_flase_with_true():
	gr.test.assert_false(true, "Should fail")
	assert_fail()

func test_assert_false_with_false():
	gr.test.assert_false(false, "Should pass")
	assert_pass()

# ------------------------------
# assert_has
# ------------------------------
func test_assert_has_passes_when_array_has_element():
	var array = [0]
	gr.test.assert_has(array, 0, 'It should have zero')
	assert_pass()

func test_assert_has_fails_when_it_does_not_have_element():
	var array = [0]
	gr.test.assert_has(array, 1, 'Should not have it')
	assert_fail()

func test_assert_not_have_passes_when_not_in_there():
	var array = [0, 3, 5]
	gr.test.assert_does_not_have(array, 2, 'Should not have it.')
	assert_pass()

func test_assert_not_have_fails_when_in_there():
	var array = [1, 10, 20]
	gr.test.assert_does_not_have(array, 20, 'Should not have it.')
	assert_fail()

# ------------------------------
# Datatype comparison fail.
# ------------------------------
func test_dt_string_number_eq():
	gr.test.assert_eq('1', 1)
	assert_fail(1)

func test_dt_string_number_ne():
	gr.test.assert_ne('2', 1)
	assert_fail(1)

func test_dt_string_number_assert_gt():
	gr.test.assert_gt('3', 1)
	assert_fail(1)

func test_dt_string_number_func_assert_lt():
	gr.test.assert_lt('1', 3)
	assert_fail(1)

func test_dt_string_number_func_assert_between():
	gr.test.assert_between('a', 5, 6)
	gr.test.assert_between(1, 2, 'c')
	assert_fail(2)

func test_dt_can_compare_to_null():
	gr.test.assert_ne(Node2D.new(), null)
	gr.test.assert_ne(null, Node2D.new())
	assert_pass(2)

# ------------------------------
# Misc tests
# ------------------------------
func test_can_call_eq_without_text():
	gr.test.assert_eq(1, 1)
	assert_pass()

func test_can_call_ne_without_text():
	gr.test.assert_ne(1, 2)
	assert_pass()

func test_can_call_true_without_text():
	gr.test.assert_true(true)
	assert_pass()

func test_can_call_false_without_text():
	gr.test.assert_false(false)
	assert_pass()

func test_script_object_added_to_tree():
	gr.test.assert_ne(get_tree(), null, "The tree should not be null if we are added to it")
	assert_pass()

func test_pending_increments_pending_count():
	gr.test.pending()
	assert_eq(gr.test.get_pending_count(), 1, 'One test should have been marked as pending')

func test_pending_accepts_text():
	pending("This is a pending test.  You should see this text in the results.")






#--------------------------------------
# Classes used to set get/set assert
#--------------------------------------
class NoGetNoSet:
	var _thing = 'nothing'

class HasGetNotSet:
	func get_thing():
		pass

class HasGetAndSetThatDontWork:
	func get_thing():
		pass
	func set_thing(new_thing):
		pass

class HasGetSetThatWorks:
	var _thing = 'something'

	func get_thing():
		return _thing
	func set_thing(new_thing):
		_thing = new_thing
# ------------------------------
# Get/Set Assert
# ------------------------------
func test_fail_if_get_set_not_defined():
	var obj = NoGetNoSet.new()
	gr.test.assert_get_set_methods(obj, 'thing', 'something', 'another thing')
	assert_fail(2)

func test_fail_if_has_get_and_not_set():
	var obj = HasGetNotSet.new()
	gr.test.assert_get_set_methods(obj, 'thing', 'something', 'another thing')
	assert_fail()

func test_fail_if_default_wrong_and_get_dont_work():
	var obj = HasGetAndSetThatDontWork.new()
	gr.test.assert_get_set_methods(obj, 'thing', 'something', 'another thing')
	assert_fail(2)

func test_fail_if_default_wrong():
	var obj = HasGetSetThatWorks.new()
	gr.test.assert_get_set_methods(obj, 'thing', 'not the right default', 'another thing')
	assert_fail()

func test_pass_if_all_get_sets_are_aligned():
	var obj = HasGetSetThatWorks.new()
	gr.test.assert_get_set_methods(obj, 'thing', 'something', 'another thing')
	assert_pass(4)

# ------------------------------
# Signal Asserts
# ------------------------------


func test_when_object_not_being_watched__assert_signal_emitted__fails():
	gr.test.assert_signal_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
	assert_fail()

func test_when_signal_emitted__assert_signal_emitted__passes():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
	gr.test.assert_signal_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
	assert_pass()

func test_when_signal_not_emitted__assert_signal_emitted__fails():
	gr.test.watch_signals(gr.signal_object)
	gr.test.assert_signal_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
	assert_fail()

func test_when_object_does_not_have_signal__assert_signal_emitted__fails():
	gr.test.watch_signals(gr.signal_object)
	gr.test.assert_signal_emitted(gr.signal_object, 'signal_does_not_exist')
	assert_fail(1, 'Only the failure that it does not have signal should fire.')

func test_when_signal_emitted__assert_signal_not_emitted__fails():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
	gr.test.assert_signal_not_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
	assert_fail()

func test_when_signal_not_emitted__assert_signal_not_emitted__fails():
	gr.test.watch_signals(gr.signal_object)
	gr.test.assert_signal_not_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
	assert_pass()

func test_when_object_does_not_have_signal__assert_signal_not_emitted__fails():
	gr.test.watch_signals(gr.signal_object)
	gr.test.assert_signal_not_emitted(gr.signal_object, 'signal_does_not_exist')
	assert_fail(1, 'Only the failure that it does not have signal should fire.')

func test_when_signal_emitted_once__assert_signal_emit_count__passes_with_1():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
	gr.test.assert_signal_emit_count(gr.signal_object, SIGNALS.SOME_SIGNAL, 1)
	assert_pass()

func test_when_signal_emitted_twice__assert_signal_emit_count__fails_with_1():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
	gr.test.assert_signal_emit_count(gr.signal_object, SIGNALS.SOME_SIGNAL, 1)
	assert_fail()

func test_when_object_does_not_have_signal__assert_signal_emit_count__fails():
	gr.test.watch_signals(gr.signal_object)
	gr.test.assert_signal_emit_count(gr.signal_object, 'signal_does_not_exist', 0)
	assert_fail()

func test__assert_has_signal__passes_when_it_has_the_signal():
	gr.test.assert_has_signal(gr.signal_object, SIGNALS.NO_PARAMETERS)
	assert_pass()

func test__assert_has_signal__fails_when_it_does_not_have_the_signal():
	gr.test.assert_has_signal(gr.signal_object, 'signal does not exist')
	assert_fail()

func test_can_get_signal_emit_counts():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
	assert_eq(gr.test.get_signal_emit_count(gr.signal_object, SIGNALS.SOME_SIGNAL), 2)

func test__assert_signal_emitted_with_paramters__fails_when_object_not_watched():
	gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [])
	assert_fail()

func test__assert_signal_emitted_with_parameters__passes_when_paramters_match():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1)
	gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1])
	assert_pass()

func test__assert_signal_emitted_with_parameters__passes_when_all_paramters_match():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1, 2, 3)
	gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1, 2, 3])
	assert_pass()

func test__assert_signal_emitted_with_parameters__fails_when_signal_not_emitted():
	gr.test.watch_signals(gr.signal_object)
	gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [2])
	assert_fail()

func test__assert_signal_emitted_with_parameters__fails_when_paramters_dont_match():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1)
	gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [2])
	assert_fail()

func test__assert_signal_emitted_with_parameters__fails_when_not_all_paramters_match():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1, 2, 3)
	gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1, 0, 3])
	assert_fail()

func test__assert_signal_emitted_with_parameters__can_check_multiple_emission():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 2)
	gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1], 0)
	gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [2], 1)
	assert_pass(2)

func test__get_signal_emit_count__returns_neg_1_when_not_watched():
	assert_eq(gr.test.get_signal_emit_count(gr.signal_object, SIGNALS.SOME_SIGNAL), -1)

func test_can_get_signal_parameters():
	gr.test.watch_signals(gr.signal_object)
	gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1, 2, 3)
	assert_eq(gr.test.get_signal_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, 0), [1, 2, 3])
