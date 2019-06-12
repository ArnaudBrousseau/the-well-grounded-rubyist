report = <<EOM
Collections Report : 05/15/2018

Initech owes us $34,500. They will remit payment on 5/15

U-North owes $96,000. They will remit payment on 5/15

Weyland-Utani Corp has a balance of $25,000 dating back to 1979
EOM

# Print names of companies
p report.lines[1..-1].map { |l| l.match(/^(\S+(?:\sCorp)?)/)&.captures }.compact.flatten

# Get prices in the text, convert them to integers
p report.lines.map { |l| l.match(/(?<=\$)([\d,]+)/)&.captures }.compact.flatten.map { |str| str.sub(',', '').to_i }

# Create a hash that maps company name to amount owed
p report.lines.map { |l| l.match(/(?<corp>\S+(?:\sCorp)?).+?(?<debt>\$[\d,]+)/)&.named_captures }.compact.inject({}) { |h, m| h[m['corp']] = m['debt']; h }

# P.S: yup, would probably never ever do this if this was production code. In the meantime, fits on one line!...
