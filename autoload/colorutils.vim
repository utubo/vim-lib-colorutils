" * Ranges
"   * r, g, b: [0 : 255]
"   * h(Hue): [0 : 360]
"   * s(Saturation): [0 : 1]
"   * l(Lightness): [0 : 1]

"*
" @param rgb dictionary{ r:, g:, b: }
" @return string "#rrggbb"
function colorutils#rgb2hex(rgb)
  return printf('#%02x%02x%02x', a:rgb.r, a:rgb.g, a:rgb.b)
endfunction

"*
" @param hex string "#rrggbb"
" @return dictionary{ r:, g:, b: }
function colorutils#hex2rgb(hex)
  return {
    \ 'r': str2nr(a:hex[1 : 2], 16),
    \ 'g': str2nr(a:hex[3 : 4], 16),
    \ 'b': str2nr(a:hex[5 : 6], 16)
  \ }
endfunction

"*
" @param rgb dictionary{ r:, g:, b: }
" @return dictionary{ h:, s:, l: }
function colorutils#rgb2hsl(rgb)
  let mx = max([a:rgb.r, a:rgb.g, a:rgb.b]) * 1.0
  let mn = min([a:rgb.r, a:rgb.g, a:rgb.b]) * 1.0
  let m = mx - mn
  let h = 0
  if a:rgb.r == a:rgb.g && a:rgb.r == a:rgb.b && a:rgb.g == a:rgb.b
    let h = 0
  elseif mx == a:rgb.r
    let h = 60 * (a:rgb.g - a:rgb.b) / m
  elseif mx == a:rgb.g
    let h = 60 * (a:rgb.b - a:rgb.r) / m + 120
  else
    let h = 60 * (a:rgb.r - a:rgb.g) / m + 240
  endif
  if h < 0
    let h += 360
  endif
  let cnt = (mx + mn) / 2.0
  let s = 0.0
  if m == 0
    let s = 0.0
  elseif cnt < 127
    let s = m / (mx + mn)
  else
    let s = m / (510.0 - mx - mn)
  endif
  return { 'h': h, 's': s, 'l': cnt / 255.0 }
endfunction


function s:k(n, hsl)
  return float2nr(a:n + a:hsl.h / 30.0) % 12
endfunction

function s:a(hsl)
  return a:hsl.s * sort([a:hsl.l, 1 - a:hsl.l])[0]
endfunction

function s:f(n, hsl)
  return float2nr(255 * (a:hsl.l - s:a(a:hsl) * max([-1, sort([s:k(a:n, a:hsl) - 3, 9 - s:k(a:n, a:hsl), 1])[0]])))
endfunction

"*
" @param hsl dictionary{ h:, s:, l: }
" @return dictionary{ r:, g:, b: }
function colorutils#hsl2rgb(hsl)
  return { 'r': s:f(0, a:hsl), 'g': s:f(8, a:hsl), 'b': s:f(4, a:hsl) }
endfunction

"*
" @param hsl dictionary{ h:, s:, l: }
" @return string "#rrggbb"
function colorutils#hsl2hex(hsl)
  return colorutils#rgb2hex(colorutils#hsl2rgb(a:hsl))
endfunction

"*
" @param hex string "#rrggbb"
" @return dictionary{ h:, s:, l: }
function colorutils#hex2hsl(hex)
  return colorutils#rgb2hsl(colorutils#hex2rgb(a:hex))
endfunction

function colorutils#compare_distance_desc(a, b)
  return a:a.distance < a:b.distance ? -1 : a:a.distance > a:b.distance ? 1 : 0
endfunction

"*
" List cterm colors sort by similarity of "#rrggbb".
" @param hex string "#rrggbb"
" @return list<{index:, r:, g:, b:, h:, s:, l:}> cterm colors sort by similarity of colors
function colorutils#list_cterm_colors(hex)
  let hsl = colorutils#hex2hsl(a:hex)
  let result = copy(s:CTERM_COLORS)
  " Calculate all distance of HSL.
  for cterm in result
    let dh = abs(hsl.h - cterm.h) / 360.0
    let dh = sort([dh, 1 - dh])[0]
    let ds = abs(hsl.s - cterm.s)
    let dl = abs(hsl.l - cterm.l)
    let cterm.distance = dh * (hsl.s + cterm.s) + ds + dl * 2.0
  endfor
  " Order by distance.
  call sort(result, 'colorutils#compare_distance_desc')
  return result
endfunction

"*
" Return the approximate cterm color of "#rrggbb".
" @param hex string "#rrggbb"
" @return directory<{index:, r:, g:, b:, h:, s:, l:}> colors of cterm sort by similarity of colors
function colorutils#find_cterm_color(hex)
  return colorutils#list_cterm_colors(a:hex)[0]
endfunction

