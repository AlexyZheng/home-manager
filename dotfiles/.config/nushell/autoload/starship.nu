# this file is both a valid
# - overlay which can be loaded with `overlay use starship_vscode.nu`
# - module which can be used with `use starship_vscode.nu`
# - script which can be used with `source starship_vscode.nu`
#
# Merged: full starship.nu prompt configuration + starship_vscode.nu
# VS Code override workaround (pre_prompt hook re-asserts the prompt
# commands and strips secondary indicators to prevent layout conflicts).

export-env { $env.STARSHIP_SHELL = "nu"; load-env {
    STARSHIP_SESSION_KEY: (random chars -l 16)

    # VS Code: strip secondary indicators to prevent layout conflicts
    PROMPT_MULTILINE_INDICATOR: "::: "

    # Does not play well with default character module.
    # TODO: Also Use starship vi mode indicators?
    PROMPT_INDICATOR: ""

    PROMPT_COMMAND: {||
        (
            # The initial value of `$env.CMD_DURATION_MS` is always `0823`, which is an official setting.
            # See https://github.com/nushell/nushell/discussions/6402#discussioncomment-3466687.
            let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
            ^/usr/bin/starship prompt
                --cmd-duration $cmd_duration
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
                ...(
                    if (which "job list" | where type == built-in | is-not-empty) {
                        ["--jobs", (job list | length)]
                    } else {
                        []
                    }
                )
        )
    }

    config: ($env.config? | default {} | merge {
        render_right_prompt_on_last_line: true
    })

    PROMPT_COMMAND_RIGHT: {||
        (
            let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
            ^/usr/bin/starship prompt
                --right
                --cmd-duration $cmd_duration
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
                ...(
                    if (which "job list" | where type == built-in | is-not-empty) {
                        ["--jobs", (job list | length)]
                    } else {
                        []
                    }
                )
        )
    }

    # VS Code: strip VI mode indicators
    PROMPT_INDICATOR_VI_INSERT: ""
    PROMPT_INDICATOR_VI_NORMAL: ""
}}

# VS Code override hook (top-level, matching original starship_vscode.nu).
# Also covers `source starship_vscode.nu` (export-env only fires for use/overlay use).
$env.config = ($env.config? | default {} | merge {
    hooks: {
        pre_prompt: [{ ||
            # Triggers right before the prompt draws, neutralizing VS Code's
            # closure-mapping override loop.
            $env.PROMPT_COMMAND = {||
                (
                    let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
                    ^/usr/bin/starship prompt
                        --cmd-duration $cmd_duration
                        $"--status=($env.LAST_EXIT_CODE)"
                        --terminal-width (term size).columns
                        ...(
                            if (which "job list" | where type == built-in | is-not-empty) {
                                ["--jobs", (job list | length)]
                            } else {
                                []
                            }
                        )
                )
            }
            $env.PROMPT_COMMAND_RIGHT = {||
                (
                    let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
                    ^/usr/bin/starship prompt
                        --right
                        --cmd-duration $cmd_duration
                        $"--status=($env.LAST_EXIT_CODE)"
                        --terminal-width (term size).columns
                        ...(
                            if (which "job list" | where type == built-in | is-not-empty) {
                                ["--jobs", (job list | length)]
                            } else {
                                []
                            }
                        )
                )
            }
        }]
    }
})

# 4. Strip secondary indicators to prevent layout conflicts
$env.PROMPT_MULTILINE_INDICATOR = "::: "
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""