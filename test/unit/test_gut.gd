extends "res://addons/gut/test.gd"

var Gut = load('res://addons/Gut/gut.gd')
var Test = load('res://addons/Gut/test.gd')

#--------------------------------------
#Used to test calling the _process method
#on an object through gut
#--------------------------------------
class HasProcessMethod:
	extends Node
	var process_called_count = 0
	var delta_sum = 0.0

	func _process(delta):
		process_called_count += 1
		delta_sum += delta

#--------------------------------------
#Used to test calling the _fixed_process
#method on an object through gut
#--------------------------------------
class HasFixedProcessMethod:
	extends Node
	var fixed_process_called_count = 0
	var delta_sum = 0.0

	func _fixed_process(delta):
		fixed_process_called_count += 1
		delta_sum += delta

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

#------------------------------
# Utility methods/variables
#------------------------------
var counts = {
	setup_count = 0,
	teardown_count = 0,
	prerun_setup_count = 0,
	postrun_teardown_count = 0,
}

# GlobalReset(gr) variables to be used by tests.
# The values of these are reset in the setup or
# teardown methods.
var gr = {
	test_gut = null,
	test_finished_called = false,
	signal_object = null,
	test = null
}

func callback_for_test_finished():
	gr.test_finished_called = true

# Returns a new gut object, all setup for testing.
func get_a_gut():
	var g = Gut.new()
	g.set_yield_between_tests(false)
	g.set_log_level(g.LOG_LEVEL_ALL_ASSERTS)
	add_child(g)
	return g

# Prints out gr.test_gut assert results, used by assert_fail and assert_pass
func print_test_gut_info():
	var text_array = gr.test_gut._log_text.split("\n")
	gut.p('Results of gr.test_gut asserts')
	gut.p('------------------------------')
	for i in range(text_array.size()):
		gut.p(text_array[i])

# convinience method to assert the number of failures on the gr.test_gut object.
func assert_fail(count=1, msg=''):
	assert_eq(gr.test_gut.get_fail_count(), count, 'failures:  ' + msg)
	if(gr.test_gut.get_fail_count() != count):
		print_test_gut_info()

# convinience method to assert the number of passes on the gr.test_gut object.
func assert_pass(count=1, msg=''):
	assert_eq(gr.test_gut.get_pass_count(), count, 'passes:  ' + msg)
	if(gr.test_gut.get_pass_count() != count):
		print_test_gut_info()

# ------------------------------
# Setup/Teardown
# ------------------------------
func setup():
	counts.setup_count += 1
	gr.test_finished_called = false
	gr.test_gut = get_a_gut()
	gr.signal_object = SignalObject.new()
	gr.test = Test.new()
	gr.test.gut = gr.test_gut

func teardown():
	counts.teardown_count += 1
	gr.test_gut.queue_free()

func prerun_setup():
	counts.prerun_setup_count += 1

func postrun_teardown():
	counts.postrun_teardown_count += 1
	#can't verify that this ran, so do an assert.
	#Asserts in any of the setup/teardown methods
	#is a bad idea in general.
	assert_true(true, 'POSTTEARDOWN RAN')
	gut.directory_delete_files('user://')

# ------------------------------
# Settings
# ------------------------------
func test_get_set_ingore_pauses():
	assert_get_set_methods(gr.test_gut, 'ignore_pause_before_teardown', false, true)

func test_when_ignore_pauses_set_it_checks_checkbox():
	gr.test_gut.set_ignore_pause_before_teardown(true)
	assert_true(gr.test_gut._ctrls.ignore_continue_checkbox.is_pressed())

func test_when_ignore_pauses_unset_it_unchecks_checkbox():
	gr.test_gut.set_ignore_pause_before_teardown(true)
	gr.test_gut.set_ignore_pause_before_teardown(false)
	assert_false(gr.test_gut._ctrls.ignore_continue_checkbox.is_pressed())

# ------------------------------
#Number tests
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
# disable strict datatype comparisons
# ------------------------------
func test_when_strict_enabled_you_can_compare_int_and_float():
	gr.test.assert_eq(1.0, 1)
	assert_pass()

func test_when_strict_disabled_can_compare_int_and_float():
	gr.test_gut.disable_strict_datatype_checks(true)
	gr.test.assert_eq(1.0, 1)
	assert_pass()


# ------------------------------
# File asserts
# ------------------------------
func test__assert_file_exists__with_file_dne():
	gr.test.assert_file_exists('user://file_dne.txt')
	assert_fail()

func test__assert_file_exists__with_file_exists():
	var path = 'user://gut_test_file.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	gr.test.assert_file_exists(path)
	assert_pass()

func test__assert_file_dne__with_file_dne():
	gr.test.assert_file_does_not_exist('user://file_dne.txt')
	assert_pass()

func test__assert_file_dne__with_file_exists():
	var path = 'user://gut_test_file2.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	gr.test.assert_file_does_not_exist(path)
	assert_fail()

