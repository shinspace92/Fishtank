#  __  __       _     _ __  __       _     _ 
# |  \/  | __ _| |__ (_)  \/  | __ _| |__ (_)
# | |\/| |/ _` | '_ \| | |\/| |/ _` | '_ \| |
# | |  | | (_| | | | | | |  | | (_| | | | | |
# |_|  |_|\__,_|_| |_|_|_|  |_|\__,_|_| |_|_|
#    

import os
import sequtils
import uuids

proc readBinFileAndConvertToUUIDs*(filePath: string): seq[UUID] =
  if not fileExists(filePath):
    raise newException(IOError, "File not found: " & filePath)

  let fileContent = readFile(filePath)
  result = newSeq[UUID](fileContent.len)

  for i, byte in fileContent:
    result[i] = parseUUID("00000000-0000-0000-0000-000000000" & byte.toHex(2))
