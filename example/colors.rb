#!/usr/bin/env ruby

require 'brains'

#This neural network will identify the main color name based on rgb values

label_encodings = {
  "Red"   => [1, 0, 0],
  "Green" => [0, 1, 0],
  "Blue"  => [0, 0 ,1]
}
#0000ff
training_data = [
  # blue
  [[0xf0/0xff.to_f, 0xf8.to_f/0xff.to_f, 1],[0,0,1]],
  [[0x00/0xff.to_f, 0x00.to_f/0xff.to_f, 1],[0,0,1]],
  [[0x00/0xff.to_f, 0x00.to_f/0xff.to_f, 0x8b.to_f/0xff.to_f],[0,0,1]],

  #green
  [[0x8f/0xff.to_f, 0x97.to_f/0xff.to_f, 0x79.to_f/0xff.to_f],[0,1,0]],
  [[0x56/0xff.to_f, 0x82.to_f/0xff.to_f, 0x03.to_f/0xff.to_f],[0,1,0]],
  [[0x1/0xff.to_f, 0x32.to_f/0xff.to_f, 0x20.to_f/0xff.to_f],[0,1,0]],

  #red 	#CE2029 	#DA2C43	#DA2C43
  [[0xce/0xff.to_f, 0x20.to_f/0xff.to_f, 0x29.to_f/0xff.to_f],[1,0,0]],
  [[0xda/0xff.to_f, 0x20.to_f/0xff.to_f, 0x43.to_f/0xff.to_f],[1,0,0]],
  [[0x99/0xff.to_f, 0x00.to_f/0xff.to_f, 0x00.to_f/0xff.to_f],[1,0,0]],
]

nn = Brains::Net.create(3, 3, 2, { neurons_per_layer: 5 })

# randomize weights before training
nn.randomize_weights


# test on untrained data
#0000ee 	#C41E3A
test_data = [
  [0x00/0xff.to_f, 0x00.to_f/0xff.to_f, 0xee.to_f/0xff.to_f], #blue
  [0xc4/0xff.to_f, 0x1e.to_f/0xff.to_f, 0x3a.to_f/0xff.to_f], #red
]

results = test_data.collect { |item|
  nn.feed(item)
}

p results

result = nn.optimize(training_data, 0.01, 1_000_000 ) { |i, error|
  puts "#{i} #{error}"
}

puts "after training"

results = test_data.collect { |item|
  nn.feed(item)
}

p results
