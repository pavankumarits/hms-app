
wmic process where "CommandLine like '%%uvicorn%%'" call terminate
