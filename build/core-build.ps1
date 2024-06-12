$core_version = $args[0]
$plugins_root = $args[1]

$current_dir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$parent_dir = Split-Path -Parent $current_dir
$core_dir = Join-Path $parent_dir "core"
$plugins_dir = Join-Path $core_dir "plugins"

if (-not (Test-Path $plugins_dir)) {
    New-Item -ItemType Directory -Path $plugins_dir | Out-Null
}

Copy-Item -Path "$current_dir\resources\node" -Destination "$plugins_dir" -Recurse
Expand-Archive -Path "$current_dir\resources\npm.zip" -DestinationPath "$plugins_dir" -Force
# 7zip unzip npm.zip will cause npx error
# $zipFilePath = Join-Path -Path $current_dir -ChildPath "resources\npm.zip"
# $7zExePath = Join-Path -Path $current_dir -ChildPath "7z\7za.exe"
# & "$7zExePath" x "$zipFilePath" -o"$plugins_dir" -y
Copy-Item -Path "$current_dir\resources\package.json" -Destination "$plugins_dir" -Force
Copy-Item -Path "$current_dir\resources\package-lock.json" -Destination "$plugins_dir" -Force
Copy-Item -Path "$plugins_root\about" -Destination "$plugins_dir" -Recurse -Force
Copy-Item -Path "$plugins_root\compile-dart-sass" -Destination "$plugins_dir" -Recurse -Force
Copy-Item -Path "$plugins_root\compile-less" -Destination "$plugins_dir" -Recurse -Force
Copy-Item -Path "$plugins_root\uni_modules" -Destination "$plugins_dir" -Recurse -Force
Copy-Item -Path "$plugins_root\uni_helpers" -Destination "$plugins_dir" -Recurse -Force

# uniapp-cli-vite
$uniapp_cli_vite_dir = "$plugins_dir\uniapp-cli-vite"
New-Item -ItemType Directory -Path $uniapp_cli_vite_dir | Out-Null
Copy-Item -Path "$plugins_root\uniapp-cli-vite\index.js" -Destination $uniapp_cli_vite_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli-vite\vite.config.js" -Destination $uniapp_cli_vite_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli-vite\package.json" -Destination $uniapp_cli_vite_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli-vite\package.nls.json" -Destination $uniapp_cli_vite_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli-vite\package.nls.zh_CN.json" -Destination $uniapp_cli_vite_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli-vite\yarn.lock" -Destination $uniapp_cli_vite_dir -Force

$package_json_path = "$uniapp_cli_vite_dir\package.json"
$package_json = Get-Content $package_json_path | ConvertFrom-Json
$package_json.devDependencies.PSObject.Properties.Remove("@esbuild/win32-ia32")
$package_json.devDependencies.PSObject.Properties.Remove("@esbuild/win32-x64")
if ($package_json.devDependencies.PSObject.Properties.Name -contains "@esbuild/linux-x64") {
    $package_json.devDependencies."@esbuild/linux-x64" = "0.20.1"
}
else {
    $package_json.devDependencies | Add-Member -MemberType NoteProperty -Name "@esbuild/linux-x64" -Value "0.20.1"
}
$package_json | ConvertTo-Json -Depth 100 | Set-Content $package_json_path

# node-sass
$uniapp_node_sass_dir = "$plugins_dir\compile-node-sass"
New-Item -ItemType Directory -Path $uniapp_node_sass_dir | Out-Null
Copy-Item -Path "$plugins_root\compile-node-sass\package.json" -Destination $uniapp_node_sass_dir -Force
Copy-Item -Path "$plugins_root\compile-node-sass\package.nls.en.json" -Destination $uniapp_node_sass_dir -Force
Copy-Item -Path "$plugins_root\compile-node-sass\package.nls.json" -Destination $uniapp_node_sass_dir -Force
Copy-Item -Path "$plugins_root\compile-node-sass\package.nls.zh-cn.json" -Destination $uniapp_node_sass_dir -Force
Copy-Item -Path "$plugins_root\compile-node-sass\package-lock.json" -Destination $uniapp_node_sass_dir -Force

# uniapp-cli
$uniapp_cli_dir = "$plugins_dir\uniapp-cli"
New-Item -ItemType Directory -Path $uniapp_cli_dir | Out-Null
Copy-Item -Path "$plugins_root\uniapp-cli\bin" -Destination "$uniapp_cli_dir" -Recurse -Force
Copy-Item -Path "$plugins_root\uniapp-cli\patches" -Destination "$uniapp_cli_dir" -Recurse -Force
Copy-Item -Path "$plugins_root\uniapp-cli\public" -Destination "$uniapp_cli_dir" -Recurse -Force
Copy-Item -Path "$plugins_root\uniapp-cli\types" -Destination "$uniapp_cli_dir" -Recurse -Force
Copy-Item -Path "$plugins_root\uniapp-cli\package.json" -Destination $uniapp_cli_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli\babel.config.js" -Destination $uniapp_cli_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli\package.nls.json" -Destination $uniapp_cli_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli\package.nls.zh_CN.json" -Destination $uniapp_cli_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli\postcss.config.js" -Destination $uniapp_cli_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli\tsconfig.json" -Destination $uniapp_cli_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli\update.txt" -Destination $uniapp_cli_dir -Force
Copy-Item -Path "$plugins_root\uniapp-cli\yarn.lock" -Destination $uniapp_cli_dir -Force

Set-Location -Path $parent_dir
$tarFilePath = "core-$core_version.tar"
& $current_dir\7z\7za.exe a -ttar $tarFilePath "core" -xr!"__MACOSX" -xr!".DS_Store"
$tarGzFilePath = "core-$core_version.tar.gz"
& $current_dir\7z\7za.exe a -tgzip $tarGzFilePath $tarFilePath
Remove-Item -Path $tarFilePath
Remove-Item -Path $core_dir -Force -Recurse