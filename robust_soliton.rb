require './mtwist.rb'

#An implimentation of the robust soliton discrete distribution
# Zero in the arrays are 0
class RobustSoliton

  DELTA = 0.5 # Failure probability

  attr_accessor :N, :M, :pdf, :cdf, :prng

  #initialises the variables
  def initialize(n, m)
    @N = n.to_f
    @M = m.to_f
    @pdf = []
    @cdf = []
    @pdf[0] = 0
    @cdf[0] = 0

    create_distributions
  end

  # Sets the seed for PRNG
  def srand(seed)
    @prng = Mtwist.new(seed)
  end

  def rand
    @prng = Mtwist.new(123456789) if @prng == nil
    return find(@prng.rand, @cdf, 0, @cdf.length)
  end

  private

  # Creates the pdf values for the distribution such that
  # p(1) = 1/N + t(1)
  # p(k) = 1/(k(k-1)) + t(i)  (k = 2,3,...,N)
  # t(k) = 1/(kM)             (k = 1,2,...,M-1)
  # t(k) = ln(R/d)/M          (k = M)
  # t(k) = 0                  (k - M+1, ..., N)
  def create_distributions
    (1..@N).each do |k|
      @pdf[k] = p(k) + t(k)  
      @cdf[k] = @cdf[k-1] + @pdf[k]
    end
    normalise
  end

  # p(1) = 1/N + t(1)
  # p(k) = 1/(k(k-1)) + t(i)  (k = 2,3,...,N)
  def p(k)
    k = k.to_f
    output = 0.0
    if k == 1
      output = 1/@N
    else
      output = 1/(k*(k-1))
    end
    return output
  end

  # t(k) = 1/(kM)             (k = 1,2,...,M-1)
  # t(k) = ln(R/d)/M          (k = M)
  # t(k) = 0                  (k - M+1, ..., N)
  def t(k)
    k = k.to_f
    output = 0.0
    if k < @M
      output = 1/(k*@M)
    elsif k == @M
      r = @N/@M
      output = Math.log(r/DELTA)/@M
    else
      output = 0.0
    end
    return output
  end

  # Ensure the distribution sums to 1
  def normalise
    nor_factor = @cdf.max
    (1..@N).each do |k|
      @pdf[k] = @pdf[k] / nor_factor 
      @cdf[k] = @cdf[k] / nor_factor
    end
  end

  # binary search on cdf to find output
  def find(v, array, s, e)
    m = s + ((e-s)/2).ceil

    if (v == array[m] || (v > array[m-1] && v < array[m+1]) || m == s)
      return m
    elsif (v < array[m])
      return find(v, array, s, m-1)
    elsif (v > array[m])
      return find(v, array, m+1, e)
    end
  end

end
