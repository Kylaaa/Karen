wally install
$folderName = (Split-Path $PSScriptRoot -Leaf)
rojo build --output ".\Bin\$folderName-Tests.rbxm" "standalone-tests.project.json"