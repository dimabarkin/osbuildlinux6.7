REM E:\Linux\6.7\fciv.exe -add "E:\Linux\6.7\V77197-01.iso" -both
set PACKER_LOG=1
c:\packer\packer build -only=virtualbox-iso oracle-linux-6.7-x86_64.json
