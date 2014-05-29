#!/usr/bin/env wish
# If the specified color seems visually "dark", return the string "white".
# Otherwise, return "black".  Used to make the foreground text on a colored
# button more visible (white text on dark buttons, black on light buttons).
# Ideally this should auto-adjust based on the color depth, but it doesn't.

proc blackWhite {comparison_color} {
    foreach {r g b} [winfo rgb . $comparison_color] {}
    if {[expr $r*.3+$g*.59+$b*.11]/[expr [lindex [winfo rgb . white] 0]]<.5} {
        return "white"}
    return "black"}

proc setColor {{ignored {}}} {
    set hexval [format "%02X%02X%02X" $::red $::green $::blue]
    .butfrm.visual.button conf -background       "#$hexval"
    .butfrm.visual.button conf -activebackground "#$hexval"
    .butfrm.visual.button conf -foreground       [blackWhite "\#$hexval"]
    .butfrm.visual.button conf -activeforeground [blackWhite "\#$hexval"]}

set max_component 255
set red   0
set blue  0
set green 0

wm title . "Black or white text on a colored button"
pack [frame .butfrm -width 150 -height 200] -expand 1 -fill both
pack [frame .butfrm.visual]
pack [button .butfrm.visual.button \
          -height 10 -width 50 -text [wm title .]]
pack [frame .butfrm.sliders] -expand 1 -fill x
setColor

foreach component {red green blue} {
    pack [scale .butfrm.sliders.$component \
              -from 0 \
              -to $::max_component \
              -showvalue 1 \
              -sliderrelief raised \
              -sliderlength 30 \
              -troughcolor $component \
              -variable ::$component \
              -command {setColor} \
              -orient horizontal ] -expand 1 -fill x }

