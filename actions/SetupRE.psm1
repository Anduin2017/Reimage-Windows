## This function is used to setup the recovery environment.
function SetupRE {
    reagentc /enable
}

Export-ModuleMember -Function SetupRE

# Bcdedit /enum {current} can check the RE ID.
# reagentc /info can check the RE status.
# Bcdedit /enum {REID} can check the RE BCD status.
# Use Diskpart to check the RE partition status.