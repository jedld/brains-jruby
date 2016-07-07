require "brains/version"
require "brains/brains.jar"
require "brains/gson.jar"
require "brains/commons-lang3.jar"
require "brains/commons-cli.jar"
require "brains/net"
require "json"

module Brains
  class Config
    attr_accessor :neurons_per_layer, :input_neurons, :output_neurons
  end
end
