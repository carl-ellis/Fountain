# decodes a fountain code
class FountainDecode

	attr_accessor :decoded, :encoded, :max_block, :num_valid, :count 

	
  def initialize(n)
		@decoded = []
		@encoded = []
		@max_block = n
		@num_valid = 0
    @count = 0
	end

	# add a single block - it's therefore already decoded
	def add_single_block(block)

		if @decoded[block.blocks[0]].nil? 
		 	@decoded[block.blocks[0]] = block.data 
			@num_valid += 1
		end
	end             

	# Checks all the encoded blocks against new decoded blocks
	def decode
		
		# go through all of the encoded blocks and fund new singles
		@encoded.each do |enc|
			@encoded.delete(enc)
	 		enc = decode_new_multi(enc)
			nd = enc.blocks.length
			if nd == 0
				# Got them all, discard
			elsif nd == 1
				# new single block
				add_single_block(enc)
			else
				# add to the pile of unknowns
				@encoded << enc
			end
		end
	end

  # add a multiblock - encoded
	def add_multi_block(block)
			@encoded << block
	end

	#decode any known blocks
	def decode_new_multi(block)
		
		not_found = []
		block.blocks.each do |bl_id|
			if @decoded[bl_id].nil?
				not_found << bl_id
			else
				block.data ^= @decoded[bl_id]
			end
		end
		block.blocks = not_found
		return block
	end

	# Pass this a block, it'll sort it
	def process(decoded_block)
		# filter them to where they need to go
		if decoded_block.blocks.length == 1
			add_single_block(decoded_block)
		else
			add_multi_block(decoded_block)
		end
		decode if (@count % (@max_block/10)) == 0
		@count +=1
	end

  # output a map representation of the current known program
	def to_s
		output = ""
		(0...@max_block).each do |i|
			if @decoded[i].nil?
				output << " "
			else
				output << "O"
			end
		end
		output << "\n\nTotal decoded:#{@num_valid}, Encoded heap size:#{@encoded.length}, Total needed:#{@max_block}, percentage:#{@num_valid/@max_block.to_f * 100}"
		return output
	end

	# Got all the blocks?
	def done?
		return @num_valid == @max_block
	end

	# Output to a file
	def output(file)
		IO.binwrite(file, @decoded.pack('L*'))
	end
end
