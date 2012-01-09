require './fountain_encode.rb'
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

# Make server
socks = []
servsock = nil
begin
	servsock = TCPServer.open(ADDR, PORT)
	servsock.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
	#servsock.bind(ADDR, PORT)
	socks << servsock
	while (1) do
		
		res = select(socks, nil, nil, nil)

		if res != nil 

			for s in res[0]
				if s == servsock
					# new connection
					newsock = servsock.accept
					socks << newsock
				else
					# current connection
					# if ended?
					if s.eof? then
						s.close
						socks.delete(s)
						puts "something left"
					else
						# if not ended
						# Send blocks
            s.write(f.next_block.to_udp)
						puts "sent something"
					end
				end
			end
			
		end

	end
rescue IOError, SystemCallError => ie
	puts "arrg #{ie}"
	ensure servsock.close if servsock
end
