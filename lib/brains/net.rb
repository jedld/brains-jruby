require 'java'

module Brains
  class Net
    def initialize(input:, output:, total:)
      @config = com.dayosoft.nn.NeuralNet::Config.new(input, output, total)
      @nn = com.dayosoft.nn.NeuralNet.new(@config);
    end
  end
end
