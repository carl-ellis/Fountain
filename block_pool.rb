require './fountain_encode.rb'

# This class is used to create a load of blocks up front, so as not to cause delay between every UDP request
class BlockPool

	attr_accessor :blocks, :i, :f, :pool_size

	# Give it a fountain to cache
	def initialize(fountain)
		@blocks = []
		@i = 0
		@f = fountain
		@pool_size = f.n/10

		new_pool
	end

	# When a pool is exhausted, re cache
	def new_pool
		puts "[Pool] Generating new pool ..."
		@i = 0
		(0...@pool_size).each do |j|
			@blocks[j] = f.next_block
		end
		puts "[Pool] Done"
	end

	# Grab a block from the pool
	def next
		b = @blocks[@i]
		@i += 1
		new_pool if @i >= @pool_size
		return b
	end
end
