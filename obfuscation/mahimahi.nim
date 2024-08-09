#  __  __       _     _ __  __       _     _ 
# |  \/  | __ _| |__ (_)  \/  | __ _| |__ (_)
# | |\/| |/ _` | '_ \| | |\/| |/ _` | '_ \| |
# | |  | | (_| | | | | | |  | | (_| | | | | |
# |_|  |_|\__,_|_| |_|_|_|  |_|\__,_|_| |_|_|
#    

import std/[streams, strutils, sequtils]

proc reverseBytes(buffer: openArray[uint8], start, length: int): seq[uint8] =
  result = newSeq[uint8](length)
  for i in 0..<length:
    result[i] = buffer[start + length - 1 - i]

proc binToUuids*(filename: string): seq[string] =
  let fs = newFileStream(filename, fmRead)
  if fs == nil:
    raise newException(IOError, "Unable to open file: " & filename)
  defer: fs.close()
  var buffer: array[16, uint8]
  var uuids: seq[string] = @[]
  while not fs.atEnd():
    var bytesRead = fs.readData(addr(buffer[0]), 16)
    if bytesRead > 0:
      if bytesRead < 16:
        # If we read less than 16 bytes, pad the rest with zeros
        for i in bytesRead..<16:
          buffer[i] = 0x90

      var reorderedBuffer: array[16, uint8]
      
      # Reverse first 4 bytes
      reorderedBuffer[0..3] = reverseBytes(buffer, 0, 4)
      
      # Reverse bytes 4-5 and 6-7
      reorderedBuffer[4..5] = reverseBytes(buffer, 4, 2)
      reorderedBuffer[6..7] = reverseBytes(buffer, 6, 2)
      
      # Keep bytes 8-15 in original order
      reorderedBuffer[8..15] = buffer[8..15]
      
      let uuid = reorderedBuffer.mapIt(it.toHex(2)).join()
      var formattedUuid = uuid
      formattedUuid.insert("-", 8)
      formattedUuid.insert("-", 13)
      formattedUuid.insert("-", 18)
      formattedUuid.insert("-", 23)
      uuids.add(formattedUuid)
  return uuids

when isMainModule:
  echo "This is a library file and should be imported, not run directly."