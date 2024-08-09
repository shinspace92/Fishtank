#  _____ _     _   _____           _    
# |  ___(_)___| |_|_   _|_ _ _ __ | | __
# | |_  | / __| '_ \| |/ _` | '_ \| |/ /
# |  _| | \__ \ | | | | (_| | | | |   < 
# |_|   |_|___/_| |_|_|\__,_|_| |_|_|\_\
#                                       

import winim
import os
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
      let uuids = binToUuids(filePath)
      echo uuids, uuids.len
main()
