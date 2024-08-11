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

	%include "request.mac"
	%include "driver.mac"
	%include "udsc.mac"
	%include "config.mac"

;	MISC constants
CR		equ	0dh			;the usual
LF		equ	0ah


labelsize DATTS, byte, 11
 DA_VOLUME	equ	08h
 DA_DIR		equ	10h
labelsize DBLOCK1H, word, 20
labelsize DBLOCK1, word, 26
labelsize DSIZE, word, 28



group CGROUP INITCODE INITDATA

section INITCODE public align=2 class=INITCODE
ASSUME CS:CGROUP,DS:CGROUP

VER_MUSTBE	equ	1072h


	Public	detect_boot_drv
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


	; Tries to detect to logical boot drive by the given phys boot drv
	; and a partition offset
detect_boot_drv proc
	les	di,[boot_device]		; get device driver address
	mov	dl,[boot_drv]		; get the boot drive sub unit
	xor	dh,dh
	dec	dh			; dh=255
	mov	ax,es
	or	ax,di			; make sure boot device is initialised
	 jnz	@@get_device_procs
	ret				; single-file kernel, user may resolve

@@get_device_procs:
	mov	ax,[es:6 + di]		; get strategy offset
	mov	[strat_off],ax
	mov	[strat_seg],es		; get strategy segment
	mov	ax,[es:8 + di]		; get interrupt offset
	mov	[intrpt_off],ax
	mov	[intrpt_seg],es		; get interrupt segment
@@test_drv:
	mov	bx,offset req_hdr
	mov	[bx+RH_UNIT],dl		; save logical unit to use
	mov	byte [bx+RH_CMD],CMD_BUILD_BPB
	call	device_request		; tell it to build a BPB
	 jnc	@@bpb_ok		; BPB successfully built
	jmp	@@next_drv		; if not, try next drive
@@bpb_ok:
	cmp	dl,[boot_drv]
	 jne	@@compare_part_off
	mov	dh,dl			; dh=boot_drv
@@compare_part_off:
	les	di,[bx+RH2_BPB]
	mov al, [init_int13_unit]
		; magic: poke into the UPB structure around the BPB
UDSC.UDSCBPB equ UDSCBPB	; NASM port label
UDSC.RUNIT equ RUNIT	; NASM port label
	cmp byte ptr [es:- UDSC.UDSCBPB + UDSC.RUNIT + di], al
	 jne @@next_drv
	mov	ax,[part_off]
	cmp	word ptr [es:BPB_HIDDEN + di],ax
	 jne	@@next_drv
	mov	ax,[part_off+2]
	cmp	word ptr [es:BPB_HIDDEN+2 + di],ax
	 jne	@@next_drv
	mov	dh,dl
	jmp	@@done
@@next_drv:
	inc	dl			; increase log drv num
	 jz	@@done
	jmp	@@test_drv
@@done:
	cmp	dh,255
	 jne	@@store_boot_drv	; boot drv found?
	jmp	dev_fail
@@store_boot_drv:
	mov	dl,dh
	mov	[boot_drv],dl
	mov	[init_drv],dl
	ret
detect_boot_drv endp


	public dev_fail

dev_fail:	; any error has occurred loading the BDOS
;--------
; Print '$' terminated message at offset DX to console without using the BDOS
;
	push cs
	pop ds
	mov	dx,offset dos_msg
	les	di,[resdev_chain]		; get first device driver address
fail_scan:
DEVHDR.ATTRIB equ ATTRIB	; NASM port label
	test	word [es:di+DEVHDR.ATTRIB],DA_CHARDEV
	 jz	fail_next		; skip if not a character device
	test	word [es:di+DEVHDR.ATTRIB],DA_ISCOT
	 jnz	fail_found		; skip if console device found
fail_next:
	les	di,[es:di]		; get next device
	jmp	fail_scan
fail_found:
	mov	ax,[es:6 + di]		; get strategy offset
	mov	[strat_off],ax
	mov	[strat_seg],es		; get strategy segment
	mov	ax,[es:8 + di]		; get interrupt offset
	mov	[intrpt_off],ax
	mov	[intrpt_seg],es		; get interrupt segment

	mov	bx,offset req_hdr
	mov	byte [bx+RH_CMD],CMD_OUTPUT	; write to console
	mov	byte [bx+RH_LEN],RH4_LEN	; set request header length
	mov	[bx+RH4_BUFOFF],dx	; set address of string
	mov	[bx+RH4_BUFSEG],ds
	mov	word [bx+RH4_COUNT],-1
	mov	si,dx			; now find the end of the string
fail_count_chars:
	inc	word [bx+RH4_COUNT]		; print another char
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
	mov	ds,[strat_seg]
	call	far [cs:strat_ptr]
	call	far [cs:intrpt_ptr]
	pop	es
	pop	ds
	test	word [bx+RH_STATUS],RHS_ERROR
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
section INITDATA public align=2 class=INITDATA

		extrn	resdev_chain:dword	; resident device driver root
		extrn	current_dos:word	; current BDOS segment
		extrn	boot_device:dword	; device driver we boot from
		extrn	boot_drv:byte		; boot drive
		extrn	init_drv:byte		; init drive
		extrn	init_int13_unit:byte


strat_ptr	label	dword
strat_off	dw	?
strat_seg	dw	?

intrpt_ptr	label	dword
intrpt_off	dw	?
intrpt_seg	dw	?

	Public	part_off
part_off	dw	0,0			; offset of boot partition

;	single error message if BDOS can't be loaded:


%include "initmsgs.mac"				; for dos_msg error msg


;	static request header for DOS device driver I/O

req_hdr		db	22
req_unit	db	?
req_cmd		db	?
req_status	dw	?
		dd	2 dup (?)
req_media	db	?
		db	16 dup (?)

labelsize req1_return, byte, req_media+1
labelsize req1_volid, word, req_media+2

labelsize req2_bufoff, word, req_media+1
labelsize req2_bufseg, word, req_media+3
labelsize req2_bpb, word, req_media+5

labelsize req3_buffer, dword, req_media+1
labelsize req3_bufoff, word, req_media+1
labelsize req3_bufseg, word, req_media+3
labelsize req3_count, word, req_media+5
labelsize req3_sector, word, req_media+7
labelsize req3_volid, word, req_media+9
labelsize req3_sector32, word, req_media+13

BPB_HIDDEN		equ	17

INITDATA	ends

	end
