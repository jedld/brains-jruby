require 'java'

module Brains
  class Net
    attr_accessor :nn, :config

    def self.create(input, output, total, opts = {})
      config = com.dayosoft.nn.NeuralNet::Config.new(input, output, total)
      config.bias = opts[:bias] || 1.0
      config.outputBias = opts[:output_bias] || 1.0
      config.learningRate = opts[:learning_rate] || 0.1
      config.neuronsPerLayer = opts[:neurons_per_layer] || 5
      config.momentumFactor = opts[:momentum_factor] || 0.5
      config.activationFunctionType = opt_to_func(opts[:activation_function] || :htan)
      config.outputActivationFunctionType = opt_to_func(opts[:activation_function] || :sigmoid)
      config.errorFormula = opt_to_error_func(opts[:activation_function] || :mean_squared)
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

    def optimize(test_cases, target_error = 0.01, max_epoch = 1_000_000_000, is_batch = false, &callback)
      inputs = []
      outputs = []

      test_cases.each do |item|
        inputs << item[0].to_java(Java::double)
        outputs << item[1].to_java(Java::double)
      end

      result = @nn.optimize(java.util.ArrayList.new(inputs), java.util.ArrayList.new(outputs), target_error, max_epoch, is_batch, callback)
      { iterations: result.first, error: result.second }
    end

    def feed(input)
      output = @nn.feed(input.to_java(Java::double)).to_a
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
