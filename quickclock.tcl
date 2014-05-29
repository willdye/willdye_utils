#!/usr/bin/env wish
# This is just a quick little script to create a small on-screen "dashboard".
# It includes an alarm clock, system load display, and an email notifier.
# It's very site-specific (and ugly), so it's not for for general use, but it
# might serve as an inspiration for some other script.  --willdye, circa 2007
wm withdraw .; toplevel .q ;# This seems to fix some troubles i had earlier.
wm override .q 1 ;# The window manager ignores us (always on top, no decor).

set ::normal_bg "blue4" ;# default background color, adjust manually
set ::alert_dir /users/willdye/.willdye/alerts ;# alert flags and procs
set top_gap  818 ;# gap from the top of the screen -- adjust manually
set ourwidth 20 ;# our own width -- adjust manually, depends on the font
set ::font_big lucidasans-bold-12
set ::font_mid lucidasans-bold-10
set ::font_small lucidasans-8

# Calculate placement position.  It should be flush with the right side, just
# a few pixels from the top.  The gap at the top should leave access room for
# the window control buttons ("little X") on the window that's underneath us.
set w [winfo screenwidth .]
if { $w >= 3200 } { set w 1600 } ;# for dual monitors, adjust manually
if { $w >= 2400 } { set w 1200 } ;# for dual monitors, adjust manually
set w [expr { $w - $ourwidth } ] ;# estimate of label width, adjust manually 
wm geometry .q "+6+$top_gap" ;# hopefully the lower-left corner in 1280x1024

# pass a parm to override geometry (yes, it isn't a good general practice to
# execute user-specified parms as raw code, but in this case we don't care.)
if { $argc > 0 } { wm geometry .q $argv }

# "dayo" means day of the week (come mister tally man, tally me banana).
foreach i {load date dayo hour mins secs} {
    label .q.$i -textvar $i -bg $::normal_bg -fg white -takefocus 0 \
        -font $::font_big -highlightthickness 0 -padx 0 -pady 0
    pack .q.$i -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 }

foreach i {load date dayo secs} {.q.$i configure -font $::font_small}

# Clicking anywhere on the clock should silence any active alarms.
bind .q <Button> {
    foreach i [winfo chi .q] {$i configure -bg $::normal_bg}
    exec /users/willdye/bin/alert_low_clear.sh ;# create a clear-all button?
    exec /users/willdye/bin/alert_high_clear.sh }

# Yes, this approach is buggy and hard to extend, but it's "good enough".
proc infinite_loop {} {
    scan [clock format [clock seconds] -format "%a %d %H %M %S"] \
        "%s %s %s %s %s" ::dayo ::date ::hour ::mins ::secs
    
    set ::load [expr round([lindex [exec cat /proc/loadavg] 0])]
    # set ::load [expr {[regexp {.*average:(.*?),.*} \
    #       [exec uptime] - ::load] ? round($::load) : "???"}]
    
    if {[string is integer $::load] && [expr {$::load > 7}]
    } then {.q.load configure -font $::font_big -fg red
    } else {.q.load configure -font $::font_mid -fg white }
    
    raise .q ;# This is wasteful, but sometimes another app can get on top.
    
    foreach {widget alerted filename} {
        load orange low_priority.flag
        date green2 high_priority.flag
        secs red    mail_hi.flag
    } {
        set flagged [file size $::alert_dir/$filename]
        set bgcolor [expr {$flagged ? $alerted : $::normal_bg}]
        .q.$widget configure -bg $bgcolor }
    after 999 [info level 0] }

infinite_loop
