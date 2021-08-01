function Get-ProjectDependencies
{
param(
[Parameter(Mandatory)]
[string]$projectName
)
dir $rootFolder -Filter *.csproj -Recurse |
where {$projectName -eq "$($_.BaseName)" |
List-Dependencies
}
function List-Dependencies
{
param(
[Parameter(ValueFromPipeline, Mandatory)]
[System.IO.FileInfo]$project
)
process
{
$projectDependancyFor = $_.BaseName
[xml]$projectXml = Get-Content $_.FullName
$ns = @{ defaultNamespace = "http://schemas.microsoft.com/developer/msbuild/2003" }
$projectXml |
Select-Xml '//defaultNamespace:ProjectReference/defaultNamespace:Name' -Namespace $ns |
foreach { $_.node.InnerText
if (-not (Test-path -path "$rootFolder\ProjectDependancy\$dependancyForProject\DependanciesOf$_.txt"))
{
Get-ProjectDependencies -projectName $_.node.InnerText | Out-File "$rootFolder\ProjectDependancy\$dependancyForProject\DependanciesOf$_.txt"
}
} |
foreach { "[" + $projectDependancyFor + "] -> [" + $_ + "]" }
}
}

[string]$rootFolder = Read-Host "Project root folder "
[string]$dependancyForProject = Read-Host "Project Name "

md "$rootFolder\ProjectDependancy\$dependancyForProject"

Get-ProjectDependencies -projectName "$dependancyForProject" | Out-File "$rootFolder\ProjectDependancy\$dependancyForProject\DependanciesOf$dependancyForProject.txt" -Append

dir "$rootFolder\ProjectDependancy" -Filter *.txt -Recurse | foreach { Get-Content "$rootFolder\ProjectDependancy\$dependancyForProject\$_" | Add-Content -Path "$rootFolder\ProjectDependancy\$dependancyForProject\ALL_$dependancyForProject.log" }
"// Copy file content on https://yuml.me/diagram/scruffy/class/draw to generate cool dependency graph" | Add-Content -Path "$rootFolder\ProjectDependancy\$dependancyForProject\ALL_$dependancyForProject.log"
del "$rootFolder\ProjectDependancy\$dependancyForProject\*.txt"