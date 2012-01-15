require './robust_soliton.rb'
require './block.rb'

# Encodes a file using a fountain code and creates blocks
class FountainEncode

	BLOCK_SIZE = 32
	MAX_INT = 4294967295

	attr_accessor :bytes, :n, :sol, :prng

	def initialize(file)

		# get chunks
		file_to_blocks(file, FountainEncode::BLOCK_SIZE)

  	@sol = RobustSoliton.new(@n, @n/2)
		@prng = Mtwist.new(1)
	end

	def file_to_blocks(file, block_size)

		# Read in file as binary
		blob = IO::binread(file)
		
		# pad for 32 bitness
		if blob.length%32 > 0
			(32 - blob.length%32).times { blob << 0x00 }
		end

		# Split into 32Kb blocks
		@bytes = blob.unpack('L*')
		@n = @bytes.length
	end

	def next_block
		# Get a seed
		seed = @prng.extract_number

		# Reset soliton and prng
		@prng = Mtwist.new(seed)
		@sol.srand((@prng.rand * MAX_INT).floor )

		# Get number of blocks and encode
		number_of_blocks = @sol.rand
		blocks_to_encode = []
		(0...number_of_blocks).each do |i|
			# Random block number
			blocks_to_encode << (@prng.rand * (@n)).floor
		end

		#encode
		block_data = 0
		blocks_to_encode.each { |b| block_data ^= @bytes[b] } 

		return Block.new(seed, block_data)
	end

end

