########################################################################
#
# deja_source.tcl
#
# here's a little debugging tool that i occasionally use when working on
# tcl programs.  it will monitor a particular file to see when it is
# updated.  when the file is updated, it can automatically issue a
# 'source' command on that file.  the idea is that every time you save
# changes to the tcl program file that you are editing, it is
# automatically fired up to see if its working now. 
#
# note you have to write your program in such a way that it does not
# freak out if the same file is sourced in again.  for example, if you
# create some widgets inside your program, put a destroy on them at the
# top of your file, so the the widgets are created afresh if the file is
# sourced.  check out "deja_initialize" for an example.  
#
# typical usage: fire up a wish console.  source the file you are
# editing, make sure it can handle being sourced a second time, then add
# a line to set the tk app name ("tk appname foobar" for example).  then
# fire up a second wish console and source in this file.  type
# 'deja_source <filename> <appname>' to get things rolling.  it should
# automatically send a 'source' command every time the edited file's
# timestamp changes.
#
########################################################################

# Resourcery: the following innocent line creates a proc named like the
# source file, which when called re-sources it:

#    proc [file tail [info script]] {} "source [info script]"

#    bind . <KeyPress-`> [list source [info script]]
#    puts "--=> sourcing [file tail [info script]]"

# Usage: include this line in files you're currently editing. Call the
# file name (without path) interactively (e.g. from a console) when you
# saved a major improvement (;-) to your file. RS

# ... and a twist on that: autoupdate Imagine you edit a file foo.tcl that
# does fancy things in your Tk application. Order once

#    uptodate foo.tcl

# and have it automatically re-sourced whenever you saved to disk:

if 0 {
    proc uptodate {filename {last_time 0} {delay 1000}} {
	set filename [file join [pwd] $filename]
	set  modtime [file mod_time   $filename]
	if {$modtime > $last_time} {
	    source  $filename}
	after $delay [list uptodate $filename $modtime $delay]
    }
}

#############################################################################
#############################################################################
#############################################################################
#############################################################################


# here's the global vars.  i don't really need this here, but the c coder 
# in me prefers to have all globals specifically declared at the top. 

set deja_vars(uninitialized) "(uninitialized)"


    



# initialize the state array, etc.  if this is getting called for the 
# second time, due to debugging in progress, try to get things back to 
# a fresh start.  

proc deja_initialize {} {
    
    global deja_vars
    
    # if this file has been sourced before, try to get a fresh start
    
    puts "cancelling pending after command(s): [after info]"
    foreach i [after info] {after cancel $i}
    
    puts "destroying widgets: [winfo chi .]"
    eval destroy [winfo chi .]
    
    puts "unsetting the array 'deja_vars'"
    if [info exists deja_vars] {unset deja_vars}
    
    # initialize globals.  oh, i used '[list ...]' instead of '{}' 
    # because want the "clock format" stuff to be evaluated.
    
    array set deja_vars \
	[list \
	     file_name        no_file_name_specified \
	     clock_time       [clock format [clock seconds]] \
	     timestamp        no_time_stamp_yet \
	     appname          no_appname_specified \
	     debug_procs_file "/users/willdye/bin/debug_procs.tcl" \
	    ]
    
    # set up the display widgets
    
    deja_array_display deja_vars
    
    set deja_vars(return_codes) \
	"\nto start auto-refreshes, type:
         \ndeja_source (or just 'deja') (file name) (tk appname)"
    
    set deja_vars(geometry) {-0+30}
    
    message .return_codes                \
	-textvar deja_vars(return_codes) \
	-bg      white                   \
        -width   300                     \
	
    pack .return_codes -fill x -side bottom
    
    # set up bindings
    #
    # 2do: replace this bind with buttons to start/stop/force auto
    # refresh.  also add buttons for setting file/appname, and even
    # searching for active appnames out there.  also file browser, eh?  
    # and a way to fire up a wish console for the app direct from the 
    # display.  hmm.  come to think of it, maybe just getting a real 
    # debugger would be simpler and better.  um, nevermind then...
    
    bind . <Button-1> deja_refresh
    
    # finally, dump a message to the console, just in case.
    
    puts $deja_vars(return_codes)
}



# this doesn't really need to be a separate proc, but i'm interested in
# developing the concept of an array of strongly typed vars that allow
# for automatic, resilient stuff like tracing, bounded updating,
# debugging, display, and whatever.  plus its more re-usable this way.

proc deja_array_display {array_name} {
    
    upvar $array_name array_local
    
    if [winfo exists .$array_name] {
	puts "destroying .$array_name.  I hope that's what you wanted."
	destroy .$array_name
    }
    
    frame    .$array_name
    pack     .$array_name -fill both -expand 1
    
    foreach i [lsort [array names array_local]] {
	
	frame    .$array_name.$i
	pack     .$array_name.$i -fill both -expand 1
	
	label .$array_name.$i.descrip   \
	    -text   "$i :"              \
	    -width  12                  \
	    -anchor e                   \
	    -padx   3                   \
	    
	label .$array_name.$i.entries   \
	    -textvar "$array_name\($i)" \
	    -width   30                 \
	    -anchor  w                  \
	    -relief  ridge              \
	    -padx    3                  \
	    
	pack .$array_name.$i.descrip -side left -fill x
	pack .$array_name.$i.entries -side left -fill both -expand 1
    }
}



