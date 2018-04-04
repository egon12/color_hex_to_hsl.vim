function! ToHSL() 
    call ColorHexToRGB()
    call ColorRGBToHSL()

endfunction

function! ColorHexToRGB()
    let lnum = 1
    while lnum <= line("$")
        call ColorHexToRGBSingle(lnum)
        let lnum = lnum + 1
    endwhile
endfunction

function! ColorRGBToHSL() 
    let lnum = 1
    while lnum <= line("$")
        call ColorRGBToHSLSingle(lnum)
        call ColorRGBAToHSLASingle(lnum)
        let lnum = lnum + 1
    endwhile
endfunction

function! AddHSLNumber(addition)
    let lnum = 1
    while lnum <= line("$")
        call AddHslNumberSingle(lnum, a:addition)
        let lnum = lnum + 1
    endwhile

    let l:save = winsaveview()
    %s/hslat(/hsla(/g
    call winrestview(l:save)
endfunction

function! ColorHexToRGBSingle(line_number)
    let hex_color = []
    let pattern = '#\([A-Fa-f0-9]\{2}\)\([A-Fa-f0-9]\{2}\)\([A-Fa-f0-9]\{2}\)'
    let allstr = getline(a:line_number)
    let hex_color = matchlist(allstr, pattern)
    
    while hex_color != []
        let int_r = str2nr(hex_color[1], '16')
        let int_g = str2nr(hex_color[2], '16')
        let int_b = str2nr(hex_color[3], '16')

        let int_rgb = "rgb(" . int_r . ", " . int_g . ", " . int_b . ")"
        let new_line_content = substitute(allstr, hex_color[0], int_rgb, "")
        let result = setline(a:line_number, new_line_content)

        let allstr = getline(a:line_number)
        let hex_color = matchlist(allstr, pattern)
    endwhile
endfunction

function! ColorRGBToHSLSingle(lnum)
    let pattern = 'rgb\W*(\W*\(\d\{1,3}\)\W*,\W*\(\d\{1,3}\)\W*,\W*\(\d\{1,3}\)\W*)'
    let allstr = getline(a:lnum)
    let rgb_color = matchlist(allstr, pattern)

    while rgb_color != []

        let hsl = RGBToHSLNumber(rgb_color)
        let hsl_color = "hsla(" . hsl[0] . ", " . hsl[1] . "%, " . hsl[2] . "%, 1)"
        let new_line_content = substitute(allstr, rgb_color[0], hsl_color, "")
        let result = setline(a:lnum, new_line_content)

        let allstr = getline(a:lnum)
        let rgb_color = matchlist(allstr, pattern)
    endwhile
endfunction

function! ColorRGBAToHSLASingle(lnum)
    let pattern = 'rgba\s*(\s*\(\d\{1,3}\)\s*,\s*\(\d\{1,3}\)\s*,\s*\(\d\{1,3}\)\s*,\s*\([0-9\.]*\)\s*)'
    let allstr = getline(a:lnum)
    let rgba_color = matchlist(allstr, pattern)

    while rgba_color != []
        let hsl = RGBToHSLNumber(rgba_color)
        let hsl_color = "hsla(" . hsl[0] . ", " . hsl[1] . "%, " . hsl[2] . "%, ". rgba_color[4] .")"
        let new_line_content = substitute(allstr, rgba_color[0], hsl_color, "")
        let result = setline(a:lnum, new_line_content)

        let allstr = getline(a:lnum)
        let rgba_color = matchlist(allstr, pattern)
    endwhile
endfunction


function! RGBToHSLNumber(rgb)

    let r = a:rgb[1]
    let g = a:rgb[2]
    let b = a:rgb[3]

    let v = max([r,g,b]) 
    let m = min([r,g,b])
    let d = v - m

    let l = (v + m) / 2

    if (d == 0)
        let h = 0
        let s = 0
        let l = l  * 100 / 256
        return [h,s,l]
    endif

    if l > (256 / 2)
        let s = d * 100/ (512-v-m)
    else
        let s = d * 100/(v+m)
    endif

    if v == r
        let h = 360 + (60 * (g - b)) / d
    elseif v == g
        let h = 120 + (60 * (b - r)) / d
    elseif v == b
        let h = 240 + (60 * (r - g)) / d
    endif

    let h = h % 360

    let l = l  * 100 / 256
    return [h, s, l, d, v, m]

endfunction

function! AddHslNumberSingle(lnum, addition)
    let pattern = 'hsla\?\s*(\s*\(\d\{0,3}\)\s*,'
    let allstr = getline(a:lnum)
    let h_old = matchlist(allstr, pattern)

    while h_old != []

        let h_new = (h_old[1] + a:addition) % 360
        let h_str_new = 'hslat(' . h_new . ','

        let new_line_content = substitute(allstr, h_old[0], h_str_new, "")
        let result = setline(a:lnum, new_line_content)

        let allstr = getline(a:lnum)
        let h_old = matchlist(allstr, pattern)

    endwhile 
endfunction
