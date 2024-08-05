[list -]



section PCM_HEADER public align=16 class=CODE

section PCM_CODE public align=1 class=CODE

section BDOS_CODE public align=2 class=CODE

section PCM_RODATA public align=2 class=CODE

section PCM_HISTORY public align=1 class=CODE

section PCM_ICODE public align=1 class=CODE

section PCM_CODEND public align=16 class=CODE



section PCMODE_DATA public align=2 class=DATA

section FDOS_DSEG common align=2 class=DATA

section FIXED_DOS_DATA public align=2 class=DATA

section PCMODE_CODE public align=2 class=DATA

section GLOBAL_DATA public align=2 class=DATA

section BDOS_DATA public align=2 class=DATA

section PCMODE_DSIZE public align=16 class=DATA


group PCMDATA PCMODE_DATA FDOS_DSEG FIXED_DOS_DATA PCMODE_CODE GLOBAL_DATA BDOS_DATA PCMODE_DSIZE
group PCMCODE PCM_HEADER PCM_CODE BDOS_CODE PCM_RODATA PCM_HISTORY PCM_ICODE PCM_CODEND

[list +]
