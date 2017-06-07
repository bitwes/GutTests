extends "res://addons/gut/test.gd"

var SignalWatcher = load('res://addons/Gut/signal_watcher.gd')
var gr = {
	so = null,
	sw = null
}

class SignalObject:
	# ####################
	# Constants so I don't get false pass/fail with misspellings
	# ####################
	const SIGNALS = {
		NO_PARAMETERS = 'no_parameters',
		ONE_PARAMETER = 'one_parameter',
		TWO_PARAMETERS = 'two_parameters'
	}
	func _init():
		add_user_signal(SIGNALS.NO_PARAMETERS)
		add_user_signal(SIGNALS.ONE_PARAMETER, [10])
		add_user_signal(SIGNALS.TWO_PARAMETERS, [1, 'WORD'])

func setup():
	gr.sw = SignalWatcher.new()
	gr.so = SignalObject.new()

func teardown():
	gr.sw = null
	gr.so = null

func test_print_signals():
	gr.sw.print_signals(gr.so)

func test_when_signal_emitted_the_signal_count_is_incremented():
	gr.sw.watch_signal(gr.so, gr.so.SIGNALS.NO_PARAMETERS)
	gr.so.emit_signal(gr.so.SIGNALS.NO_PARAMETERS)
	assert_eq(gr.sw.get_emit_count(gr.so, gr.so.SIGNALS.NO_PARAMETERS), 1, 'The signal should have been counted.')

func test_when_signal_emitted_assert_emitted_passes():
	gr.sw.watch_signal(gr.so, gr.so.SIGNALS.NO_PARAMETERS)
	gr.so.emit_signal(gr.so.SIGNALS.NO_PARAMETERS)
	assert_true(gr.sw.did_emit(gr.so, gr.so.SIGNALS.NO_PARAMETERS), 'The signal should have been emitted')

func test_no_engine_errors_when_signal_does_not_exist():
	gut.p('!! Look for Red !!')
	gr.sw.watch_signal(gr.so, 'some_signal_that_does_not_exist')

func test_when_signal_emitted_with_parameters_it_is_counted():
	gr.sw.watch_signal(gr.so, gr.so.SIGNALS.NO_PARAMETERS)
	gr.so.emit_signal(gr.so.SIGNALS.NO_PARAMETERS, 'word')
	assert_eq(gr.sw.get_emit_count(gr.so, gr.so.SIGNALS.NO_PARAMETERS), 1, 'The signal should have been counted.')
