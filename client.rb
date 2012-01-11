require 'socket'
require './decode_block.rb'
require './fountain_decode.rb'

# Outputs progress displays
def display_progress(fd)
	system("clear")
	puts fd
end

# Server info
ADDR = "148.88.226.231"
PORT = "48155"

# Make sure an output file is given
if ARGV[0].nil?
	puts "Please give an output file name"
end

# Make server
servsock = nil
socks = []
begin
	# Ruby sockets are easy
	servsock = UDPSocket.new

	# get size
	servsock.send("size",0, ADDR, PORT)
	n, from = servsock.recvfrom(100,0)
  n = n.to_i

	# Create decoder
	fd = FountainDecode.new(n)
	i = 1
	while (!fd.done?) do

		# Send anything, could even be "badger" and get the next block
		servsock.send("more",0, ADDR, PORT)
		
		input, from = servsock.recvfrom(100,0)
		block = input.unpack('L*')

		# Pass it to the decoder
		fd.process( DecodeBlock.new(Block.new(block[0], block[1]), n))

		# Only output every N blocks
		display_progress(fd) if (i % 100 == 0)
		i = (i+1)%100
	end

	# When done, output
	fd.output(ARGV[0])
	puts "Done"
rescue IOError, SystemCallError => ie
	puts "arrg #{ie}"
	ensure servsock.close if servsock
end

