netsh winsock reset catalog
netsh int ip reset reset.log
ipconfig /flushdns
ipconfig /registerdns
route /f
sc config FDResPub start=auto
sc config fdPHost start=auto
shutdown -r -t 10