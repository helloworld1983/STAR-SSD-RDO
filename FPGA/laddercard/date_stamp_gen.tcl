set outfile [open "date_stamp.vhd" w+]

set systemTime [clock seconds] 


scan [clock format $systemTime -format %d] "%02d" day 
scan [clock format $systemTime -format %m] "%02d" month
scan [clock format $systemTime -format %Y] "%04d" year
scan [clock format $systemTime -format %H] "%02d" hour
scan [clock format $systemTime -format %M] "%02d" minute
scan [clock format $systemTime -format %S] "%02d" second


set dateval [format "constant revision_date : std_logic_vector(31 downto 0) := X\"%02d%02d%02d%02d\";"   $day $month [expr $year/100] [expr $year%100] ]
set timeval [format "constant revision_time : std_logic_vector(31 downto 0) := X\"%02d%02d%02d%02d\";"   $hour $minute $second 0]


puts $outfile "use ieee.std_logic_1164.all;"
puts $outfile "package date_stamp is"

puts $outfile $dateval
puts $outfile $timeval
puts $outfile "end package date_stamp;"

close $outfile

