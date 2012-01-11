require './block.rb'
require './robust_soliton.rb'
require './mtwist.rb'

# Handy class for turning a seed into the blocks which were used to encode a block
# Used by the decoder
class DecodeBlock

	attr_accessor :seed, :blocks, :data

	# Set the RNGs and get your information
	def initialize(block, n)
		@seed = block.seed
		@data = block.data
		@blocks = []

		# get blocks encoded
		s = RobustSoliton.new(n,n/2)
		s.srand(@seed)
		m = Mtwist.new(seed)

		nb = s.rand
		(0...nb).each do |i|
			@blocks << (m.rand * (n)).floor
		end
	end

	# Debug
	def to_s
		output = ""
		@blocks.each { |b| output << "#{b} " }
		return output + "=> #{data}"
	end
end
