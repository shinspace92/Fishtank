# Fishtank
Automates Red Team Payload
Credits to @byt3bl33d3r for providing base templates of code snippets in his OffensiveNim repo

# Setup
1. Install `nim` programming language
```
https://nim-lang.org/install.html
```

2. Install required `nim` libraries
```
nimble install uuids
nimble install winim
nimble install ptr_math
```

3. Create `shellcodes` and `outputs` directory
```
mkdir shellcodes outputs
```

# Usage
1. Prepare shellcode in `.bin` format
2. Run `FishTank.exe` and give it a path to the shellcode
```
FishTank.exe shellcodes/calc.bin
```
3. An `exe` will be generated in the `outputs` directory

> [!Danger] Ethical Usage
> This tool is meant to be used for educational purposes only.
