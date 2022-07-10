model basic -ndm 3 -ndf 6

proc py {args} {
    eval "[exec python {*}$args]"
}


lassign [py makePattern.py "/home/claudio/brace/CSMIP/sanlorenzo_28june2021.zip"] dt steps

puts "$dt $steps"


