#!/usr/bin/expect -f
# Robert Hilton (robert.a.hilton.jr@gmail.com)
# Argument 0 is the CSV file input. CSV Format is header row PrevAPName,NewAPName then the data following the header row
# Argument 1 is the IP address of the master controller
# Argument 2 is the password for the admin user
# Argument 3 is set to enable an enable password (set to en)
# Argument 4 is the enable password (only used if en is specified)
# Usage: ./APRename.sh APNames.csv 192.168.50.254 password en enpassword

package require csv
package require struct

::struct::matrix values

set file [lindex $argv 0 ]

set fid [open $file r]
::csv::read2matrix $fid values "," auto
close $fid
set maxRows [values rows]

set timeout -1
set ip [lindex $argv 1 ]
puts $ip
set pass [lindex $argv 2 ]
puts $pass
set en [lindex $argv 3 ]
puts $en
set enpass [lindex $argv 4 ]
puts $enpass

spawn ssh admin@$ip
expect "*assword: "

send "$pass\r"
if {[llength $en] > 0} {
	send "\r"
	expect "*>"
	send "en\r"
	expect "*assword:"
	send "$enpass\r"
	expect "#"
}

send "\r"
expect "#"

for {set i 1} {$i<$maxRows} {incr i} {
	set prevName [values get cell 0 $i]
	set newName [values get cell 1 $i]
	set cmd "ap-rename ap-name $prevName $newName"
    send "$cmd\r"
	expect "#"
}

if {[llength $en] > 0} {
	send "\r"
	expect "#"
	send "exit\r"
	expect "*>"
}
send "exit\r"
