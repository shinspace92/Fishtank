#___________                   
#\__    ___/_ __  ____ _____   
#  |    | |  |  \/    \\__  \  
#  |    | |  |  /   |  \/ __ \_
#  |____| |____/|___|  (____  /
#                    \/     \/ 

import std/[strformat]

const NOP_BYTE: uint8 = 0x90  # NOP byte value

proc generateMac*(bytes: array[6, uint8]): string =
  result = fmt"{bytes[0]:02X}-{bytes[1]:02X}-{bytes[2]:02X}-{bytes[3]:02X}-{bytes[4]:02X}-{bytes[5]:02X}"

proc binToMACs*(filename: string): tuple[arr: cstringArray, len: int] =
  var macs: seq[string] = @[]  # Initialize an empty sequence
  var file: File
  var buffer: array[6, uint8]
  var bytesRead: int
  var totalBytesRead: int = 0
  
  try:
    file = open(filename, fmRead)
    while true:
      bytesRead = file.readBuffer(addr buffer, 6)
      totalBytesRead += bytesRead
      if bytesRead == 0:
        break

      echo fmt"Debug: Read {bytesRead} bytes: {buffer[0]:02X} {buffer[1]:02X} {buffer[2]:02X} {buffer[3]:02X} {buffer[4]:02X} {buffer[5]:02X}"

      if bytesRead < 6:
        echo fmt"Debug: Padding last {6 - bytesRead} bytes with NOP"
        # Pad with NOP bytes if less than 6 bytes are read
        for i in bytesRead..5:
          buffer[i] = NOP_BYTE
      
      macs.add(generateMac(buffer))
      
      if bytesRead < 6:
        break  # Exit after processing the last padded chunk
  finally:
    if file != nil:
      file.close()
  echo fmt"Debug: Total bytes read: {totalBytesRead}"

  result.arr = allocCStringArray(macs)
  result.len = macs.len

# Example usage (can be removed if not needed)
when isMainModule:
  echo "This is a library file and should be imported, not run directly."