"*
" Colors of cterm
let s:CTERM_COLORS = [
  \ { 'index':0,   'hex':'#000000', 'r':0,   'g':0,   'b':0,   'h':0,   's':0.00, 'l':0.00 },
  \ { 'index':1,   'hex':'#800000', 'r':128, 'g':0,   'b':0,   'h':0,   's':1.00, 'l':0.25 },
  \ { 'index':2,   'hex':'#008000', 'r':0,   'g':128, 'b':0,   'h':120, 's':1.00, 'l':0.25 },
  \ { 'index':3,   'hex':'#808000', 'r':128, 'g':128, 'b':0,   'h':60,  's':1.00, 'l':0.25 },
  \ { 'index':4,   'hex':'#000080', 'r':0,   'g':0,   'b':128, 'h':240, 's':1.00, 'l':0.25 },
  \ { 'index':5,   'hex':'#800080', 'r':128, 'g':0,   'b':128, 'h':300, 's':1.00, 'l':0.25 },
  \ { 'index':6,   'hex':'#008080', 'r':0,   'g':128, 'b':128, 'h':180, 's':1.00, 'l':0.25 },
  \ { 'index':7,   'hex':'#c0c0c0', 'r':192, 'g':192, 'b':192, 'h':0,   's':0.00, 'l':0.75 },
  \ { 'index':8,   'hex':'#808080', 'r':128, 'g':128, 'b':128, 'h':0,   's':0.00, 'l':0.50 },
  \ { 'index':9,   'hex':'#ff0000', 'r':255, 'g':0,   'b':0,   'h':0,   's':1.00, 'l':0.50 },
  \ { 'index':10,  'hex':'#00ff00', 'r':0,   'g':255, 'b':0,   'h':120, 's':1.00, 'l':0.50 },
  \ { 'index':11,  'hex':'#ffff00', 'r':255, 'g':255, 'b':0,   'h':60,  's':1.00, 'l':0.50 },
  \ { 'index':12,  'hex':'#0000ff', 'r':0,   'g':0,   'b':255, 'h':240, 's':1.00, 'l':0.50 },
  \ { 'index':13,  'hex':'#ff00ff', 'r':255, 'g':0,   'b':255, 'h':300, 's':1.00, 'l':0.50 },
  \ { 'index':14,  'hex':'#00ffff', 'r':0,   'g':255, 'b':255, 'h':180, 's':1.00, 'l':0.50 },
  \ { 'index':15,  'hex':'#ffffff', 'r':255, 'g':255, 'b':255, 'h':0,   's':0.00, 'l':1.00 },
  \ { 'index':16,  'hex':'#000000', 'r':0,   'g':0,   'b':0,   'h':0,   's':0.00, 'l':0.00 },
  \ { 'index':17,  'hex':'#00005f', 'r':0,   'g':0,   'b':95,  'h':240, 's':1.00, 'l':0.18 },
  \ { 'index':18,  'hex':'#000087', 'r':0,   'g':0,   'b':135, 'h':240, 's':1.00, 'l':0.26 },
  \ { 'index':19,  'hex':'#0000af', 'r':0,   'g':0,   'b':175, 'h':240, 's':1.00, 'l':0.34 },
  \ { 'index':20,  'hex':'#0000d7', 'r':0,   'g':0,   'b':215, 'h':240, 's':1.00, 'l':0.42 },
  \ { 'index':21,  'hex':'#0000ff', 'r':0,   'g':0,   'b':255, 'h':240, 's':1.00, 'l':0.50 },
  \ { 'index':22,  'hex':'#005f00', 'r':0,   'g':95,  'b':0,   'h':120, 's':1.00, 'l':0.18 },
  \ { 'index':23,  'hex':'#005f5f', 'r':0,   'g':95,  'b':95,  'h':180, 's':1.00, 'l':0.18 },
  \ { 'index':24,  'hex':'#005f87', 'r':0,   'g':95,  'b':135, 'h':198, 's':1.00, 'l':0.26 },
  \ { 'index':25,  'hex':'#005faf', 'r':0,   'g':95,  'b':175, 'h':207, 's':1.00, 'l':0.34 },
  \ { 'index':26,  'hex':'#005fd7', 'r':0,   'g':95,  'b':215, 'h':213, 's':1.00, 'l':0.42 },
  \ { 'index':27,  'hex':'#005fff', 'r':0,   'g':95,  'b':255, 'h':218, 's':1.00, 'l':0.50 },
  \ { 'index':28,  'hex':'#008700', 'r':0,   'g':135, 'b':0,   'h':120, 's':1.00, 'l':0.26 },
  \ { 'index':29,  'hex':'#00875f', 'r':0,   'g':135, 'b':95,  'h':162, 's':1.00, 'l':0.26 },
  \ { 'index':30,  'hex':'#008787', 'r':0,   'g':135, 'b':135, 'h':180, 's':1.00, 'l':0.26 },
  \ { 'index':31,  'hex':'#0087af', 'r':0,   'g':135, 'b':175, 'h':194, 's':1.00, 'l':0.34 },
  \ { 'index':32,  'hex':'#0087d7', 'r':0,   'g':135, 'b':215, 'h':202, 's':1.00, 'l':0.42 },
  \ { 'index':33,  'hex':'#0087ff', 'r':0,   'g':135, 'b':255, 'h':208, 's':1.00, 'l':0.50 },
  \ { 'index':34,  'hex':'#00af00', 'r':0,   'g':175, 'b':0,   'h':120, 's':1.00, 'l':0.34 },
  \ { 'index':35,  'hex':'#00af5f', 'r':0,   'g':175, 'b':95,  'h':153, 's':1.00, 'l':0.34 },
  \ { 'index':36,  'hex':'#00af87', 'r':0,   'g':175, 'b':135, 'h':166, 's':1.00, 'l':0.34 },
  \ { 'index':37,  'hex':'#00afaf', 'r':0,   'g':175, 'b':175, 'h':180, 's':1.00, 'l':0.34 },
  \ { 'index':38,  'hex':'#00afd7', 'r':0,   'g':175, 'b':215, 'h':191, 's':1.00, 'l':0.42 },
  \ { 'index':39,  'hex':'#00afff', 'r':0,   'g':175, 'b':255, 'h':199, 's':1.00, 'l':0.34 },
  \ { 'index':40,  'hex':'#00d700', 'r':0,   'g':215, 'b':0,   'h':120, 's':1.00, 'l':0.42 },
  \ { 'index':41,  'hex':'#00d75f', 'r':0,   'g':215, 'b':95,  'h':147, 's':1.00, 'l':0.42 },
  \ { 'index':42,  'hex':'#00d787', 'r':0,   'g':215, 'b':135, 'h':158, 's':1.00, 'l':0.42 },
  \ { 'index':43,  'hex':'#00d7af', 'r':0,   'g':215, 'b':175, 'h':169, 's':1.00, 'l':0.42 },
  \ { 'index':44,  'hex':'#00d7d7', 'r':0,   'g':215, 'b':215, 'h':180, 's':1.00, 'l':0.42 },
  \ { 'index':45,  'hex':'#00d7ff', 'r':0,   'g':215, 'b':255, 'h':189, 's':1.00, 'l':0.50 },
  \ { 'index':46,  'hex':'#00ff00', 'r':0,   'g':255, 'b':0,   'h':120, 's':1.00, 'l':0.50 },
  \ { 'index':47,  'hex':'#00ff5f', 'r':0,   'g':255, 'b':95,  'h':142, 's':1.00, 'l':0.50 },
  \ { 'index':48,  'hex':'#00ff87', 'r':0,   'g':255, 'b':135, 'h':152, 's':1.00, 'l':0.50 },
  \ { 'index':49,  'hex':'#00ffaf', 'r':0,   'g':255, 'b':175, 'h':161, 's':1.00, 'l':0.50 },
  \ { 'index':50,  'hex':'#00ffd7', 'r':0,   'g':255, 'b':215, 'h':171, 's':1.00, 'l':0.50 },
  \ { 'index':51,  'hex':'#00ffff', 'r':0,   'g':255, 'b':255, 'h':180, 's':1.00, 'l':0.50 },
  \ { 'index':52,  'hex':'#5f0000', 'r':95,  'g':0,   'b':0,   'h':0,   's':1.00, 'l':0.18 },
  \ { 'index':53,  'hex':'#5f005f', 'r':95,  'g':0,   'b':95,  'h':300, 's':1.00, 'l':0.18 },
  \ { 'index':54,  'hex':'#5f0087', 'r':95,  'g':0,   'b':135, 'h':282, 's':1.00, 'l':0.26 },
  \ { 'index':55,  'hex':'#5f00af', 'r':95,  'g':0,   'b':175, 'h':273, 's':1.00, 'l':0.34 },
  \ { 'index':56,  'hex':'#5f00d7', 'r':95,  'g':0,   'b':215, 'h':267, 's':1.00, 'l':0.42 },
  \ { 'index':57,  'hex':'#5f00ff', 'r':95,  'g':0,   'b':255, 'h':262, 's':1.00, 'l':0.50 },
  \ { 'index':58,  'hex':'#5f5f00', 'r':95,  'g':95,  'b':0,   'h':60,  's':1.00, 'l':0.18 },
  \ { 'index':59,  'hex':'#5f5f5f', 'r':95,  'g':95,  'b':95,  'h':0,   's':0.00, 'l':0.37 },
  \ { 'index':60,  'hex':'#5f5f87', 'r':95,  'g':95,  'b':135, 'h':240, 's':0.17, 'l':0.45 },
  \ { 'index':61,  'hex':'#5f5faf', 'r':95,  'g':95,  'b':175, 'h':240, 's':0.33, 'l':0.52 },
  \ { 'index':62,  'hex':'#5f5fd7', 'r':95,  'g':95,  'b':215, 'h':240, 's':0.60, 'l':0.60 },
  \ { 'index':63,  'hex':'#5f5fff', 'r':95,  'g':95,  'b':255, 'h':240, 's':1.00, 'l':0.68 },
  \ { 'index':64,  'hex':'#5f8700', 'r':95,  'g':135, 'b':0,   'h':78,  's':1.00, 'l':0.26 },
  \ { 'index':65,  'hex':'#5f875f', 'r':95,  'g':135, 'b':95,  'h':120, 's':0.17, 'l':0.45 },
  \ { 'index':66,  'hex':'#5f8787', 'r':95,  'g':135, 'b':135, 'h':180, 's':0.17, 'l':0.45 },
  \ { 'index':67,  'hex':'#5f87af', 'r':95,  'g':135, 'b':175, 'h':210, 's':0.33, 'l':0.52 },
  \ { 'index':68,  'hex':'#5f87d7', 'r':95,  'g':135, 'b':215, 'h':220, 's':0.60, 'l':0.60 },
  \ { 'index':69,  'hex':'#5f87ff', 'r':95,  'g':135, 'b':255, 'h':225, 's':1.00, 'l':0.68 },
  \ { 'index':70,  'hex':'#5faf00', 'r':95,  'g':175, 'b':0,   'h':87,  's':1.00, 'l':0.34 },
  \ { 'index':71,  'hex':'#5faf5f', 'r':95,  'g':175, 'b':95,  'h':120, 's':0.33, 'l':0.52 },
  \ { 'index':72,  'hex':'#5faf87', 'r':95,  'g':175, 'b':135, 'h':150, 's':0.33, 'l':0.52 },
  \ { 'index':73,  'hex':'#5fafaf', 'r':95,  'g':175, 'b':175, 'h':180, 's':0.33, 'l':0.52 },
  \ { 'index':74,  'hex':'#5fafd7', 'r':95,  'g':175, 'b':215, 'h':200, 's':0.60, 'l':0.60 },
  \ { 'index':75,  'hex':'#5fafff', 'r':95,  'g':175, 'b':255, 'h':210, 's':1.00, 'l':0.68 },
  \ { 'index':76,  'hex':'#5fd700', 'r':95,  'g':215, 'b':0,   'h':93,  's':1.00, 'l':0.42 },
  \ { 'index':77,  'hex':'#5fd75f', 'r':95,  'g':215, 'b':95,  'h':120, 's':0.60, 'l':0.60 },
  \ { 'index':78,  'hex':'#5fd787', 'r':95,  'g':215, 'b':135, 'h':140, 's':0.60, 'l':0.60 },
  \ { 'index':79,  'hex':'#5fd7af', 'r':95,  'g':215, 'b':175, 'h':160, 's':0.60, 'l':0.60 },
  \ { 'index':80,  'hex':'#5fd7d7', 'r':95,  'g':215, 'b':215, 'h':180, 's':0.60, 'l':0.60 },
  \ { 'index':81,  'hex':'#5fd7ff', 'r':95,  'g':215, 'b':255, 'h':195, 's':1.00, 'l':0.68 },
  \ { 'index':82,  'hex':'#5fff00', 'r':95,  'g':255, 'b':0,   'h':98,  's':1.00, 'l':0.50 },
  \ { 'index':83,  'hex':'#5fff5f', 'r':95,  'g':255, 'b':95,  'h':120, 's':1.00, 'l':0.68 },
  \ { 'index':84,  'hex':'#5fff87', 'r':95,  'g':255, 'b':135, 'h':135, 's':1.00, 'l':0.68 },
  \ { 'index':85,  'hex':'#5fffaf', 'r':95,  'g':255, 'b':175, 'h':150, 's':1.00, 'l':0.68 },
  \ { 'index':86,  'hex':'#5fffd7', 'r':95,  'g':255, 'b':215, 'h':165, 's':1.00, 'l':0.68 },
  \ { 'index':87,  'hex':'#5fffff', 'r':95,  'g':255, 'b':255, 'h':180, 's':1.00, 'l':0.68 },
  \ { 'index':88,  'hex':'#870000', 'r':135, 'g':0,   'b':0,   'h':0,   's':1.00, 'l':0.26 },
  \ { 'index':89,  'hex':'#87005f', 'r':135, 'g':0,   'b':95,  'h':318, 's':1.00, 'l':0.26 },
  \ { 'index':90,  'hex':'#870087', 'r':135, 'g':0,   'b':135, 'h':300, 's':1.00, 'l':0.26 },
  \ { 'index':91,  'hex':'#8700af', 'r':135, 'g':0,   'b':175, 'h':286, 's':1.00, 'l':0.34 },
  \ { 'index':92,  'hex':'#8700d7', 'r':135, 'g':0,   'b':215, 'h':277, 's':1.00, 'l':0.42 },
  \ { 'index':93,  'hex':'#8700ff', 'r':135, 'g':0,   'b':255, 'h':272, 's':1.00, 'l':0.50 },
  \ { 'index':94,  'hex':'#875f00', 'r':135, 'g':95,  'b':0,   'h':42,  's':1.00, 'l':0.26 },
  \ { 'index':95,  'hex':'#875f5f', 'r':135, 'g':95,  'b':95,  'h':0,   's':0.17, 'l':0.45 },
  \ { 'index':96,  'hex':'#875f87', 'r':135, 'g':95,  'b':135, 'h':300, 's':0.17, 'l':0.45 },
  \ { 'index':97,  'hex':'#875faf', 'r':135, 'g':95,  'b':175, 'h':270, 's':0.33, 'l':0.52 },
  \ { 'index':98,  'hex':'#875fd7', 'r':135, 'g':95,  'b':215, 'h':260, 's':0.60, 'l':0.60 },
  \ { 'index':99,  'hex':'#875fff', 'r':135, 'g':95,  'b':255, 'h':255, 's':1.00, 'l':0.68 },
  \ { 'index':100, 'hex':'#878700', 'r':135, 'g':135, 'b':0,   'h':60,  's':1.00, 'l':0.26 },
  \ { 'index':101, 'hex':'#87875f', 'r':135, 'g':135, 'b':95,  'h':60,  's':0.17, 'l':0.45 },
  \ { 'index':102, 'hex':'#878787', 'r':135, 'g':135, 'b':135, 'h':0,   's':0.00, 'l':0.52 },
  \ { 'index':103, 'hex':'#8787af', 'r':135, 'g':135, 'b':175, 'h':240, 's':0.20, 'l':0.60 },
  \ { 'index':104, 'hex':'#8787d7', 'r':135, 'g':135, 'b':215, 'h':240, 's':0.50, 'l':0.68 },
  \ { 'index':105, 'hex':'#8787ff', 'r':135, 'g':135, 'b':255, 'h':240, 's':1.00, 'l':0.76 },
  \ { 'index':106, 'hex':'#87af00', 'r':135, 'g':175, 'b':0,   'h':73,  's':1.00, 'l':0.34 },
  \ { 'index':107, 'hex':'#87af5f', 'r':135, 'g':175, 'b':95,  'h':90,  's':0.33, 'l':0.52 },
  \ { 'index':108, 'hex':'#87af87', 'r':135, 'g':175, 'b':135, 'h':120, 's':0.20, 'l':0.60 },
  \ { 'index':109, 'hex':'#87afaf', 'r':135, 'g':175, 'b':175, 'h':180, 's':0.20, 'l':0.60 },
  \ { 'index':110, 'hex':'#87afd7', 'r':135, 'g':175, 'b':215, 'h':210, 's':0.50, 'l':0.68 },
  \ { 'index':111, 'hex':'#87afff', 'r':135, 'g':175, 'b':255, 'h':220, 's':1.00, 'l':0.76 },
  \ { 'index':112, 'hex':'#87d700', 'r':135, 'g':215, 'b':0,   'h':82,  's':1.00, 'l':0.42 },
  \ { 'index':113, 'hex':'#87d75f', 'r':135, 'g':215, 'b':95,  'h':100, 's':0.60, 'l':0.60 },
  \ { 'index':114, 'hex':'#87d787', 'r':135, 'g':215, 'b':135, 'h':120, 's':0.50, 'l':0.68 },
  \ { 'index':115, 'hex':'#87d7af', 'r':135, 'g':215, 'b':175, 'h':150, 's':0.50, 'l':0.68 },
  \ { 'index':116, 'hex':'#87d7d7', 'r':135, 'g':215, 'b':215, 'h':180, 's':0.50, 'l':0.68 },
  \ { 'index':117, 'hex':'#87d7ff', 'r':135, 'g':215, 'b':255, 'h':200, 's':1.00, 'l':0.76 },
  \ { 'index':118, 'hex':'#87ff00', 'r':135, 'g':255, 'b':0,   'h':88,  's':1.00, 'l':0.50 },
  \ { 'index':119, 'hex':'#87ff5f', 'r':135, 'g':255, 'b':95,  'h':105, 's':1.00, 'l':0.68 },
  \ { 'index':120, 'hex':'#87ff87', 'r':135, 'g':255, 'b':135, 'h':120, 's':1.00, 'l':0.76 },
  \ { 'index':121, 'hex':'#87ffaf', 'r':135, 'g':255, 'b':175, 'h':140, 's':1.00, 'l':0.76 },
  \ { 'index':122, 'hex':'#87ffd7', 'r':135, 'g':255, 'b':215, 'h':160, 's':1.00, 'l':0.76 },
  \ { 'index':123, 'hex':'#87ffff', 'r':135, 'g':255, 'b':255, 'h':180, 's':1.00, 'l':0.76 },
  \ { 'index':124, 'hex':'#af0000', 'r':175, 'g':0,   'b':0,   'h':0,   's':1.00, 'l':0.34 },
  \ { 'index':125, 'hex':'#af005f', 'r':175, 'g':0,   'b':95,  'h':327, 's':1.00, 'l':0.34 },
  \ { 'index':126, 'hex':'#af0087', 'r':175, 'g':0,   'b':135, 'h':314, 's':1.00, 'l':0.34 },
  \ { 'index':127, 'hex':'#af00af', 'r':175, 'g':0,   'b':175, 'h':300, 's':1.00, 'l':0.34 },
  \ { 'index':128, 'hex':'#af00d7', 'r':175, 'g':0,   'b':215, 'h':289, 's':1.00, 'l':0.42 },
  \ { 'index':129, 'hex':'#af00ff', 'r':175, 'g':0,   'b':255, 'h':281, 's':1.00, 'l':0.50 },
  \ { 'index':130, 'hex':'#af5f00', 'r':175, 'g':95,  'b':0,   'h':33,  's':1.00, 'l':0.34 },
  \ { 'index':131, 'hex':'#af5f5f', 'r':175, 'g':95,  'b':95,  'h':0,   's':0.33, 'l':0.52 },
  \ { 'index':132, 'hex':'#af5f87', 'r':175, 'g':95,  'b':135, 'h':330, 's':0.33, 'l':0.52 },
  \ { 'index':133, 'hex':'#af5faf', 'r':175, 'g':95,  'b':175, 'h':300, 's':0.33, 'l':0.52 },
  \ { 'index':134, 'hex':'#af5fd7', 'r':175, 'g':95,  'b':215, 'h':280, 's':0.60, 'l':0.60 },
  \ { 'index':135, 'hex':'#af5fff', 'r':175, 'g':95,  'b':255, 'h':270, 's':1.00, 'l':0.68 },
  \ { 'index':136, 'hex':'#af8700', 'r':175, 'g':135, 'b':0,   'h':46,  's':1.00, 'l':0.34 },
  \ { 'index':137, 'hex':'#af875f', 'r':175, 'g':135, 'b':95,  'h':30,  's':0.33, 'l':0.52 },
  \ { 'index':138, 'hex':'#af8787', 'r':175, 'g':135, 'b':135, 'h':0,   's':0.20, 'l':0.60 },
  \ { 'index':139, 'hex':'#af87af', 'r':175, 'g':135, 'b':175, 'h':300, 's':0.20, 'l':0.60 },
  \ { 'index':140, 'hex':'#af87d7', 'r':175, 'g':135, 'b':215, 'h':270, 's':0.50, 'l':0.68 },
  \ { 'index':141, 'hex':'#af87ff', 'r':175, 'g':135, 'b':255, 'h':260, 's':1.00, 'l':0.76 },
  \ { 'index':142, 'hex':'#afaf00', 'r':175, 'g':175, 'b':0,   'h':60,  's':1.00, 'l':0.34 },
  \ { 'index':143, 'hex':'#afaf5f', 'r':175, 'g':175, 'b':95,  'h':60,  's':0.33, 'l':0.52 },
  \ { 'index':144, 'hex':'#afaf87', 'r':175, 'g':175, 'b':135, 'h':60,  's':0.20, 'l':0.60 },
  \ { 'index':145, 'hex':'#afafaf', 'r':175, 'g':175, 'b':175, 'h':0,   's':0.00, 'l':0.68 },
  \ { 'index':146, 'hex':'#afafd7', 'r':175, 'g':175, 'b':215, 'h':240, 's':0.33, 'l':0.76 },
  \ { 'index':147, 'hex':'#afafff', 'r':175, 'g':175, 'b':255, 'h':240, 's':1.00, 'l':0.84 },
  \ { 'index':148, 'hex':'#afd700', 'r':175, 'g':215, 'b':0,   'h':71,  's':1.00, 'l':0.42 },
  \ { 'index':149, 'hex':'#afd75f', 'r':175, 'g':215, 'b':95,  'h':80,  's':0.60, 'l':0.60 },
  \ { 'index':150, 'hex':'#afd787', 'r':175, 'g':215, 'b':135, 'h':90,  's':0.50, 'l':0.68 },
  \ { 'index':151, 'hex':'#afd7af', 'r':175, 'g':215, 'b':175, 'h':120, 's':0.33, 'l':0.76 },
  \ { 'index':152, 'hex':'#afd7d7', 'r':175, 'g':215, 'b':215, 'h':180, 's':0.33, 'l':0.76 },
  \ { 'index':153, 'hex':'#afd7ff', 'r':175, 'g':215, 'b':255, 'h':210, 's':1.00, 'l':0.84 },
  \ { 'index':154, 'hex':'#afff00', 'r':175, 'g':255, 'b':0,   'h':78,  's':1.00, 'l':0.50 },
  \ { 'index':155, 'hex':'#afff5f', 'r':175, 'g':255, 'b':95,  'h':90,  's':1.00, 'l':0.68 },
  \ { 'index':156, 'hex':'#afff87', 'r':175, 'g':255, 'b':135, 'h':100, 's':1.00, 'l':0.76 },
  \ { 'index':157, 'hex':'#afffaf', 'r':175, 'g':255, 'b':175, 'h':120, 's':1.00, 'l':0.84 },
  \ { 'index':158, 'hex':'#afffd7', 'r':175, 'g':255, 'b':215, 'h':150, 's':1.00, 'l':0.84 },
  \ { 'index':159, 'hex':'#afffff', 'r':175, 'g':255, 'b':255, 'h':180, 's':1.00, 'l':0.84 },
  \ { 'index':160, 'hex':'#d70000', 'r':215, 'g':0,   'b':0,   'h':0,   's':1.00, 'l':0.42 },
  \ { 'index':161, 'hex':'#d7005f', 'r':215, 'g':0,   'b':95,  'h':333, 's':1.00, 'l':0.42 },
  \ { 'index':162, 'hex':'#d70087', 'r':215, 'g':0,   'b':135, 'h':322, 's':1.00, 'l':0.42 },
  \ { 'index':163, 'hex':'#d700af', 'r':215, 'g':0,   'b':175, 'h':311, 's':1.00, 'l':0.42 },
  \ { 'index':164, 'hex':'#d700d7', 'r':215, 'g':0,   'b':215, 'h':300, 's':1.00, 'l':0.42 },
  \ { 'index':165, 'hex':'#d700ff', 'r':215, 'g':0,   'b':255, 'h':291, 's':1.00, 'l':0.50 },
  \ { 'index':166, 'hex':'#d75f00', 'r':215, 'g':95,  'b':0,   'h':27,  's':1.00, 'l':0.42 },
  \ { 'index':167, 'hex':'#d75f5f', 'r':215, 'g':95,  'b':95,  'h':0,   's':0.60, 'l':0.60 },
  \ { 'index':168, 'hex':'#d75f87', 'r':215, 'g':95,  'b':135, 'h':340, 's':0.60, 'l':0.60 },
  \ { 'index':169, 'hex':'#d75faf', 'r':215, 'g':95,  'b':175, 'h':320, 's':0.60, 'l':0.60 },
  \ { 'index':170, 'hex':'#d75fd7', 'r':215, 'g':95,  'b':215, 'h':300, 's':0.60, 'l':0.60 },
  \ { 'index':171, 'hex':'#d75fff', 'r':215, 'g':95,  'b':255, 'h':285, 's':1.00, 'l':0.68 },
  \ { 'index':172, 'hex':'#d78700', 'r':215, 'g':135, 'b':0,   'h':38,  's':1.00, 'l':0.42 },
  \ { 'index':173, 'hex':'#d7875f', 'r':215, 'g':135, 'b':95,  'h':20,  's':0.60, 'l':0.60 },
  \ { 'index':174, 'hex':'#d78787', 'r':215, 'g':135, 'b':135, 'h':0,   's':0.50, 'l':0.68 },
  \ { 'index':175, 'hex':'#d787af', 'r':215, 'g':135, 'b':175, 'h':330, 's':0.50, 'l':0.68 },
  \ { 'index':176, 'hex':'#d787d7', 'r':215, 'g':135, 'b':215, 'h':300, 's':0.50, 'l':0.68 },
  \ { 'index':177, 'hex':'#d787ff', 'r':215, 'g':135, 'b':255, 'h':280, 's':1.00, 'l':0.76 },
  \ { 'index':178, 'hex':'#d7af00', 'r':215, 'g':175, 'b':0,   'h':49,  's':1.00, 'l':0.42 },
  \ { 'index':179, 'hex':'#d7af5f', 'r':215, 'g':175, 'b':95,  'h':40,  's':0.60, 'l':0.60 },
  \ { 'index':180, 'hex':'#d7af87', 'r':215, 'g':175, 'b':135, 'h':30,  's':0.50, 'l':0.68 },
  \ { 'index':181, 'hex':'#d7afaf', 'r':215, 'g':175, 'b':175, 'h':0,   's':0.33, 'l':0.76 },
  \ { 'index':182, 'hex':'#d7afd7', 'r':215, 'g':175, 'b':215, 'h':300, 's':0.33, 'l':0.76 },
  \ { 'index':183, 'hex':'#d7afff', 'r':215, 'g':175, 'b':255, 'h':270, 's':1.00, 'l':0.84 },
  \ { 'index':184, 'hex':'#d7d700', 'r':215, 'g':215, 'b':0,   'h':60,  's':1.00, 'l':0.42 },
  \ { 'index':185, 'hex':'#d7d75f', 'r':215, 'g':215, 'b':95,  'h':60,  's':0.60, 'l':0.60 },
  \ { 'index':186, 'hex':'#d7d787', 'r':215, 'g':215, 'b':135, 'h':60,  's':0.50, 'l':0.68 },
  \ { 'index':187, 'hex':'#d7d7af', 'r':215, 'g':215, 'b':175, 'h':60,  's':0.33, 'l':0.76 },
  \ { 'index':188, 'hex':'#d7d7d7', 'r':215, 'g':215, 'b':215, 'h':0,   's':0.00, 'l':0.84 },
  \ { 'index':189, 'hex':'#d7d7ff', 'r':215, 'g':215, 'b':255, 'h':240, 's':1.00, 'l':0.92 },
  \ { 'index':190, 'hex':'#d7ff00', 'r':215, 'g':255, 'b':0,   'h':70,  's':1.00, 'l':0.50 },
  \ { 'index':191, 'hex':'#d7ff5f', 'r':215, 'g':255, 'b':95,  'h':75,  's':1.00, 'l':0.68 },
  \ { 'index':192, 'hex':'#d7ff87', 'r':215, 'g':255, 'b':135, 'h':80,  's':1.00, 'l':0.76 },
  \ { 'index':193, 'hex':'#d7ffaf', 'r':215, 'g':255, 'b':175, 'h':90,  's':1.00, 'l':0.84 },
  \ { 'index':194, 'hex':'#d7ffd7', 'r':215, 'g':255, 'b':215, 'h':120, 's':1.00, 'l':0.92 },
  \ { 'index':195, 'hex':'#d7ffff', 'r':215, 'g':255, 'b':255, 'h':180, 's':1.00, 'l':0.92 },
  \ { 'index':196, 'hex':'#ff0000', 'r':255, 'g':0,   'b':0,   'h':0,   's':1.00, 'l':0.50 },
  \ { 'index':197, 'hex':'#ff005f', 'r':255, 'g':0,   'b':95,  'h':338, 's':1.00, 'l':0.50 },
  \ { 'index':198, 'hex':'#ff0087', 'r':255, 'g':0,   'b':135, 'h':328, 's':1.00, 'l':0.50 },
  \ { 'index':199, 'hex':'#ff00af', 'r':255, 'g':0,   'b':175, 'h':319, 's':1.00, 'l':0.50 },
  \ { 'index':200, 'hex':'#ff00d7', 'r':255, 'g':0,   'b':215, 'h':309, 's':1.00, 'l':0.50 },
  \ { 'index':201, 'hex':'#ff00ff', 'r':255, 'g':0,   'b':255, 'h':300, 's':1.00, 'l':0.50 },
  \ { 'index':202, 'hex':'#ff5f00', 'r':255, 'g':95,  'b':0,   'h':22,  's':1.00, 'l':0.50 },
  \ { 'index':203, 'hex':'#ff5f5f', 'r':255, 'g':95,  'b':95,  'h':0,   's':1.00, 'l':0.68 },
  \ { 'index':204, 'hex':'#ff5f87', 'r':255, 'g':95,  'b':135, 'h':345, 's':1.00, 'l':0.68 },
  \ { 'index':205, 'hex':'#ff5faf', 'r':255, 'g':95,  'b':175, 'h':330, 's':1.00, 'l':0.68 },
  \ { 'index':206, 'hex':'#ff5fd7', 'r':255, 'g':95,  'b':215, 'h':315, 's':1.00, 'l':0.68 },
  \ { 'index':207, 'hex':'#ff5fff', 'r':255, 'g':95,  'b':255, 'h':300, 's':1.00, 'l':0.68 },
  \ { 'index':208, 'hex':'#ff8700', 'r':255, 'g':135, 'b':0,   'h':32,  's':1.00, 'l':0.50 },
  \ { 'index':209, 'hex':'#ff875f', 'r':255, 'g':135, 'b':95,  'h':15,  's':1.00, 'l':0.68 },
  \ { 'index':210, 'hex':'#ff8787', 'r':255, 'g':135, 'b':135, 'h':0,   's':1.00, 'l':0.76 },
  \ { 'index':211, 'hex':'#ff87af', 'r':255, 'g':135, 'b':175, 'h':340, 's':1.00, 'l':0.76 },
  \ { 'index':212, 'hex':'#ff87d7', 'r':255, 'g':135, 'b':215, 'h':320, 's':1.00, 'l':0.76 },
  \ { 'index':213, 'hex':'#ff87ff', 'r':255, 'g':135, 'b':255, 'h':300, 's':1.00, 'l':0.76 },
  \ { 'index':214, 'hex':'#ffaf00', 'r':255, 'g':175, 'b':0,   'h':41,  's':1.00, 'l':0.50 },
  \ { 'index':215, 'hex':'#ffaf5f', 'r':255, 'g':175, 'b':95,  'h':30,  's':1.00, 'l':0.68 },
  \ { 'index':216, 'hex':'#ffaf87', 'r':255, 'g':175, 'b':135, 'h':20,  's':1.00, 'l':0.76 },
  \ { 'index':217, 'hex':'#ffafaf', 'r':255, 'g':175, 'b':175, 'h':0,   's':1.00, 'l':0.84 },
  \ { 'index':218, 'hex':'#ffafd7', 'r':255, 'g':175, 'b':215, 'h':330, 's':1.00, 'l':0.84 },
  \ { 'index':219, 'hex':'#ffafff', 'r':255, 'g':175, 'b':255, 'h':300, 's':1.00, 'l':0.84 },
  \ { 'index':220, 'hex':'#ffd700', 'r':255, 'g':215, 'b':0,   'h':51,  's':1.00, 'l':0.50 },
  \ { 'index':221, 'hex':'#ffd75f', 'r':255, 'g':215, 'b':95,  'h':45,  's':1.00, 'l':0.68 },
  \ { 'index':222, 'hex':'#ffd787', 'r':255, 'g':215, 'b':135, 'h':40,  's':1.00, 'l':0.76 },
  \ { 'index':223, 'hex':'#ffd7af', 'r':255, 'g':215, 'b':175, 'h':30,  's':1.00, 'l':0.84 },
  \ { 'index':224, 'hex':'#ffd7d7', 'r':255, 'g':215, 'b':215, 'h':0,   's':1.00, 'l':0.92 },
  \ { 'index':225, 'hex':'#ffd7ff', 'r':255, 'g':215, 'b':255, 'h':300, 's':1.00, 'l':0.92 },
  \ { 'index':226, 'hex':'#ffff00', 'r':255, 'g':255, 'b':0,   'h':60,  's':1.00, 'l':0.50 },
  \ { 'index':227, 'hex':'#ffff5f', 'r':255, 'g':255, 'b':95,  'h':60,  's':1.00, 'l':0.68 },
  \ { 'index':228, 'hex':'#ffff87', 'r':255, 'g':255, 'b':135, 'h':60,  's':1.00, 'l':0.76 },
  \ { 'index':229, 'hex':'#ffffaf', 'r':255, 'g':255, 'b':175, 'h':60,  's':1.00, 'l':0.84 },
  \ { 'index':230, 'hex':'#ffffd7', 'r':255, 'g':255, 'b':215, 'h':60,  's':1.00, 'l':0.92 },
  \ { 'index':231, 'hex':'#ffffff', 'r':255, 'g':255, 'b':255, 'h':0,   's':0.00, 'l':1.00 },
  \ { 'index':232, 'hex':'#080808', 'r':8,   'g':8,   'b':8,   'h':0,   's':0.00, 'l':0.03 },
  \ { 'index':233, 'hex':'#121212', 'r':18,  'g':18,  'b':18,  'h':0,   's':0.00, 'l':0.07 },
  \ { 'index':234, 'hex':'#1c1c1c', 'r':28,  'g':28,  'b':28,  'h':0,   's':0.00, 'l':0.10 },
  \ { 'index':235, 'hex':'#262626', 'r':38,  'g':38,  'b':38,  'h':0,   's':0.00, 'l':0.14 },
  \ { 'index':236, 'hex':'#303030', 'r':48,  'g':48,  'b':48,  'h':0,   's':0.00, 'l':0.18 },
  \ { 'index':237, 'hex':'#3a3a3a', 'r':58,  'g':58,  'b':58,  'h':0,   's':0.00, 'l':0.22 },
  \ { 'index':238, 'hex':'#444444', 'r':68,  'g':68,  'b':68,  'h':0,   's':0.00, 'l':0.26 },
  \ { 'index':239, 'hex':'#4e4e4e', 'r':78,  'g':78,  'b':78,  'h':0,   's':0.00, 'l':0.30 },
  \ { 'index':240, 'hex':'#585858', 'r':88,  'g':88,  'b':88,  'h':0,   's':0.00, 'l':0.34 },
  \ { 'index':241, 'hex':'#626262', 'r':98,  'g':98,  'b':98,  'h':0,   's':0.00, 'l':0.37 },
  \ { 'index':242, 'hex':'#6c6c6c', 'r':108, 'g':108, 'b':108, 'h':0,   's':0.00, 'l':0.40 },
  \ { 'index':243, 'hex':'#767676', 'r':118, 'g':118, 'b':118, 'h':0,   's':0.00, 'l':0.46 },
  \ { 'index':244, 'hex':'#808080', 'r':128, 'g':128, 'b':128, 'h':0,   's':0.00, 'l':0.50 },
  \ { 'index':245, 'hex':'#8a8a8a', 'r':138, 'g':138, 'b':138, 'h':0,   's':0.00, 'l':0.54 },
  \ { 'index':246, 'hex':'#949494', 'r':148, 'g':148, 'b':148, 'h':0,   's':0.00, 'l':0.58 },
  \ { 'index':247, 'hex':'#9e9e9e', 'r':158, 'g':158, 'b':158, 'h':0,   's':0.00, 'l':0.61 },
  \ { 'index':248, 'hex':'#a8a8a8', 'r':168, 'g':168, 'b':168, 'h':0,   's':0.00, 'l':0.65 },
  \ { 'index':249, 'hex':'#b2b2b2', 'r':178, 'g':178, 'b':178, 'h':0,   's':0.00, 'l':0.69 },
  \ { 'index':250, 'hex':'#bcbcbc', 'r':188, 'g':188, 'b':188, 'h':0,   's':0.00, 'l':0.73 },
  \ { 'index':251, 'hex':'#c6c6c6', 'r':198, 'g':198, 'b':198, 'h':0,   's':0.00, 'l':0.77 },
  \ { 'index':252, 'hex':'#d0d0d0', 'r':208, 'g':208, 'b':208, 'h':0,   's':0.00, 'l':0.81 },
  \ { 'index':253, 'hex':'#dadada', 'r':218, 'g':218, 'b':218, 'h':0,   's':0.00, 'l':0.85 },
  \ { 'index':254, 'hex':'#e4e4e4', 'r':228, 'g':228, 'b':228, 'h':0,   's':0.00, 'l':0.89 },
  \ { 'index':255, 'hex':'#eeeeee', 'r':238, 'g':238, 'b':238, 'h':0,   's':0.00, 'l':0.93 }
\ ]

