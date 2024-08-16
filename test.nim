import std/[strutils, net]

proc readBinFileToIpv4Array(filePath: string): seq[string] =
  var ipv4Array: seq[string] = @[]
  let fileContent = readFile(filePath)
  
  for i in countup(0, fileContent.len - 1, 4):
    if i + 3 < fileContent.len:
      let ipBytes = [
        ord(fileContent[i]),
        ord(fileContent[i+1]),
        ord(fileContent[i+2]),
        ord(fileContent[i+3])
      ]
      let ipAddress = $IpAddress(family: IpAddressFamily.IPv4,
                                 address_v4: [ipBytes[0].uint8,
                                              ipBytes[1].uint8,
                                              ipBytes[2].uint8,
                                              ipBytes[3].uint8])
      ipv4Array.add(ipAddress)
  
  return ipv4Array

# Example usage
let filePath = "shellcodes/calc.bin"
let ipv4Array = readBinFileToIpv4Array(filePath)

echo "IPv4 Addresses:"
for ip in ipv4Array:
  echo ip
