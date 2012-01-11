require './fountain_encode.rb'
require './block_pool.rb'
require 'socket'

# Server info
ADDR = "148.88.226.231"
PORT = "48155"

if ARGV.length == 0
	puts "give a file to code"
	exit
end

# Create fountain
f = FountainEncode.new(ARGV[0])
bp = BlockPool.new(f)

# Make server
socks = []
servsock = nil
begin
	servsock = UDPSocket.open
	servsock.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
	servsock.bind(ADDR, PORT)
	socks << servsock
	while (1) do
		
		res = select(socks, nil, nil, nil)

		if res != nil 

			for s in res[0]
				if s == servsock
					# new connection
					reply, from = servsock.recvfrom(100, 0)

					# If size is asked, give them it
          if reply == "size"
						s.send(f.n.to_s,0, from[2], from[1])
					else
						# Send blocks
						#block = f.next_block
						block = bp.next
						s.send(block.to_udp,0, from[2], from[1])
						#puts block
					end
				end
			end
			
		end

	end
rescue IOError, SystemCallError => ie
	puts "arrg #{ie}"
	ensure servsock.close if servsock
end
