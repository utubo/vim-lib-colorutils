# vim-lib-colorutils
color utils for vimscript

⚠This is not plugin.

## Functions

- You can use `colorutils9#...` on vim9script, otherwithe use `colorutils#...`
- ⚠Functions does not validate arguments.

### colorutils9#rgb2hex(rgb: any): string
```vim
# example
echo colorutils9#rgb2hex({ 'r': 255, 'g': 128, 'b': 64 })
# -> '#ff8040'
```

### colorutils9#hex2rgb(hex: string): any
```vim
# example
echo colorutils9#hex2rgb('#ff8040')
# -> {'r': 255, 'g': 128, 'b': 64}
```

### colorutils9#rgb2hsl(rgb: any): any
```vim
# example
echo colorutils9#rgb2hsl({ 'r': 255, 'g': 128, 'b': 64 })
# -> {'h': 1.0, 'l': 20.104712, 's': 0.62549}
```

### colorutils9#hsl2rgb(hsl: any): any
```vim
# example
echo colorutils9#hsl2rgb('#ff8040')
# -> {'r': 255, 'g': 128, 'b': 64}
```
### colorutils9#hsl2hex(hsl: any): string

### colorutils9#hex2hsl(hex: string): any

### colorutils9#compare_distance_desc(x: any, y: any): number

### colorutils9#list_cterm_colors(hex: string): any
List cterm colors sort by similarity of "#rrggbb".

### colorutils9#find_cterm_color(hex: string): any
Return the approximate cterm color of "#rrggbb".
```vim
# example
echo colorutils9#find_cterm_color('#ffffff')
# -> {'index': 15, 'r': 255, 'g': 255, 'b': 255, 'h': 0, 'l': 1.0, 's': 0.0, 'distance': 0.0}
```

## RGB and HSL
- Ranges
  - r(Red): [0 : 255]
  - g(Green): [0 : 255]
  - b(Blue): [0 : 255]
  - h(Hue): [0 : 360]
  - s(Saturation): [0.0 : 1.0]
  - l(Lightness): [0.0 : 1.0]

## LICENSE
[WTFPL](https://www.wtfpl.net)
