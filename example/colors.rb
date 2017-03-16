#!/usr/bin/env ruby

require 'brains'

#This neural network will identify the main color name based on rgb values
RED = [0,0,1]
GREEN = [0,1,0]
BLUE = [1,0,0]

def color_value(color_value)
   [
     Integer(color_value[0..1], 16).to_f / 0xff.to_f,
     Integer(color_value[2..3], 16).to_f / 0xff.to_f,
     Integer(color_value[4..5], 16).to_f / 0xff.to_f,
   ]
end

def color_desc(result)
  return "blue" if (result[0] > result[1] && result[0] > result[2])
  return "green" if (result[1] > result[0] && result[1] > result[2])
  return "red" if (result[2] > result[0] && result[2] > result[1])
end

label_encodings = {
  "Blue"   => [1, 0, 0],
  "Green" => [0, 1, 0],
  "Red"  => [0, 0 ,1]
}
#0000ff
training_data = [
  # red
  [color_value('E32636'), RED],
  [color_value('8B0000'), RED],
  [color_value('800000'), RED],
  [color_value('65000B'), RED],
  [color_value('674846'), RED],

  #green
  [color_value('8F9779'), GREEN],
  [color_value('568203'), GREEN],
  [color_value('013220'), GREEN],
  [color_value('00FF00'), GREEN],
  [color_value('006400'), GREEN],
  [color_value('00A877'), GREEN],

  #blue
  [color_value('89CFF0'), BLUE],
  [color_value('ADD8E6'), BLUE],
  [color_value('0000FF'), BLUE],
  [color_value('0070BB'), BLUE],
  [color_value('545AA7'), BLUE],
  [color_value('4C516D'), BLUE],
]

nn = Brains::Net.create(3, 3, 1, {
    neurons_per_layer: 3,
    output_function: :softmax,
    error: :cross_entropy })

# randomize weights before training
nn.randomize_weights


# test on untrained data
#0000ee 	#C41E3A
test_data = [
  [color_value('0087BD') , 'blue'], # blue
  [color_value('C80815') , 'red'], # venetian red
  [color_value('009E60') , 'green'], # Shamrock green
  [color_value('00FF00') , 'green'], # green
  [color_value('333399') , 'blue'], # blue
]

correct = 0
test_data.each_with_index { |item , index|
  c = color_desc(nn.feed(item[0]))
  correct +=1 if (c == item[1])
  puts c
}

puts "#{correct}/#{test_data.length}"

result = nn.optimize(training_data, 0.25, 100_000, 100 ) { |i, error|
  puts "#{i} #{error}"
}

p result

puts "after training"

correct = 0
test_data.each_with_index { |item , index|
  r = nn.feed(item[0])
  c = color_desc(r)
  correct +=1 if (c == item[1])
  puts "#{r} -> #{c}"
}

puts "#{correct}/#{test_data.length}"

puts nn.to_json
