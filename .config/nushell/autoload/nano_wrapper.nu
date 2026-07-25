#====================================================================
# Run VS Code if available, otherwise fallback to anti-unix nano
#====================================================================
def nano [
    ...args: string     # The files or arguments you want to pass
    --line-numbers(-l)  # Switch to turn on line numbers for nano fallback
] {
    # Check for installation, a graphical engine, AND that standard input is a terminal
    let vscode_installed = (which code | is-not-empty)

    if ($vscode_installed) {
        # Call the binary explicitly to prevent any argument duplication or array misbehavior
        ^code --reuse-window ...$args e> /dev/null o> /dev/null
    } else {
        let base_flags = ["-A" "-D" "-F" "-G" "-I" "-L" "-M" "-S" "-U" "-Z" "-a" "-q" "-_" "-/"]
        
        let final_flags = if $line_numbers {
            $base_flags | append ["-l"]
        } else {
            $base_flags
        }

        # Safe fallback execution path for minimal/single-user environments
        /usr/bin/nano ...$final_flags ...$args
    }
}

#====================================================================
# Wrapper for VS Code to keep flags active but silence Electron spam
#====================================================================
def --wrapped code [...args: string] {
    # Launch code and immediately dump all stdout/stderr from the wrapper
    ^code ...$args e> /dev/null o> /dev/null
}