extends ColorRect


@export var ramp : Gradient
@export_range(0.0, 1.0) var step : float = 0.5:
	set(value):
		step = value / 150

var t : float = 0.0


func _process(_delta):
	color = ramp.sample(t)
	t += step
	if t >= 1.0: t = 0
