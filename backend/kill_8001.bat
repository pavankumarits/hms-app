
wmic process where "CommandLine like '%%port 8001%%'" call terminate
