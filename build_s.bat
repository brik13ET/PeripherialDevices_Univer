@echo off

set ASM=.\TASM5.0\TASM.EXE /zi /r /w2 /t /la /z
set LD=.\TASM5.0\TLINK.EXE /v /m 
set OUT=.\OUT.EXE
set OBJS=0

cls
del *.exe
del *.obj

%ASM% %1 ,%OBJS%, .\OUT.LST, .\OUT.XREF

SET OBJ=
FOR /R %%F IN (*.obj) do (
	call set "OBJ=%%OBJ%% %%F"
)
echo object files: %OBJ%
%LD% %OBJ%, %OUT%, .\OUT.MAP