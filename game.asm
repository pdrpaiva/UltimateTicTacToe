.8086
.model small
.stack 2048

dseg	segment para public 'data'

dseg	ends	

cseg	segment para public 'code'
assume	cs:cseg, ds:dseg

main  proc

main  endp

cseg	ends
end	main
