#!/usr/bin/awk -f
BEGIN {
    FS = ","         # Set the Input Field Separator to a comma
    OFS = "\t\t"     # Set the Output Field Separator to a tab (for clean columns)
    print "Student Name", "Total Score", "Status" # Print a header
}
{
total = $2 + $3 + $4
status = "Pass"
if (total < 150) {
        status = "FAIL (Low Total)"
    } else if ($2 < 40 || $3 < 40 || $4 < 40) {
        status = "FAIL (Low Individual Score)"
    }
print $1, total, status
}
END {
print "Processing Complete."
}