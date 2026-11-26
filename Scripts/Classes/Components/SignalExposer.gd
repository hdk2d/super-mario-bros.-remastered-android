class_name SignalExposer
extends Node2D

# Android runtime signal bridge; desktop editor wire rendering is not required.
signal signal_connected
signal pulse_emitted
signal powered_on
signal powered_off
signal recieved_pulse
signal recieved_power
signal lost_power

@export var can_input := true
@export var can_output := true
var total_inputs := 0
var turned_on := false

func turn_on() -> void:
	if can_output:
		turned_on = true
		powered_on.emit()

func turn_off() -> void:
	if can_output:
		turned_on = false
		powered_off.emit()

func emit_pulse() -> void:
	if can_output:
		pulse_emitted.emit()

func on_recieve_power() -> void:
	if can_input:
		recieved_power.emit()

func on_recieve_pulse() -> void:
	if can_input:
		recieved_pulse.emit()

func on_lost_power() -> void:
	if can_input:
		lost_power.emit()