func test__assert_file_empty__with_empty_file():
	var path = 'user://gut_test_empty.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	gr.test.assert_file_empty(path)
	assert_pass()

func test__assert_file_empty__with_not_empty_file():
	var path = 'user://gut_test_empty2.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.store_8(1)
	f.close()
	gr.test.assert_file_empty(path)
	assert_fail()

func test__assert_file_empty__fails_when_file_dne():
	var path = 'user://file_dne.txt'
	gr.test.assert_file_empty(path)
	assert_fail()

func test__assert_file_not_empty__with_empty_file():
	var path = 'user://gut_test_empty3.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	gr.test.assert_file_not_empty(path)
	assert_fail()

func test__assert_file_not_empty__with_populated_file():
	var path = 'user://gut_test_empty4.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.store_8(1)
	f.close()
	gr.test.assert_file_not_empty(path)
	assert_pass()

func test__assert_file_not_empty__fails_when_file_dne():
	var path = 'user://file_dne.txt'
	gr.test.assert_file_not_empty(path)
	assert_fail()

# ------------------------------
# File utilities
# ------------------------------
func test_file_touch_creates_file():
	var path = 'user://gut_test_touch.txt'
	gut.file_touch(path)
	gr.test.assert_file_exists(path)
	assert_pass()


func test_file_delete_kills_file():
	var path = 'user://gut_test_file_delete.txt'
	gr.test_gut.file_touch(path)
	gr.test_gut.file_delete(path)
	gr.test.assert_file_does_not_exist(path)
	assert_pass()

func test_delete_all_files_in_a_directory():
	var path = 'user://gut_dir_tests'
	var d = Directory.new()
	d.open('user://')
	str(d.make_dir('gut_dir_tests'))

	gr.test_gut.file_touch(path + '/helloworld.txt')
	gr.test_gut.file_touch(path + '/file2.txt')
	gr.test_gut.directory_delete_files(path)
	gr.test.assert_file_does_not_exist(path + '/helloworld.txt')
	gr.test.assert_file_does_not_exist(path + '/file2.txt')

	assert_pass(2, 'both files should not exist')

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
	gr.test.assert_ne(HasFixedProcessMethod.new(), null)
	gr.test.assert_ne(null, HasFixedProcessMethod.new())
	assert_pass(2)

# ------------------------------
#Misc tests
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
	assert_eq(gr.test_gut.get_pending_count(), 1, 'One test should have been marked as pending')

func test_pending_accepts_text():
	pending("This is a pending test.  You should see this text in the results.")

func test_simulate_calls_process():
	var obj = HasProcessMethod.new()
	gr.test_gut.simulate(obj, 10, .1)
	gr.test.assert_eq(obj.process_called_count, 10, "_process should have been called 10 times")
	#using just the numbers didn't work, nor using float.  str worked for some reason and
	#i'm not sure why.
	gr.test.assert_eq(str(obj.delta_sum), str(1), "The delta value should have been passed in and summed")
	assert_pass(2)

func test_simulate_calls_process_on_child_objects():
	var parent = HasProcessMethod.new()
	var child = HasProcessMethod.new()
	parent.add_child(child)
	gr.test_gut.simulate(parent, 10, .1)
	gr.test.assert_eq(child.process_called_count, 10, "_process should have been called on the child object too")
	assert_pass()

func test_simulate_calls_process_on_child_objects_of_child_objects():
	var objs = []
	for i in range(5):
		objs.append(HasProcessMethod.new())
		if(i > 0):
			objs[i - 1].add_child(objs[i])
	gr.test_gut.simulate(objs[0], 10, .1)

	for i in range(objs.size()):
		gr.test.assert_eq(objs[i].process_called_count, 10, "_process should have been called on object # " + str(i))

	assert_pass(objs.size())

func test_simulate_calls_fixed_process():
	var obj = HasFixedProcessMethod.new()
	gr.test_gut.simulate(obj, 10, .1)
	gr.test.assert_eq(obj.fixed_process_called_count, 10, "_process should have been called 10 times")
	#using just the numbers didn't work, nor using float.  str worked for some reason and
	#i'm not sure why.
	gr.test.assert_eq(str(obj.delta_sum), str(1), "The delta value should have been passed in and summed")
	assert_pass(2)
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
# Setting test to run
# ------------------------------
func test_get_set_test_to_run():
	gr.test.assert_get_set_methods(gr.test_gut, 'unit_test_name', '', 'hello')
	assert_pass(4)

func test_setting_name_will_run_only_matching_tests():
	gr.test_gut.add_script('res://test/samples/test_sample_all_passed.gd')
	gr.test_gut.set_unit_test_name('test_works')
	gr.test_gut.test_scripts()
	assert_eq(gr.test_gut.get_test_count(), 1)

