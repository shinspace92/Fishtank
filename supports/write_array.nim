import std/[os, strutils]

proc write_array*(obfs_method: string, arr: cstringArray, len: int): string =
  let outputFilename = "../compile/" & obfs_method & "_compile.nim"
  let tempFilename = outputFilename & ".temp"
  var inFile: File
  var outFile: File
  try:
      inFile = open(outputFilename, fmRead)
      outFile = open(tempFilename, fmWrite)
      
      var insideArraySection = false
      for line in inFile.lines:
        if line.strip().startsWith("var arr ="):
          insideArraySection = true
          outFile.writeLine("var arr = allocCStringArray([")
          for i in 0..<len:
            if i >= len: break
            outFile.writeLine("  \"" & $arr[i] & "\",")
          outFile.writeLine("])")
        elif line.strip().startsWith("var count"):
          outFile.writeLine("var count: int = " & $len)
          insideArraySection = false
        elif not insideArraySection:
          outFile.writeLine(line)
  finally:
      if not inFile.isNil: inFile.close()
      if not outFile.isNil: outFile.close()
        # Replace the original file with the updated one
  try:
      removeFile(outputFilename)
      moveFile(tempFilename, outputFilename)
  except:
      echo "Error replacing file: ", getCurrentExceptionMsg()

  result = outputFilename
when isMainModule:
  echo "This is a library file and should be imported, not run directly."