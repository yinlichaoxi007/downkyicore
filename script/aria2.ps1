param(
    [ValidateSet("x86","x64")]
    [string]$arch = "x64",
    [switch]$Force
)

begin {
    # 强制设置进程级编码
    $PSDefaultParameterValues['*:Encoding'] = 'UTF8'
    [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
}

process {
    function Create-Dir($dir) {
        if (!(Test-Path -LiteralPath $dir)) {
            New-Item -LiteralPath $dir -ItemType "directory"
        }
    }
    
    try {
        # 初始化目录
        Create-Dir ".\downloads"
        
        $url="";
        if ($arch -eq "x86") {
            $url="https://github.com/yaobiao131/downkyi-aria2-static-build/releases/download/1.37.0/aria2-i686-w64-mingw32_static.zip";
        }
        
        if ($arch -eq "x64") {
            $url="https://github.com/yaobiao131/downkyi-aria2-static-build/releases/download/1.37.0/aria2-x86_64-w64-mingw32_static.zip";
        }
        
        # 下载文件
        $downloadPath = ".\downloads\aria2-$arch.zip"
        # 强制下载判断
        if ($Force) {
            Write-Host "强制下载已启用" -ForegroundColor Magenta
            Remove-Item -LiteralPath $downloadPath -Force -ErrorAction SilentlyContinue
        }
        # 文件存在性检查与完整性验证
        if (Test-Path -LiteralPath $downloadPath) {
            $fileInfo = Get-Item -LiteralPath $downloadPath
            # 基础校验：文件大小需超过0MB
            if ($fileInfo.Length -gt 0MB) {
                Write-Host "发现已缓存文件，跳过下载（大小：$($fileInfo.Length/1MB.ToString('0.0')) MB）" -ForegroundColor DarkGray
                $skipDownload = $true
            }
            else {
                Write-Host "检测到不完整文件，重新下载..." -ForegroundColor Yellow
                Remove-Item -LiteralPath $downloadPath -Force
            }
        }
        if(-not $skipDownload){
            Write-Host "正在下载: $url" -ForegroundColor Cyan
            $retryCount = 0
            do
            {
                try
                {
                    Start-BitsTransfer -Source $url -Destination $downloadPath -ErrorAction Stop
                    break
                }
                catch
                {
                    $retryCount++
                    if ($retryCount -ge 3)
                    {
                        Write-Host "下载失败，请检查网络连接或代理设置。" -ForegroundColor Red
                        throw
                    }
                    Write-Host "下载失败，第${retryCount}次重试..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                }
            } while ($true)
        }
        
        # 解压处理
        $expandPath = ".\aria2_temp"
        Remove-Item -LiteralPath $expandPath -Recurse -Force -ErrorAction SilentlyContinue
        Expand-Archive -LiteralPath $downloadPath -DestinationPath $expandPath -Force
        
        # 查找可执行文件
        $exePath = Get-ChildItem -LiteralPath $expandPath -Recurse -Filter "aria2c.exe" | 
                   Select-Object -First 1 -ExpandProperty FullName
        
        if (-not $exePath) {
            # 显式输出调试信息
            Write-Host "解压目录内容：" -ForegroundColor Yellow
            Get-ChildItem -LiteralPath $expandPath -Recurse | Format-Table FullName
            throw "在解压文件中未找到 aria2c.exe"
        }
        
        # 复制文件
        $destDir="..\DownKyi.Core\Binary\win-$arch\aria2\"
        Create-Dir $destDir
        Copy-Item -LiteralPath $exePath $destDir -Force
        Write-Host "成功复制到: $destDir" -ForegroundColor Green
        
    } catch {
            Write-Host "错误发生: $_" -ForegroundColor Red
            exit 1
    }finally {
        # 清理临时文件
        try {
            if ($expandPath -and (Test-Path -LiteralPath $expandPath -ErrorAction SilentlyContinue)) {
                Remove-Item -LiteralPath $expandPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "已删除临时目录: $expandPath" -ForegroundColor DarkGray
            }
        }
        catch {
            Write-Host "清理过程中出现异常: $_" -ForegroundColor Yellow
        }
    }
}