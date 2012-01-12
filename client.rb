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
#ADDR = "127.0.0.1"
PORT = "48155"
TIMEOUT = 5.0

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

	n = nil

	# get size
	while(n.nil?)
		servsock.send("size",0, ADDR, PORT)
		if select([servsock], nil, nil, TIMEOUT)
			n, from = servsock.recvfrom(100,0)
			n = n.to_i      
		end
	end

	# Create decoder
	fd = FountainDecode.new(n)
	i = 1
	while (!fd.done?) do

		begin

			# Send anything, could even be "badger" and get the next block
			servsock.send("more",0, ADDR, PORT)
		  if select([servsock], nil, nil, TIMEOUT)
				input, from = servsock.recvfrom_nonblock(100,0)
				block = input.unpack('L*')

				# Pass it to the decoder
				d = DecodeBlock.new(Block.new(block[0], block[1]), n)
				fd.process(d )

				# Only output every N blocks
				display_progress(fd) if (i % 75 == 0)
				i = (i+1)%75
			end
		rescue Exception
      retry
		end
	end

	# When done, output
	fd.output(ARGV[0])
	puts "Done"
rescue IOError, SystemCallError => ie
	puts "arrg #{ie}"
	ensure servsock.close if servsock
end

