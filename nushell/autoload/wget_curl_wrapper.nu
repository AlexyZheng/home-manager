# Cross-compatible downloader wrapper that safely routes to available system binaries
def --wrapped wget [...rest: string] {
    let has_curl = (which curl | is-empty | not $in)
    let has_wget = (which wget | is-empty | not $in)

    if not $has_curl and not $has_wget {
        print $"(ansi red)Error: Neither 'curl' nor 'wget' could be located on this system.(ansi reset)"
        return
    }

    # Case 1: Simple single-link paste (Strip token query strings and download)
    if ($rest | length) == 1 and not ($rest.0 | str starts-with "-") {
        let url = ($rest | first)
        let clean_url = ($url | split row "?" | first)
        
        if $has_curl {
            print $"[Backend: curl] Stripping token parameters and saving file..."
            ^curl -L -O -J --retry 3 $clean_url
        } else {
            print $"[Backend: wget] Stripping token parameters and saving file..."
            ^wget -N $clean_url
        }

    # Case 2: Multi-parameter script configurations (Intercept custom output flags)
    } else if ($rest | length) > 1 {
        let has_short_out = ($rest | any {|x| $x == "-O"})
        let has_long_out = ($rest | any {|x| $x | str starts-with "--output-document=" or $x | str starts-with "--output-file="})

        if $has_short_out or $has_long_out {
            let url = ($rest | last)
            let clean_url = ($url | split row "?" | first)
            
            # Extract the user's custom file output name destination
            let filename = if $has_short_out {
                let o_index = ($rest | enumerate | where item == "-O" | first | get index)
                let val_index = ($o_index + 1)
                if $val_index < ($rest | length) { $rest | get $val_index } else { $clean_url | path parse | get stem }
            } else {
                # Modern 'where' replacement deployed here to satisfy current syntax rules
                $rest | where {|x| $x | str starts-with "--output-document=" or $x | str starts-with "--output-file="} | first | split row "=" | last
            }

            if $has_curl {
                print $"[Backend: curl] Mapping destination flag: ($filename)"
                ^curl -L --retry 3 $clean_url -o $filename
            } else {
                print $"[Backend: wget] Executing native destination flag: ($filename)"
                ^wget ...$rest
            }
        } else {
            # Case 3: Pass general mixed flag options straight to whichever binary is live
            if $has_wget { ^wget ...$rest } else { ^curl ...$rest }
        }
    } else {
        if $has_wget { ^wget ...$rest } else { ^curl ...$rest }
    }
}

# Clean curl wrapper that fails gracefully or sanitizes raw queries
def --wrapped curl [...rest: string] {
    if (which curl | is-empty) {
        print $"(ansi red)Error: The 'curl' command is not installed on this system.(ansi reset)"
        return
    }

    if ($rest | length) == 1 and not ($rest.0 | str starts-with "-") {
        let url = ($rest | first)
        let clean_url = ($url | split row "?" | first)
        ^curl $clean_url
    } else {
        ^curl ...$rest
    }
}
