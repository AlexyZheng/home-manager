# Pure curl downloader replacing wget entirely with zero bloat
def --wrapped wget [...rest: string] {
    # Case 1: Simple single-link paste (Strip token query strings and download)
    if ($rest | length) == 1 and not ($rest.0 | str starts-with "-") {
        let url = ($rest | first)
        let clean_url = ($url | split row "?" | first)
        print $"[Smart-Download] Stripping token parameters and saving file..."
        ^curl -L -O -J --no-clobber --retry 5 $clean_url

    # Case 2: Standard wget parameter scripts (Translate -O on-the-fly to curl)
    } else if ($rest | length) > 1 {
        let has_short_out = ($rest | any {|x| $x == "-O"})
        let has_long_out = ($rest | any {|x| $x | str starts-with "--output-document="})

        if $has_short_out or $has_long_out {
            let url = ($rest | last)
            let clean_url = ($url | split row "?" | first)
            
            # Find the user's custom file output name destination
            let filename = if $has_short_out {
                let o_index = ($rest | enumerate | where item == "-O" | first | get index)
                let val_index = ($o_index + 1)
                if $val_index < ($rest | length) { $rest | get $val_index } else { $clean_url | path parse | get stem }
            } else {
                $rest | filter {|x| $x | str starts-with "--output-document="} | first | split row "=" | last
            }

            print $"[Smart-Translate] Redirecting flag to curl destination: ($filename)"
            ^curl -L --retry 5 $clean_url -o $filename
        } else {
            # Case 3: Pass any other standard flags straight down into curl
            ^curl ...$rest
        }
    } else {
        ^curl ...$rest
    }
}

# Clean curl wrapper that ONLY strips query parameters on raw URLs
def --wrapped curl [...rest: string] {
    if ($rest | length) == 1 and not ($rest.0 | str starts-with "-") {
        let url = ($rest | first)
        let clean_url = ($url | split row "?" | first)
        ^curl $clean_url
    } else {
        ^curl ...$rest
    }
}