func test_setting_name_matches_partial():
	gr.test_gut.add_script('res://test/unit/test_sample_all_passed.gd')
	gr.test_gut.set_unit_test_name('two')
	gr.test_gut.test_scripts()
	assert_eq(gr.test_gut.get_test_count(), 1)

# These should all pass, just making sure there aren't any syntax errors.
func test_asserts_on_test_object():
	pending('This really is not pending')
	assert_eq(1, 1, 'text')
	assert_ne(1, 2, 'text')
	assert_gt(10, 5, 'text')
	assert_lt(1, 2, 'text')
	assert_true(true, 'text')
	assert_false(false, 'text')
	assert_between(5, 1, 10, 'text')
	assert_file_does_not_exist('res://doesnotexist')

	var path = 'user://gut_test_file.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	assert_file_exists(path)


	var path = 'user://gut_test_empty.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	assert_file_empty(path)

	var path = 'user://gut_test_not_empty3.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.store_8(1)
	f.close()
	assert_file_not_empty(path)

	var obj = HasGetSetThatWorks.new()
	assert_get_set_methods(obj, 'thing', 'something', 'another thing')

# ------------------------------
# Loading diretories
# ------------------------------
func test_adding_directory_loads_files():
	gr.test_gut.add_directory('res://test_dir_load')
	assert_has(gr.test_gut._test_scripts, 'res://test_dir_load/test_samples.gd')

func test_adding_directory_does_not_load_bad_prefixed_files():
	gr.test_gut.add_directory('res://test_dir_load')
	assert_does_not_have(gr.test_gut._test_scripts, 'res://test_dir_load/bad_prefix.gd')

func test_adding_directory_skips_files_with_wrong_extension():
	gr.test_gut.add_directory('res://test_dir_load')
	assert_does_not_have(gr.test_gut._test_scripts, 'res://test_dir_load/test_bad_extension.txt')

func test_if_directory_does_not_exist_it_does_not_die():
	gr.test_gut.add_directory('res://adsf')
	assert_true(true, 'We should get here')

func test_adding_same_directory_does_not_add_duplicates():
	gr.test_gut.add_directory('res://test/unit')
	var orig = gr.test_gut._test_scripts.size()
	gr.test_gut.add_directory('res://test/unit')
	assert_eq(gr.test_gut._test_scripts.size(), orig)

# We only have 3 directories with tests in them so test 3
func test_directories123_defined_in_editor_are_loaded_on_ready():
	var g = Gut.new()
	var t = Test.new()
	t.gut = g
	g.set_yield_between_tests(false)
	g._directory1 = 'res://test_dir_load'
	g._directory2 = 'res://test/unit'
	g._directory3 = 'res://test/integration'
	add_child(g)
	t.assert_has(g._test_scripts, 'res://test_dir_load/test_samples.gd', 'Should have dir1 script')
	t.assert_has(g._test_scripts, 'res://test/unit/test_gut.gd', 'Should have dir2 script')
	t.assert_has(g._test_scripts, 'res://test/integration/test_sample_all_passed_integration.gd', 'Should have dir3 script')
	assert_eq(g.get_pass_count(), 3, 'they should have passed')

# ^ aaaand then we test 2 more.
func test_directories456_defined_in_editor_are_loaded_on_ready():
	var g = Gut.new()
	var t = Test.new()
	t.gut = g
	g.set_yield_between_tests(false)
	g._directory4 = 'res://test_dir_load'
	g._directory5 = 'res://test/unit'
	g._directory6 = 'res://test/integration'
	add_child(g)
	t.assert_has(g._test_scripts, 'res://test_dir_load/test_samples.gd', 'Should have dir4 script')
	t.assert_has(g._test_scripts, 'res://test/unit/test_gut.gd', 'Should have dir5 script')
	t.assert_has(g._test_scripts, 'res://test/integration/test_sample_all_passed_integration.gd', 'Should have dir6 script')
	assert_eq(g.get_pass_count(), 3, 'they should have passed')


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

func test_when_moving_to_next_test_watched_signals_are_cleared():
	gr.test_gut.add_script('res://test/unit/verify_signal_watches_are_cleared.gd')
	gr.test_gut.test_scripts()
	assert_eq(gr.test_gut.get_pass_count(), 1, 'One test should have passed.')
	assert_eq(gr.test_gut.get_fail_count(), 1, 'One test should have failed.')

#-------------------------------------------------------------------------------
#
#
# This must be LAST test
#
#
#-------------------------------------------------------------------------------
func test_verify_results():
	gut.p("/*THESE SHOULD ALL PASS, IF NOT THEN SOMETHING IS BROKEN*/")
	gut.p("/*These counts will be off if another script was run before this one.*/")
	assert_eq(1, counts.prerun_setup_count, "Prerun setup should have been called once")
	assert_eq(gut.get_test_count(), counts.setup_count, "Setup should have been called once for each test")
	# teardown for this test hasn't been run yet.
	assert_eq(gut.get_test_count() -1, counts.teardown_count, "Teardown should have been called one less time.")
