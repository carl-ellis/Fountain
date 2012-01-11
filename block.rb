# Describes an encoded block
class Block

	attr_accessor :seed, :data

	# Constructor
	def initialize(seed, data)
		@seed = seed
		@data = data
	end

	# For debug output
	def to_s
		return "#{seed}|#{data}"
	end

	# For UDP transmission
	def to_udp
		return [seed, data].pack('L*')
	end
end
