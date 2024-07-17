;    File              : $BDOSLDR.ASM$
;
;    Description       :
;
;    Original Author   : DIGITAL RESEARCH
;
;    Last Edited By    : $CALDERA$
;
;-----------------------------------------------------------------------;
;    Copyright Work of Caldera, Inc. All Rights Reserved.
;      
;    THIS WORK IS A COPYRIGHT WORK AND CONTAINS CONFIDENTIAL,
;    PROPRIETARY AND TRADE SECRET INFORMATION OF CALDERA, INC.
;    ACCESS TO THIS WORK IS RESTRICTED TO (I) CALDERA, INC. EMPLOYEES
;    WHO HAVE A NEED TO KNOW TO PERFORM TASKS WITHIN THE SCOPE OF
;    THEIR ASSIGNMENTS AND (II) ENTITIES OTHER THAN CALDERA, INC. WHO
;    HAVE ACCEPTED THE CALDERA OPENDOS SOURCE LICENSE OR OTHER CALDERA LICENSE
;    AGREEMENTS. EXCEPT UNDER THE EXPRESS TERMS OF THE CALDERA LICENSE
;    AGREEMENT NO PART OF THIS WORK MAY BE USED, PRACTICED, PERFORMED,
;    COPIED, DISTRIBUTED, REVISED, MODIFIED, TRANSLATED, ABRIDGED,
;    CONDENSED, EXPANDED, COLLECTED, COMPILED, LINKED, RECAST,
;    TRANSFORMED OR ADAPTED WITHOUT THE PRIOR WRITTEN CONSENT OF
;    CALDERA, INC. ANY USE OR EXPLOITATION OF THIS WORK WITHOUT
;    AUTHORIZATION COULD SUBJECT THE PERPETRATOR TO CRIMINAL AND
;    CIVIL LIABILITY.
;-----------------------------------------------------------------------;
;
;    *** Current Edit History ***
;    *** End of Current Edit History ***
;
;    $Log$
;
;    ENDLOG

	include request.equ
	include driver.equ
	include	config.equ

;	MISC constants
CR		equ	0dh			;the usual
LF		equ	0ah


DATTS		equ	byte ptr 11
 DA_VOLUME	equ	08h
 DA_DIR		equ	10h
DBLOCK1H	equ	word ptr 20
DBLOCK1		equ	word ptr 26
DSIZE		equ	word ptr 28



CGROUP		group	INITCODE, INITDATA

INITCODE	segment public word 'INITCODE'
ASSUME CS:CGROUP,DS:CGROUP

if DOS5
VER_MUSTBE	equ	1072h
else
VER_MUSTBE	equ	1071h
endif

	Public	dos_version_check

dos_version_check:
;-----------------
	mov	ax,4452h
	int	21h			; try and get DRDOS version number
	 jc	dev_fail		;  it's not DRDOS !
	and	ax,0fffeh		; don't be so picky
	cmp	ax,VER_MUSTBE		; version check the DRDOS BDOS
	 jne	dev_fail		;  reject all but the one we want
	ret				; return now I'm happy

dev_fail:	; any error has occurred loading the BDOS
;--------
; Print '$' terminated message at offset DX to console without using the BDOS
;
	mov	dx,offset dos_msg
	les	di,resdev_chain		; get first device driver address
fail_scan:
	test	es:[di+DEVHDR.ATTRIB],DA_CHARDEV
	 jz	fail_next		; skip if not a character device
	test	es:[di+DEVHDR.ATTRIB],DA_ISCOT
	 jnz	fail_found		; skip if console device found
fail_next:
	les	di,es:[di]		; get next device
	jmp	fail_scan
fail_found:
	mov	ax,es:6[di]		; get strategy offset
	mov	strat_off,ax
	mov	strat_seg,es		; get strategy segment
	mov	ax,es:8[di]		; get interrupt offset
	mov	intrpt_off,ax
	mov	intrpt_seg,es		; get interrupt segment

	mov	bx,offset req_hdr
	mov	[bx+RH_CMD],CMD_OUTPUT	; write to console
	mov	[bx+RH_LEN],RH4_LEN	; set request header length
	mov	[bx+RH4_BUFOFF],dx	; set address of string
	mov	[bx+RH4_BUFSEG],ds
	mov	[bx+RH4_COUNT],-1
	mov	si,dx			; now find the end of the string
fail_count_chars:
	inc	[bx+RH4_COUNT]		; print another char
	lodsb				; examine the next one
	cmp	al,'$'			; terminating char ?
	 jnz	fail_count_chars
	call	device_request		; call the console driver

	sti
wait_forever:
	jmp	wait_forever			; wait for reboot


device_request:		; general device driver interface
;--------------
;	entry:	BX -> request header
;	exit:	CY = 1 if error

	push	ds
	push	es
	push	ds
	pop	es
	mov	ds,strat_seg
	call	dword ptr cs:strat_ptr
	call	dword ptr cs:intrpt_ptr
	pop	es
	pop	ds
	test	[bx+RH_STATUS],RHS_ERROR
	 jnz	devreq_err
	clc
	ret
devreq_err:
	stc
;	jmp	dev_fail		; print error message


	ret

INITCODE	ends



;
;	INITIALIZED DATA SEGMENT
;	========================
INITDATA	segment public word 'INITDATA'

		extrn	resdev_chain:dword	; resident device driver root
		extrn	current_dos:word	; current BDOS segment
		extrn	boot_device:dword	; device driver we boot from
		extrn	boot_drv:byte		; boot drive
		extrn	init_drv:byte		; init drive

strat_ptr	label	dword
strat_off	dw	?
strat_seg	dw	?

intrpt_ptr	label	dword
intrpt_off	dw	?
intrpt_seg	dw	?

	Public	part_off
part_off	dw	0,0			; offset of boot partition

;	single error message if BDOS can't be loaded:


include	initmsgs.def				; Include TFT Header File


;dos_msg	db	CR,LF,'Can''t load DOS file.$'


;	static request header for DOS device driver I/O

req_hdr		db	22
req_unit	db	?
req_cmd		db	?
req_status	dw	?
		dd	2 dup (?)
req_media	db	?
		db	16 dup (?)

req1_return	equ	byte ptr req_media+1
req1_volid	equ	word ptr req_media+2

req2_bufoff	equ	word ptr req_media+1
req2_bufseg	equ	word ptr req_media+3
req2_bpb	equ	word ptr req_media+5

req3_buffer	equ	dword ptr req_media+1
req3_bufoff	equ	word ptr req_media+1
req3_bufseg	equ	word ptr req_media+3
req3_count	equ	word ptr req_media+5
req3_sector	equ	word ptr req_media+7
req3_volid	equ	word ptr req_media+9
req3_sector32	equ	word ptr req_media+13

	extrn	sector_buffer:byte
INITDATA	ends

	end
