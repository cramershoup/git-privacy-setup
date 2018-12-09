#Requires -Version 4

$VAR_DIR = (Get-Item "$PSScriptRoot\..").FullName
$INSTALL_DIR = (Get-Item "$PSScriptRoot\..\..").FullName

Get-Content "$VAR_DIR\git-privacy-setup\VERSION" | Write-Output
Write-Output ''

if ($INSTALL_DIR.IndexOf(' ') -ge 0) {
    Write-Error "You installed this script at:"
    Write-Error "    $INSTALL_DIR"
    Write-Error "It contains spaces that will cause problems using this script."
    Write-Error "Please reinstall it at a location without any space!" -ErrorAction Stop
}

$PREFIX=$args[0]
function git_set {
    param([String]$Key, [String]$Val)
    if ($Val) {
        & git --no-pager config --local "$Key" "$Val"
        if ($PREFIX) {
            & git --no-pager config --global "$PREFIX.$Key" "$Val"
        }
    } else {
        & git --no-pager config --local --unset "$Key"
        if ($PREFIX) {
            & git --no-pager config --global --unset "$PREFIX.$Key"
        }
    }
}

function git_get {
    param([String]$Key)
    $Val = & git --no-pager config --get "$Key"
    if (!$Val -and $PREFIX) {
        $Val = & git --no-pager config --get --global "$PREFIX.$Key"
    }
    return $Val
}

