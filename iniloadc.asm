
%if 0

iniload config generation script

Usage of the works is permitted provided that this
instrument is retained with the works, so that any entity
that uses the works is notified of this instrument.

DISCLAIMER: THE WORKS ARE WITHOUT WARRANTY.

%endif

%assign __lMACROS1_MAC__SHOW_EXPLICIT 0
%assign __lMACROS1_MAC__SHOW_EXPLICIT_DEFAULT 0
%assign __lMACROS1_MAC__SHOW_EXPLICIT_VALUE 0

	db '; File auto-generated, do not edit.',13,10
	db 'strdef INILOAD_SIGNATURE, "DR"',13,10
	db '%assign _DEVICE 0',13,10
	db '%ifn _TEST_PROGRAM',13,10
	db ' numdef SECOND_PAYLOAD_EXE, 1',13,10
	db ' strdef SECOND_PAYLOAD_FILE, "tmp/version.com"',13,10
	db ' numdef SECOND_PAYLOAD_EXE_IP, 256',13,10
	db '%endif',13,10
