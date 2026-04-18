# Jujutsu shortcuts for common commit, bookmark, and push flows.

$script:EnvironmentJjExecutable = (Get-Command jj.exe -CommandType Application -ErrorAction SilentlyContinue |
  Select-Object -First 1 -ExpandProperty Source)

function Invoke-JjNative {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Arguments
  )

  if (-not $script:EnvironmentJjExecutable) {
    Write-Error 'jj.exe was not found on PATH.'
    return
  }

  & $script:EnvironmentJjExecutable @Arguments
}

function Invoke-JjStep {
  param(
    [Parameter(Mandatory = $true)]
    [string[]] $Arguments
  )

  Invoke-JjNative @Arguments

  if ($LASTEXITCODE -ne 0) {
    Write-Error "jj $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    return $false
  }

  return $true
}

function Get-JjCurrentBookmark {
  param(
    [string] $Default = 'main'
  )

  if (-not $script:EnvironmentJjExecutable) {
    return $Default
  }

  $bookmarkLines = & $script:EnvironmentJjExecutable bookmark list -r '@' 2>$null

  if ($LASTEXITCODE -ne 0) {
    return $Default
  }

  $bookmarks = @($bookmarkLines |
    ForEach-Object {
      if ($_ -match '^\s*([^:\s]+):') {
        $Matches[1]
      }
    } |
    Where-Object { $_ })

  if ($bookmarks.Count -eq 1) {
    return $bookmarks[0]
  }

  if ($Default -and ($bookmarks -contains $Default)) {
    return $Default
  }

  return $Default
}

function Show-JjPushShortcutHelp {
  @'
Usage:
  jj push "commit message" [bookmark]
  jj push -m "commit message" [-b bookmark] [-r remote]
  jjp "commit message" [bookmark]

Flow:
  jj describe -m <message>
  jj bookmark move <bookmark> --to @
  jj git push --bookmark <bookmark>

If no bookmark is supplied, the shortcut uses the single local bookmark at @.
If that cannot be determined, it falls back to main.
'@
}

function Invoke-JjPush {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0)]
    [Alias('m')]
    [string] $Message,

    [Parameter(Position = 1)]
    [Alias('b')]
    [string] $Bookmark,

    [Alias('r')]
    [string] $Remote,

    [switch] $NoPush,
    [switch] $Help
  )

  if ($Help -or -not $Message) {
    Show-JjPushShortcutHelp
    return
  }

  if (-not $Bookmark) {
    $Bookmark = Get-JjCurrentBookmark -Default 'main'
  }

  if (-not (Invoke-JjStep -Arguments @('describe', '-m', $Message))) {
    return
  }

  if (-not (Invoke-JjStep -Arguments @('bookmark', 'move', $Bookmark, '--to', '@'))) {
    return
  }

  if ($NoPush) {
    return
  }

  $pushArguments = @('git', 'push', '--bookmark', $Bookmark)

  if ($Remote) {
    $pushArguments += @('--remote', $Remote)
  }

  [void] (Invoke-JjStep -Arguments $pushArguments)
}

function Invoke-JjPushFromArguments {
  param(
    [string[]] $ShortcutArguments
  )

  $message = $null
  $bookmark = $null
  $remote = $null
  $noPush = $false

  for ($index = 0; $index -lt $ShortcutArguments.Count; $index++) {
    $argument = $ShortcutArguments[$index]
    $option = $argument.ToLowerInvariant()

    switch ($option) {
      { $_ -in @('--help', '-help', '-h', '-?') } {
        Show-JjPushShortcutHelp
        return
      }
      { $_ -in @('--message', '-message', '-m') } {
        $index++
        $message = $ShortcutArguments[$index]
        continue
      }
      { $_ -in @('--bookmark', '-bookmark', '-b') } {
        $index++
        $bookmark = $ShortcutArguments[$index]
        continue
      }
      { $_ -in @('--remote', '-remote', '-r') } {
        $index++
        $remote = $ShortcutArguments[$index]
        continue
      }
      { $_ -in @('--no-push', '-no-push', '-nopush') } {
        $noPush = $true
        continue
      }
      default {
        if (-not $message) {
          $message = $argument
          continue
        }

        if (-not $bookmark) {
          $bookmark = $argument
          continue
        }

        Write-Error "Unexpected jj push argument: $argument"
        return
      }
    }
  }

  Invoke-JjPush -Message $message -Bookmark $bookmark -Remote $remote -NoPush:$noPush
}