# the proc that tries to issue the source command when the interp is
# created elsewhere.

proc deja_refresh {} {
    
    global deja_vars
    
    # at long last, issue the command this whole dubious file has been 
    # created to support.  drumroll, please...
    
    catch {
	
	#send $deja_vars(appname) source $deja_vars(debug_procs_file)
	#send $deja_vars(appname) debug_init_2
	send $deja_vars(appname) source $deja_vars(file_name)
	
    } deja_vars(return_codes)
    
    # if there was any trouble, complain about it.
    
    if {[string length $deja_vars(return_codes)] != 0} {
	
	catch {wm deiconify .}
	catch {raise .}
	catch {.return_codes config -bg yellow}
	
	puts ""
	puts "--------------------------------( deja_source -- begin messages)"
	puts [clock format [clock seconds]]
	puts "$deja_vars(file_name)"
	puts "--------------------------------"
	puts "$deja_vars(return_codes)"
	puts "--------------------------------( deja_source ---- end messages)"
	
    } else {
	catch {.return_codes config -bg white}
    }	
}



# the proc that tries to issue the source command when the interp is
# created by deja.

proc deja_restart {} {
    
    global deja_vars
    
    # at long last, issue the command this whole dubious file has been 
    # created to support.  drumroll, please...
    
    catch {
	if [interp exists $deja_vars(appname)] {
	    # record the position (but not sizing) of the existing window.
#	     if {[string length $deja_vars(return_codes)] == 0} {
#		 catch {
#		     regsub \
#			 {^[[:digit:]]*x[[:digit:]]*} \
#			 [interp eval $deja_vars(appname) winfo geo .] \
#			 {} \
#			 deja_vars(geometry)
#		     puts "new: $deja_vars(geometry)"
#		 }
#	     }
	    # destroy the existing window.
	    interp delete $deja_vars(appname)
	}
	
	interp create $deja_vars(appname)
	
	# by default it doesnt have tk stuff, so load it in.
	load {} Tk $deja_vars(appname)
	
	interp eval $deja_vars(appname) tk appname $deja_vars(appname)
	
	interp eval $deja_vars(appname) \
	    [list source $deja_vars(debug_procs_file)]
	
	interp eval $deja_vars(appname) [list source $deja_vars(file_name)]
	
	# move it to the same position the old window was at.
	interp eval $deja_vars(appname) [list wm geo . $deja_vars(geometry)]
	
    } deja_vars(return_codes)
    
    # if there was any trouble, complain about it.
    
    if {[string length $deja_vars(return_codes)] != 0} {
	
	catch {wm deiconify .}
	catch {raise .}
	catch {.return_codes config -bg yellow}
	
	puts ""
	puts "--------------------------------( deja_source -- begin messages)"
	puts [clock format [clock seconds]]
	puts "$deja_vars(file_name)"
	puts "--------------------------------"
	puts "$deja_vars(return_codes)"
	puts "--------------------------------( deja_source ---- end messages)"
	
    } else {
	catch {.return_codes config -bg white}
    }
}



# the main proc for when the interp is created elsewhere.  note it calls
# itself a lot in most cases.

proc deja_source {{file_name "(none specified)"} {appname wish8.2}} {
    
    global deja_vars
    
    # update all the elements of the array 'deja_vars'
    
    set deja_vars(file_name) $file_name
    set deja_vars(appname)   $appname
    
    if [file exists $deja_vars(file_name)] {
	set latest_mtime      [file  mtime  $deja_vars(file_name)]
	set latest_time_stamp [clock format $latest_mtime]
    } else {
	set deja_vars(timestamp) 0
	set latest_time_stamp    0
    }
    
    set deja_vars(clock_time) [clock format [clock seconds]]
    
    # now check to see if we want a refresh
    
    if {[string compare "$latest_time_stamp" "$deja_vars(timestamp)"]} {
	set deja_vars(timestamp) $latest_time_stamp
	deja_refresh
    }
    
    # finally (this should always be last) set the alarm clock
    
    after 1000 [list deja_source $file_name $appname]
}




# the main proc for when the interp is created by deja.  note it calls
# itself a lot in most cases.

proc deja {{file_name "/users/willdye/deja_child.tcl"} {appname dj}} {
    
    global deja_vars
    
    # update all the elements of the array 'deja_vars'
    
    set deja_vars(file_name) $file_name
    set deja_vars(appname)   $appname
    
    if [file exists $deja_vars(file_name)] {
	set latest_mtime      [file  mtime  $deja_vars(file_name)]
	set latest_time_stamp [clock format $latest_mtime]
    } else {
	set deja_vars(timestamp) 0
	set latest_time_stamp    0
    }
    
    set deja_vars(clock_time) [clock format [clock seconds]]
    
    # now check to see if we want a refresh
    
    if {[string compare "$latest_time_stamp" "$deja_vars(timestamp)"]} {
	set deja_vars(timestamp) $latest_time_stamp
	deja_restart
    }
    
    # finally (this should always be last) set the alarm clock
    
    after 1000 [list deja $file_name $appname]
}



# fire up the initializer & that's all, folks.

if {! [info exists noinit]} {
    deja_initialize
}
