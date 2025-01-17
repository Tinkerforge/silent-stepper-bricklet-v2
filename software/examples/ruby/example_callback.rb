#!/usr/bin/env ruby
# -*- ruby encoding: utf-8 -*-

require 'tinkerforge/ip_connection'
require 'tinkerforge/bricklet_silent_stepper_v2'

include Tinkerforge

HOST = 'localhost'
PORT = 4223
UID = 'XYZ' # Change XYZ to the UID of your Silent Stepper Bricklet 2.0

ipcon = IPConnection.new # Create IP connection
ss = BrickletSilentStepperV2.new UID, ipcon # Create device object

ipcon.connect HOST, PORT # Connect to brickd
# Don't use device before ipcon is connected

# Use position reached callback to program random movement
ss.register_callback(BrickletSilentStepperV2::CALLBACK_POSITION_REACHED) do |position|
  if rand(1) == 0
    steps = 1000 + rand(4000) # steps (forward)
    puts "Driving forward: #{steps} steps"
  else
    steps = rand(4000) - 5000 # steps (backward)
    puts "Driving backward: #{steps} steps"
  end

  vel = 200 + rand(1800) # steps/s
  acc = 100 + rand(900) # steps/s^2
  dec = 100 + rand(900) # steps/s^2
  puts "Configuration (vel, acc, dec): #{vel}, #{acc}, #{dec}"

  ss.set_speed_ramping acc, dec
  ss.set_max_velocity vel
  ss.set_steps steps
end

ss.set_step_configuration BrickletSilentStepperV2::STEP_RESOLUTION_8, \
                          true # 1/8 steps (interpolated)
ss.set_enabled true # Enable motor power
ss.set_steps 1 # Drive one step forward to get things going

puts 'Press key to exit'
$stdin.gets

# Stop motor before disabling motor power
ss.stop # Request motor stop
ss.set_speed_ramping 500, 5000 # Fast deacceleration (5000 steps/s^2) for stopping
sleep 0.4 # Wait for motor to actually stop: max velocity (2000 steps/s) / decceleration (5000 steps/s^2) = 0.4 s
ss.set_enabled false # Disable motor power

ipcon.disconnect
