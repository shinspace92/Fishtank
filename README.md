# Fishtank
Automates Red Team Payload

# Setup
Install required `nim` libraries
```
nimble install uuids
nimble install winim
nimble install ptr_math
```

# To-do
 - [ ] HeapCreate() using read_write -> HeapAlloc() -> VirtualProtect() to read_write_execute -> Execution
 - [ ] **Automation**
	 - [x] Take positional arguments for:
		 - [ ] path to `.bin`
		 - [ ] Shellcode obfuscation methods
		 - [ ] 
	 - [ ] Obfuscate shellcode
	 - [ ] 