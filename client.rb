require 'socket'
require './block.rb'

# Server info
ADDR = "148.88.226.231"
PORT = "48155"

# Make server
servsock = nil
socks = []
begin
	servsock = UDPSocket.new
	while (1) do

		servsock.send("more",0, ADDR, PORT)
		
		input, from = servsock.recvfrom(100,0)
		block = input.unpack('L*')
		b = Block.new(block[0], block[1])
		puts b
			

	end
rescue IOError, SystemCallError => ie
	puts "arrg #{ie}"
	ensure servsock.close if servsock
end
