#!/usr/bin/env ruby

require 'brains'

# RNN to approximate a sine function sequence

def generate_sine_test_data(start_t, end_t)
  inputs = []
  outputs = []

  (start_t...end_t).each do |t|
    inputs << [Math.sin(t)]
    outputs << [Math.sin(t + 1)]
  end

  [[inputs, outputs]]
end



training_data = generate_sine_test_data(0, 10)

testing_data = generate_sine_test_data(11, 20)

# input sequence
input_sequence = training_data[0][0].map { |a| a[0] }
test_input_sequence = testing_data[0][0].map { |a| a[0] }
test_output_sequence = testing_data[0][1].map { |a| a[0] }

nn = Brains::Net.create(1, 1, 1, { neurons_per_layer: 3,
      learning_rate: 0.01,
      recurrent: true,
      output_function: :htan,
     })

# randomize weights before training
nn.randomize_weights

results = nn.feed(testing_data[0][0])
results.each_with_index do |a, index|
  puts "#{test_input_sequence[index]} => #{a[0]}"
end

result = nn.optimize_recurrent(training_data, 0.001, 1_000_000, 10_000 ) { |i, error|
  puts "#{i} #{error}"
}

results = nn.feed(testing_data[0][0])
results.each_with_index do |a, index|
  puts "#{test_input_sequence[index]} => #{a[0]} (#{test_output_sequence[index]})"
end

puts nn.to_json
