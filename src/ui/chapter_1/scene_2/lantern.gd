extends PointLight2D

# How fast the fire flickers
@export var flicker_speed: float = 25.0

# The lowest and highest brightness of the light
@export var min_energy: float = 1.2
@export var max_energy: float = 2.0 

# The smallest and largest size of the light circle
@export var min_scale: float = 0.9
@export var max_scale: float = 1.1

var noise: FastNoiseLite 
var time_passed: float = 0.0

func _ready():
	# Create the noise generator that will give us smooth random numbers
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	# Give it a random starting seed so every lantern looks a bit different
	noise.seed = randi()

func _process(delta: float):
	# Move forward in time
	time_passed += delta * flicker_speed
	
	# Get a smooth random number between -1.0 and 1.0 based on time
	var sampled_noise = noise.get_noise_1d(time_passed)
	
	# Convert that -1 to 1 range into a 0 to 1 percentage
	var flicker_percentage = (sampled_noise + 1.0) / 2.0
	
	# Apply the random percentage to our light's energy and scale!
	energy = lerp(min_energy, max_energy, flicker_percentage)
	texture_scale = lerp(min_scale, max_scale, flicker_percentage)
