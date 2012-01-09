# An implementation of the Mersenne Twister
class Mtwist

  # Some constants to make up for typeless constraints
  ARRAY_LENGTH = 624

  INIT_CONST = 1812433253

  EXTRACT_CONST1 = 2636928640
  EXTRACT_CONST2 = 4022730752

  GENERATE_CONST = 2567483615 

  attr_accessor :mt, :index

  #Initialise the generator from a seed
  def initialize(seed)
    @index = 0
    @mt = []
    @mt[0] = seed
    (1...ARRAY_LENGTH).each do |i|
      @mt[i] = (2 **32 -1) & (INIT_CONST * (@mt[i-1] ^ (@mt[i-1] >> 30)) + i)
    end
  end

  # Get a psuedorandom number - state re-generated every 624 numbers
  def extract_number
    if @index == 0
      generate_numbers()
    end

    y = @mt[@index]
    y = y ^ (y >> 11)
    y = y ^ ((y << 7) & EXTRACT_CONST1)
    y = y ^ ((y << 15) & EXTRACT_CONST2)
    y = y ^ (y >> 18)

    index = (@index + 1) % ARRAY_LENGTH
    return y
  end

  #Generates 624 untempered numbers
  def generate_numbers
    (0...ARRAY_LENGTH).each do |i|
      y = ((1 << 31) & @mt[i]) + ((2**31 -1) & (@mt[(i+1)%ARRAY_LENGTH] % ARRAY_LENGTH))
      @mt[i] = @mt[(i + 397) % ARRAY_LENGTH] ^ (y >> 1)
      if (y % 2) != 0
        @mt[i] = @mt[i] ^ GENERATE_CONST
      end
    end
  end

  # Return a float that is (0,1)
  def rand
    return extract_number / (2**32 -1).to_f
  end

end
