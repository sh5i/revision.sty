#!/usr/bin/env ruby

P1 = /(?<p1> (?: [^\{\}]+ | \{ \g<p1> \} )*)/x
P2 = /(?<p2> (?: [^\{\}]+ | \{ \g<p2> \} )*)/x

class String
  def crop(name)
    gsub(/\\#{name}\{(#{P1})\}/, '')
  end
  def peel(name)
    gsub(/\\#{name}\{#{P1}\}/, '\k<p1>')
  end
  def peel2(name)
    gsub(/\\#{name}\{#{P1}\}\{#{P2}\}/, '\k<p2>')
  end
end

s = ARGF.read
s = s.peel(/A(?:dded)?/)
s = s.peel(/M(?:odified)?/).peel(/M(?:odified)?/) # in case of nesting
s = s.crop(/D(?:eleted)?/)
s = s.crop(/Removed/)
s = s.peel2(/Rep(?:laced)?/)
s = s.peel2(/R(?:evised)?/).peel2(/R(?:evised)?/) # in case of nesting
s = s.crop(/Label/)

# s = s.peel(/underline/)
# s = s.peel(/text/)
# s = s.peel(/emph/)
# s = s.peel(/textit/)
# s = s.peel(/textbf/)
# s = s.peel(/textsf/)
# s = s.peel(/texttt/)
# s = s.peel(/mathrm/)
# s = s.peel(/mathit/)
# s = s.peel(/mathbf/)
# s = s.peel(/mathsf/)
# s = s.peel(/mathtt/)

# s = s.crop(/label/)

#s = s.peel(/section/)
#s = s.peel(/subsection/)
#s = s.peel(/subsubsection/)
#s = s.peel(/paragraph/)

#s = s.crop(/cite/)
# s = s.gsub('~', ' ')
# s = s.gsub('\\%', '%')

# s = s.peel(/BLT/)


print s
