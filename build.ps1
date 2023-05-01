wally install
$folderName = (Split-Path $PSScriptRoot -Leaf)
rojo build --output ".\Bin\$folderName.rbxm" "default.project.json"