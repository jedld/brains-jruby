require 'java'

module Brains
  class Net
    attr_accessor :nn, :config

    def self.create(input, output, total_hidden_layers = 1, opts = {})
      neurons_per_layer = opts[:neurons_per_layer] || 5

      config = com.dayosoft.nn.NeuralNet::Config.new(input, output,  total_hidden_layers * neurons_per_layer + output)
      config.bias = opts[:bias] || 1.0
      config.outputBias = opts[:output_bias] || 1.0
      config.learningRate = opts[:learning_rate] || 0.1
      config.neuronsPerLayer = neurons_per_layer
      config.momentumFactor = opts[:momentum_factor] || 0.5
      config.isRecurrent = opts[:recurrent] || false
      config.backPropagationAlgorithm = opt_t_back_alg(opts[:train_method] || :standard)
      config.activationFunctionType = opt_to_func(opts[:activation_function] || :htan)
      config.outputActivationFunctionType = opt_to_func(opts[:output_function] || :sigmoid)
      config.errorFormula = opt_to_error_func(opts[:error] || :mean_squared)
      nn = com.dayosoft.nn.NeuralNet.new(config);

      Brains::Net.new.set_nn(nn).set_config(config)
    end

    def self.load(json_string)
      nn = com.dayosoft.nn.NeuralNet::loadStateFromJsonString(nil, json_string)
      config = nn.getConfig

      Brains::Net.new.set_nn(nn).set_config(config)
    end

    def randomize_weights(min = -1, max = 1)
      @nn.randomizeWeights(min, max)
    end

    def dump_weights
      @nn.dumpWeights.to_a.map(&:to_a)
    end

    def dump_biases
      @nn.dumpWeights.to_a.map(&:to_a)
    end

    def optimize(test_cases, target_error = 0.01, max_epoch = 1_000_000_000, callback_interval = 1000, &callback)
      inputs = []
      outputs = []

      test_cases.each do |item|
        inputs << item[0].to_java(Java::double)
        outputs << item[1].to_java(Java::double)
      end

      result = @nn.optimize(java.util.ArrayList.new(inputs), java.util.ArrayList.new(outputs), target_error, max_epoch,
        callback_interval, callback)
      { iterations: result.first, error: result.second }
    end

    def optimize_recurrent(test_cases, target_error = 0.01, max_epoch = 1_000_000_000,
        callback_interval = 1000, max_layers = 0, &callback)
      inputs = []
      outputs = []

      input_set = java.util.ArrayList.new
      output_set = java.util.ArrayList.new

      test_cases.each do |item|

        inputs = java.util.ArrayList.new
        outputs = java.util.ArrayList.new

        item[0].each do |item|
          inputs.add(item.to_java(Java::double))
        end

        item[1].each do |item|
          outputs.add(item.to_java(Java::double))
        end

        input_set.add(inputs)
        output_set.add(outputs)
      end

      result = @nn.optimizeRecurrent(input_set, output_set, target_error, max_layers, max_epoch,
        callback_interval, callback)

      { iterations: result.first, error: result.second }
    end

    def feed(input)
      # recurrent mode when array of array is passed.
      if input && input.size > 0 && input[0].kind_of?(Array)
        feed_recurrent(input)
      else
        @nn.feed(input.to_java(Java::double)).to_a
        @nn.updatePreviousOutputs if config.isRecurrent
      end
    end

    # For a recurrent network, this resets hidden states back to zero
    def reset
      if config.isRecurrent
        @nn.resetRecurrentStates
      else
        puts "Warning not a recurrent network. This does nothing"
      end
    end

    def feed_recurrent(inputs)
      inputset = java.util.ArrayList.new
      inputs.each do |input|
        inputset.add(input.to_java(Java::double))
      end

      output_set = @nn.feed(inputset).to_a
      output_set.collect do |output|
        output.to_a
      end
    end

    def to_json
      @nn.saveStateToJson
    end

    def set_nn(nn)
      @nn = nn
      self
    end

    def set_config(config)
      @config = config
      self
    end

    protected

    def initialize
    end

    private

    def self.opt_to_func(func)
      case func
      when :htan
        com.dayosoft.nn.Neuron::HTAN
      when :sigmoid
        com.dayosoft.nn.Neuron::SIGMOID
      when :softmax
        com.dayosoft.nn.Neuron::SOFTMAX
      when :rectifier
        com.dayosoft.nn.Neuron::RECTIFIER
      else
        raise "invalid activation function #{func}"
      end
    end

    def self.opt_t_back_alg(func)
      case func
      when :standard
        com.dayosoft.nn.NeuralNet::Config::STANDARD_BACKPROPAGATION
      when :rprop
        com.dayosoft.nn.NeuralNet::Config::RPROP_BACKPROPAGATION
      else
        raise "Invalid backpropagation method #{func}"
      end
    end

    def self.opt_to_error_func(func)
      case func
      when :mean_squared
        com.dayosoft.nn.NeuralNet::Config::MEAN_SQUARED
      when :cross_entropy
        com.dayosoft.nn.NeuralNet::Config::CROSS_ENTROPY
      else
        raise "Invalid Error Function #{func}"
      end
    end
  end
end