function Show-JjMergeToMainShortcutHelp {
  @'
Usage:
  jj merge-main <source-bookmark> [message]
  jj merge-main -b <source-bookmark> [-m "merge message"] [-t main] [-r remote]
  jjmm <source-bookmark> [message]

Flow:
  jj new <target-bookmark> <source-bookmark> -m <message>
  jj bookmark move <target-bookmark> --to @
  jj git push

The target bookmark defaults to main. If no message is supplied, the shortcut
uses "Merge <source-bookmark> into <target-bookmark>".
'@
}

function Test-JjCurrentChangeHasConflict {
  if (-not $script:EnvironmentJjExecutable) {
    return $false
  }

  $conflictStatus = & $script:EnvironmentJjExecutable log -r '@' --no-graph -T "if(conflict, 'conflict', '')" 2>$null

  if ($LASTEXITCODE -ne 0) {
    return $false
  }

  return (($conflictStatus -join '').Trim() -eq 'conflict')
}

function Invoke-JjMergeToMain {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0)]
    [Alias('b')]
    [string] $Branch,

    [Parameter(Position = 1)]
    [Alias('m')]
    [string] $Message,

    [Alias('t')]
    [string] $Target = 'main',

    [Alias('r')]
    [string] $Remote,

    [switch] $NoPush,
    [switch] $Help
  )

  if ($Help) {
    Show-JjMergeToMainShortcutHelp
    return
  }

  if (-not $Branch) {
    $Branch = Get-JjCurrentBookmark -Default $null
  }

  if (-not $Branch -or $Branch -eq $Target) {
    Write-Error "Pass the source bookmark to merge into $Target, for example: jj merge-main feature-branch"
    return
  }

  if (-not $Message) {
    $Message = "Merge $Branch into $Target"
  }

  if (-not (Invoke-JjStep -Arguments @('new', $Target, $Branch, '-m', $Message))) {
    return
  }

  if (Test-JjCurrentChangeHasConflict) {
    Write-Warning 'The merge commit has conflicts. Resolve them before moving the target bookmark or pushing.'
    return
  }

  if (-not (Invoke-JjStep -Arguments @('bookmark', 'move', $Target, '--to', '@'))) {
    return
  }

  if ($NoPush) {
    return
  }

  $pushArguments = @('git', 'push', '--bookmark', $Target)

  if ($Remote) {
    $pushArguments += @('--remote', $Remote)
  }

  [void] (Invoke-JjStep -Arguments $pushArguments)
}

function Invoke-JjMergeToMainFromArguments {
  param(
    [string[]] $ShortcutArguments
  )

  $branch = $null
  $message = $null
  $target = 'main'
  $remote = $null
  $noPush = $false

  for ($index = 0; $index -lt $ShortcutArguments.Count; $index++) {
    $argument = $ShortcutArguments[$index]
    $option = $argument.ToLowerInvariant()

    switch ($option) {
      { $_ -in @('--help', '-help', '-h', '-?') } {
        Show-JjMergeToMainShortcutHelp
        return
      }
      { $_ -in @('--branch', '-branch', '--bookmark', '-bookmark', '-b') } {
        $index++
        $branch = $ShortcutArguments[$index]
        continue
      }
      { $_ -in @('--message', '-message', '-m') } {
        $index++
        $message = $ShortcutArguments[$index]
        continue
      }
      { $_ -in @('--target', '-target', '-t') } {
        $index++
        $target = $ShortcutArguments[$index]
        continue
      }
      { $_ -in @('--remote', '-remote', '-r') } {
        $index++
        $remote = $ShortcutArguments[$index]
        continue
      }
      { $_ -in @('--no-push', '-no-push', '-nopush') } {
        $noPush = $true
        continue
      }
      default {
        if (-not $branch) {
          $branch = $argument
          continue
        }

        if (-not $message) {
          $message = $argument
          continue
        }

        Write-Error "Unexpected jj merge-main argument: $argument"
        return
      }
    }
  }

  Invoke-JjMergeToMain -Branch $branch -Message $message -Target $target -Remote $remote -NoPush:$noPush
}

Set-Alias -Name jjp -Value Invoke-JjPush
Set-Alias -Name jjmm -Value Invoke-JjMergeToMain

function jj {
  [CmdletBinding(PositionalBinding = $false)]
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Arguments
  )

  if ($Arguments.Count -eq 0) {
    Invoke-JjNative
    return
  }

  $command = $Arguments[0]
  $remainingArguments = @()

  if ($Arguments.Count -gt 1) {
    $remainingArguments = $Arguments[1..($Arguments.Count - 1)]
  }

  switch ($command) {
    'push' {
      Invoke-JjPushFromArguments -ShortcutArguments $remainingArguments
      return
    }
    'merge-main' {
      Invoke-JjMergeToMainFromArguments -ShortcutArguments $remainingArguments
      return
    }
    default {
      Invoke-JjNative @Arguments
      return
    }
  }
}
