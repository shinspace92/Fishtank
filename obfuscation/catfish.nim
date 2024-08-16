import std/[strformat]

const NOP_BYTE: uint8 = 0x90

proc ipv4fuscate(byte: uint8): uint8 =
  case byte:
    of ord('b'): result = byte + 3
    of ord('i'): result = byte + 15
    of ord('n'): result = byte - 9
    else: result = byte

proc generateIpv4*(ip: uint32): string =
  let
    a: uint8 = ipv4fuscate((ip shr 24).uint8)
    b: uint8 = ipv4fuscate((ip shr 16).uint8)
    c: uint8 = ipv4fuscate((ip shr 8).uint8)
    d: uint8 = ipv4fuscate(ip.uint8)
  result = fmt"{a}.{b}.{c}.{d}"

proc generateIpv4Hex*(a, b, c, d: int): uint32 =
  result = (ipv4fuscate(a.uint8).uint32 shl 24) or
           (ipv4fuscate(b.uint8).uint32 shl 16) or
           (ipv4fuscate(c.uint8).uint32 shl 8) or
           ipv4fuscate(d.uint8).uint32

proc binToIpv4s*(filename: string): tuple[arr: cstringArray, len: int] =
  var ipv4s: seq[string] = @[]  # Initialize an empty sequence
  var buffer: array[4, uint8]
  var bytesRead: int
  var file: File

  try:
    file = open(filename, fmRead)
    while true:
      bytesRead = file.readBuffer(addr buffer, 4)
      if bytesRead == 0:
        break
      elif bytesRead < 4:
        # Pad with zeros if less than 4 bytes are read
        for i in bytesRead..3:
          buffer[i] = NOP_BYTE
      
      let ip = generateIpv4Hex(buffer[0].int, buffer[1].int, buffer[2].int, buffer[3].int)
      ipv4s.add(generateIpv4(ip))
      
      if bytesRead < 4:
        break  # Exit after processing the last padded chunk
  finally:
    if file != nil:
      file.close()

  result.arr = allocCStringArray(ipv4s)
  result.len = ipv4s.len

when isMainModule:
  echo "This is a library file and should be imported, not run directly."