function mingw_path {
    param([String]$Path)
    $Path = [System.IO.Path]::GetFullPath($Path)
    $drive = $Path.Substring(0, 1).ToLower()
    $Path = $Path.Substring(2).Replace('\', '/').Replace(':', '');
    return '/' + $drive + $Path
}

function decide {
    param($Question, $YesAction, $NoAction)
    while ($true) {
        $response = Read-Host -Prompt "$Question (y/n)"
        if ($response -eq 'y' -or $response -eq 'yes') {
            if ($YesAction) {
                & $YesAction
            }
            break
        }
        elseif ($response -eq 'n' -or $response -eq 'no') {
            if ($NoAction) {
                & $NoAction
            }
            break
        }
        else {
            Write-Host "Please type Y for Yes or N for No"
        }
    }
}

function git_init {
    Write-Host "Initializing Git..."
    & git init
}

function git_dont_init {
    Write-Host "Nothing to do."
    exit
}

if (!(Test-Path ".git")) {
    Write-Host "You are not in a Git root directory."
    decide 'Do you want to initialize current directory as a Git project?' git_init git_dont_init
}

Write-Host "Setup local Git hooks..."
New-Item ".git\hooks" -ItemType Directory -Force | Out-Null
Copy-Item "$VAR_DIR\git-privacy-setup\post-commit" ".git\hooks\post-commit" -Force | Out-Null

function git_set_profile {
    $script:git_name = Read-Host -Prompt "Enter a name"
    $script:git_email = Read-Host -Prompt "Enter a email"
}

$git_name = git_get user.name
$git_email = git_get user.email
if ($git_name -and $git_email) {
    Write-Host "You current Git commit profile is:"
    Write-Host "    $git_name <$git_email>"
    decide 'Do you want to use this profile?' '' git_set_profile
}
else {
    Write-Host "You don't have a Git commit profile."
    Write-Host "Setup a local profile now..."
    git_set_profile
}

git_set user.name "$git_name"
git_set user.email "$git_email"
$script:git_name = git_get user.name
$script:git_email = git_get user.email
Write-Host "Local Git commit profile set to:"
Write-Host "    $git_name <$git_email>"

function git_set_gpgsign {
    $script:gpgsign = "true"
}

$gpgsign = git_get commit.gpgsign
if ($gpgsign -ne "true") {
    decide 'Do you want to sign commits with a GPG key?' git_set_gpgsign
}
git_set commit.gpgsign "$gpgsign"

function git_set_signingkey {
    $script:signingkey = Read-Host -Prompt "Enter a GPG key ID"
}

if ($gpgsign -eq "true") {
    $signingkey = git_get user.signingkey
    if ($signingkey) {
        Write-Host "You have this GPG key ID in your Git config:"
        Write-Host "    $signingkey"
        decide 'Do you want to use this GPG key?' '' git_set_signingkey
    }
    else {
        git_set_signingkey
    }
    git_set user.signingkey "$signingkey"
}

function git_set_gpg_program {
    $script:gpg_program = Read-Host -Prompt "Enter the path to GPG executable"
}

if ($gpgsign -eq "true") {
    $gpg_program = git_get gpg.program
    if ($gpg_program) {
        Write-Host "You have this GPG program in your Git config:"
        Write-Host "    $gpg_program"
        decide 'Do you want to use this GPG program?' '' git_set_gpg_program
    }
    else {
        try {
            $gpg_program = (Get-Item (Get-Command gpg).Path).FullName
            Write-Host "You have this GPG program in your path:"
            Write-Host "    $gpg_program"
            decide 'Do you want to use this GPG program?' '' git_set_gpg_program
        }
        catch {
            Write-Host "Can't find a GPG program!"
            Write-Host "Setup GPG program path now..."
            git_set_gpg_program
        }
    }
    git_set gpg.program "$gpg_program"
}

function git_set_ssh_ident {
    $script:ssh_ident = Read-Host -Prompt "Enter the SSH private key path (e.g. C:\Users\me\.ssh\id_rsa)"
    if (Test-Path $ssh_ident) {
        $script:ssh_ident = mingw_path $ssh_ident
    }
}

$ssh_ident = git_get ssh.ident
if ($ssh_ident) {
    if (Test-Path $ssh_ident) {
        $script:ssh_ident = mingw_path $ssh_ident
    }
    Write-Host "You have this SSH private key in your Git config:"
    Write-Host "    $ssh_ident"
    decide 'Do you want to use this SSH private key?' '' git_set_ssh_ident
}
else {
    decide 'Do you want to specify a SSH key?' git_set_ssh_ident
}
git_set ssh.ident "$ssh_ident"

function git_set_proxy {
    $script:proxy = Read-Host -Prompt "Enter the SOCKS5 proxy ( [user:pass@]host:port )"
}

$proxy = git_get proxy.socks5
if ($proxy) {
    Write-Host "You have this SOCKS5 proxy in your Git config:"
    Write-Host "    $proxy"
    decide 'Do you want to use this SOCKS5 proxy?' '' git_set_proxy
}
else {
    decide 'Do you want to use a SOCKS5 proxy?' git_set_proxy
}
git_set proxy.socks5 "$proxy"

function git_set_connect {
    $script:connect = Read-Host -Prompt "Enter the path to connect executable (e.g. /c/bin/connect)"
    if (Test-Path $connect) {
        $script:connect = mingw_path $connect
    }
}

function find_system_connect {
    try {
        $script:connect = (Get-Item (Get-Command connect).Path).FullName
        $script:connect = mingw_path $connect
        Write-Host "You have this connect executable in your path:"
        Write-Host "    $connect"
        decide 'Do you want to use this connect executable?' '' git_set_connect
    }
    catch {
        Write-Host "Can't find a connect executable!"
        Write-Host "Setup connect executable path now..."
        git_set_connect
    }
}

function find_precompiled_connect {
    $script:connect = "$VAR_DIR\connect\win\"
    $arch = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
    if ($arch -eq "64-bit") {
        $script:connect += "x64"
    }
    else {
        $script:connect += "x86"
    }
    $script:connect += "\connect.exe"
    if (Test-Path $connect -PathType Leaf) {
        $script:connect = mingw_path $connect
        Write-Host "We have provided a precompiled executable at:"
        Write-Host "    $connect"
        decide 'Do you want to use this connect executable?' '' find_system_connect
    }
    else {
        find_system_connect
    }
}

if ($proxy) {
    Write-Host "Using SOCKS5 proxy with Git over SSH needs the connect executable."
    Write-Host "It's recommended to obtain the patched version from:"
    Write-Host "    https://github.com/cramershoup/connect.c"
    Write-Host "Which supports inline password and uses NOAUTH if no explicit login."
    $connect = git_get connect.program
    if ($connect) {
        Write-Host "You have this connect executable in your Git config:"
        Write-Host "    $connect"
        decide 'Do you want to use this connect executable?' '' find_precompiled_connect
    }
    else {
        find_precompiled_connect
    }
    git_set connect.program "$connect"
}

if ($ssh_ident -and $proxy) {
    $ssh = "ssh"
    if ($ssh_ident) {
        $ssh += " -i '$ssh_ident'"
    }
    if ($proxy) {
        $ssh += " -o 'ProxyCommand=$connect -S $proxy %h %p'"
    }
    git_set http.proxy "socks5h://$proxy"
    git_set core.sshCommand $ssh
}

if (!$proxy) {
    git_set http.proxy
}

Write-Host "Your Git setup is completed!"
