# Describes an encoded block
class Block

	attr_accessor :seed, :data

	def initialize(seed, data)
		@seed = seed
		@data = data
	end

	def to_s
		return "#{seed}|#{data}"
	end

	def to_udp
		return [seed, data].pack('L*')
	end
end
