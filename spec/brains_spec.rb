require 'spec_helper'

describe Brains do
  it 'has a version number' do
    expect(Brains::VERSION).not_to be nil
  end

  it 'Train the sin function using neural networks' do
    # 1 input neuron, 1 output neuron, 5 total neurons
    brain = Brains::Net.new(1, 1, 20)
    brain.randomize_weights
    test_cases = [
      [ [1.0] , [Math.sin(1.0)] ],
      [ [0.9] , [Math.sin(0.9)] ],
      [ [0.5] , [Math.sin(0.5)] ],
      [ [0.3] , [Math.sin(0.3)] ],
      [ [0.1] , [Math.sin(0.1)] ],
      [ [0.2] , [Math.sin(0.2)] ],
      [ [0.8] , [Math.sin(0.8)] ],
      [ [0] , [Math.sin(0)] ],
    ]
    expect((brain.feed([0.6])[0] - Math.sin(0.6)).abs).to be > 0.1
    brain.optimize(test_cases, 0.001) { |i, total_errors|
      puts "#{i} -> #{total_errors}"
    }
    expect((brain.feed([0.6])[0] - Math.sin(0.6)).abs).to be < 0.1
    expect(JSON.parse(brain.to_json).select { |k,v| ['n'].include? k}).to eq ({'n' => 20})
  end
end
