.model small
.stack 100h

MAX = 101

.data
	message 		db 'Iveskite zodziu eilute atskirta tarpais', 0Dh, 0Ah, '$'
	error_message	db 13,10,"Eilute nebuvo ivesta ",13,10,"$"
	result_message  db 13,10,"Rezultatas: ","$"
	buffer			db MAX, ?, MAX dup (?)
	number 			db 0
	index 			dw 0
.code

start:
	; perkeliam į duomenų segmentą į registrą
	MOV ax, @data
	MOV ds, ax
	
	; išvedam žinutę į ekraną
	MOV ah, 09h
	MOV dx, offset message
	INT 21h
	
	; skaitoma eilutė
	MOV dx, offset buffer
	MOV ah, 0Ah
	INT 21h
	
	MOV cx, 0
	MOV cl, buffer[1]
	
	cmp cl, 0
	JE error_mes
	
	MOV si, offset buffer + 2 
	
restult:
	MOV ah, 09h
	MOV dx, offset result_message
	INT 21h
	
count_numbers:
	MOV al,  [si]	; al nusiunciam si(adresa)
	INC si			;adresas buffer
	
	CMP al, '0'
	JB  printing
	CMP al, '9'
	JA  count_big_letters
	
	JMP loopas
	
count_big_letters:

	CMP al, 'A'
	JB printing
	CMP al, 'Z'
	JA count_small_letters
	
	JMP loopas

	
count_small_letters:
	CMP al, 'a'
	JB printing
	CMP al, 'z'
	JA printing
	
loopas:
	
	INC number
	LOOP count_numbers
	INC cx
	
printing:
	
	;ADD number, 30h
	cmp number, 0
	MOV index, cx			; isidedam cx i numberi kad nepamestumem koks buvo pirmo loopo cx
	JE number_is_zero		; jei tai nera skaicius nieko neisvedam
	
	;SUB number, 30h			; tikrinimui buvo naudojamas kaip simbolis, todel atverciam atgal 
	MOV al, number
	MOV ah, 0
	MOV cx, 0
	MOV bx, 10
convert:
	XOR dx,dx
	DIV bx
	
	ADD dl, '0'
	JMP loop1 
	
loop1:
	PUSH dx
	INC cx

	CMP ax, 0
	JA convert
	
print_number:
	POP dx 					; griztam i praeita reiksme
	MOV ah, 2
	INT 21h
	LOOP print_number
	
	MOV dl,' '				; atspausdiname tarpa tarp skaiciu
	MOV ah, 2
	INT 21h
	
number_is_zero:
	MOV number, 0	
	MOV cx, index			;grazinam i cx jo buvusia reiksme
	LOOP count_numbers
	JMP ending
	
error_mes:
	MOV dx, offset error_message
	MOV ah, 09h
	INT 21h
	JMP start	
ending:

	MOV ax, 4c00h 		     
	INT 21h    
	
end start