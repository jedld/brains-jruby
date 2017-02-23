#!/usr/bin/env ruby

require 'brains'


# Build a 3 layer network: 4 input neurons, 4 hidden neurons, 3 output neurons
# Bias neurons are automatically added to input + hidden layers; no need to specify these
# 5 = 4 in one hidden layer + 1 output neuron (input neurons not counted)

nn = Brains::Net.create(2, 1, 5, { neurons_per_layer: 4 })
nn.randomize_weights

# A    B   A XOR B
# 1    1      0
# 1    0      1
# 0    1      1
# 0    0      0

training_data = [
  [[0.9, 0.9], [0.1]],
  [[0.9, 0.1], [0.9]],
  [[0.1, 0.9], [0.9]],
  [[0.1, 0.1], [0.1]],
]

# test on untrained data
test_data = [
  [0.9, 0.9],
  [0.9, 0.1],
  [0.1, 0.9],
  [0.1, 0.1]
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

state = nn.to_json
puts state

nn2 = Brains::Net.load(state)

results2 = test_data.collect { |item|
  nn2.feed(item)
}

puts "use saved state"

p results2
