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
  [[0xf0/0xff.to_f, 0xf8.to_f/0xff.to_f, 1],[0,0,1]],
  [[0x00/0xff.to_f, 0x00.to_f/0xff.to_f, 1],[0,0,1]],
  [[0x00/0xff.to_f, 0x00.to_f/0xff.to_f, 0x8b.to_f/0xff.to_f],[0,0,1]]
]

nn = Brains::Net.create(2, 1, 9, { neurons_per_layer: 4 })
nn.randomize_weights


# test on untrained data
#0000ee
test_data = [
  [0x00/0xff.to_f, 0x00.to_f/0xff.to_f, 0xee.to_f/0xff.to_f],
]

results = test_data.collect { |item|
  nn.feed(item)
}

p results

result = nn.optimize(training_data, 0.01, 1_000 ) { |i, error|
  puts "#{i} #{error}"
}

puts "after training"

results = test_data.collect { |item|
  nn.feed(item)
}

p results
