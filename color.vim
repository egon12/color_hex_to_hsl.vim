function! ColorHexToRGBSingle(line_number)

    let pattern = '#\([A-Fa-f0-9]\{2}\)\([A-Fa-f0-9]\{2}\)\([A-Fa-f0-9]\{2}\)'

    let allstr = getline(a:line_number)

    let hex_color = matchlist(allstr, pattern)

    if hex_color == [] 
        return
    endif

    let hex_r = hex_color[1]
    let hex_g = hex_color[2]
    let hex_b = hex_color[3]

    let int_r = str2nr(hex_r, '16')
    let int_g = str2nr(hex_g, '16')
    let int_b = str2nr(hex_b, '16')

    let int_rgb = "rgb(" . int_r . ", " . int_g . ", " . int_b . ")"

    let new_line_content = substitute(allstr, hex_color[0], int_rgb, "")

    let result = setline(a:line_number, new_line_content)

endfunction



function! ColorHexToRGB()
    let lnum = 1
    while lnum <= line("$")
        call ColorHexToRGBSingle(lnum)
        let lnum = lnum + 1
    endwhile
endfunction

function! ColorRGBToHSLSingle(lnum)

    let pattern = 'rgba\?\W*(\W*\(\d\{0,3}\)\W*,\W*\(\d\{0,3}\)\W*,\W*\(\d\{0,3}\)\W*)'

    let allstr = getline(a:lnum)

    let rgb_color = matchlist(allstr, pattern)

    if rgb_color == []
        return
    endif

    let hsl = RGBToHSLNumber(rgb_color)

    let hsl_color = "hsla(" . hsl[0] . ", " . hsl[1] . "%, " . hsl[2] . "%, 1)"


    let new_line_content = substitute(allstr, rgb_color[0], hsl_color, "")

    let result = setline(a:lnum, new_line_content)


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
        return [h,s,l]
    endif

    if l > (256 / 2)
        let s = d * 100/ (512-v-m)
    else
        let s = d * 100/(v+m)
    endif

    if v == r && g >= b
        let h = 60 * (g - b) / d
    elseif v == r && b > g
        let h = 360 + (60 * (g - b)) / d
    elseif v == g
        let h = 120 + (60 * (b - r)) / d
    elseif v == b
        let h = 240 + (60 * (r - g)) / d
    endif


    let l = l  * 100 / 256
    return [h, s, l, d, v, m]


endfunction

function! ColorRGBToHSL() 
    let lnum = 1
    while lnum <= line("$")
        call ColorRGBToHSLSingle(lnum)
        let lnum = lnum + 1
    endwhile


endfunction
