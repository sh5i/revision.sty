#!/usr/bin/env ruby

P1 = /(?<p1> (?: [^\{\}]+ | \{ \g<p1> \} )*)/x
P2 = /(?<p2> (?: [^\{\}]+ | \{ \g<p2> \} )*)/x
SEP = /(?: \s | %[^\n]*\n )*/x # what TeX skips between two arguments

# Every rule strictly shrinks the string, so repeating it until nothing
# matches terminates, and peels nesting of any depth.
class String
  def crop(name)
    s = dup
    nil while s.gsub!(/\\#{name}\{#{P1}\}/, '')
    s
  end
  def peel(name)
    s = dup
    nil while s.gsub!(/\\#{name}\{#{P1}\}/, '\k<p1>')
    s
  end
  def peel2(name)
    s = dup
    nil while s.gsub!(/\\#{name}\{#{P1}\}#{SEP}\{#{P2}\}/, '\k<p2>')
    s
  end
end

s = ARGF.read
s = s.peel(/A(?:dded)?/)
s = s.peel(/M(?:odified)?/)
s = s.crop(/D(?:eleted)?/)
s = s.crop(/Removed/)
s = s.peel2(/Rep(?:laced)?/)
s = s.peel2(/RevisedNoMark/)
s = s.peel2(/R(?:evised)?/)
s = s.peel2(/RM/)
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
