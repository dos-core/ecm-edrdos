
; Public Domain

%include "lmacros3.mac"

	cpu 8086
	org 256
start:
	mov al, 13
	mov si, 129
.loop_cap:
	lodsb
	call capitalise
	mov byte [si - 1], al
	cmp al, 13
	jne .loop_cap

	mov si, 129
.loop_blank:
	lodsb
	cmp al, 32
	je .loop_blank
	cmp al, 9
	je .loop_blank
	cmp al, 13
	je display_version
	dec si
	mov di, msg.keyword_version
	mov cx, msg.keyword_version.length
	repe cmpsb
	jne display_error
	lodsb
	cmp al, 32
	je display_version
	cmp al, 9
	je display_version
	cmp al, 13
	je display_version

display_error:
	mov dx, msg.error
	mov cx, msg.error.length
	mov bx, 1
	mov ah, 40h
	int 21h
	mov ax, 4C01h
	int 21h


capitalise:
	cmp al, 'a'
	jb .ret
	cmp al, 'z'
	ja .ret
	xor al, 'a' ^ 'A'
.ret:
	retn


display_version:
	mov dx, msg.version
	mov cx, msg.version.length
	mov bx, 1
	mov ah, 40h
	int 21h
	mov ax, 4C00h
	int 21h


%define if comment
%define else comment
%define endif comment

msg:
.error:
	db "Error, unknown parameter!",13,10
.error.length: equ $ - .error

.keyword_version:
	db "VERSION"
.keyword_version.length: equ $ - .keyword_version
	db '='

.version:
%include "version.inc"
	db 13,10
.version.length: equ $ - .version
