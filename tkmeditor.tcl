#!/usr/bin/wish 
#
# TkMeDitor : Tcl/Tk Markdown Editor
# Version DEV-0.1
# Author: Silvano Emanuel Roqués
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

package require Tk

# ----- Variables globales -----
set openedfile ""
set persistentmd ""
# -----

wm title . "TKMeDitor"
wm iconname . "text"

set menustatus "    "
frame .statusBar
label .statusBar.label -textvariable menustatus -relief sunken -bd 1 -font "Helvetica 10" -anchor w
pack .statusBar.label -side left -padx 2 -expand yes -fill both
pack .statusBar -side bottom -fill x -pady 2

menu .menu
menu .menu.file -tearoff 0
.menu add cascade -label "Archivo" -menu .menu.file -underline 0
.menu.file add command -label "Nuevo" -command {newFile .text}
.menu.file add command -label "Abrir" -command {fileDialog .text "open"}
.menu.file add command -label "Guardar" -command {saveFile .text $openedfile}
.menu.file add command -label "Guardar como..." -command {fileDialog .text "saveAs"}
.menu.file add separator
.menu.file add command -label "Salir" -command {destroy .}

. configure -menu .menu

frame .fraToolbar

menubutton .fraToolbar.mBtnH -text "Títulos" -direction below -menu .fraToolbar.mBtnH.items
menu .fraToolbar.mBtnH.items -tearoff 0
foreach bn {1 2 3 4 5 6} {
	set mark [string repeat "#" $bn]
	.fraToolbar.mBtnH.items add command -label "Título $bn" -command "putLineMarkdown .text $mark"
} 

button .fraToolbar.mBtnIt -text "Cursiva" -command {putInlineMarkdown .text "*"} -relief flat
button .fraToolbar.mBtnB -text "Negrita" -command {putInlineMarkdown .text "**"}  -relief flat

menubutton .fraToolbar.mBtnL -text "Listas" -direction below -menu .fraToolbar.mBtnL.items
menu .fraToolbar.mBtnL.items -tearoff 0
 .fraToolbar.mBtnL.items add command -label "Lista desordenada" -command {setLinePersistentFormat .text "*"}
 .fraToolbar.mBtnL.items add command -label "Lista numerada"

menubutton .fraToolbar.mBtnCod -text "Código" -direction below -menu .fraToolbar.mBtnCod.items
menu .fraToolbar.mBtnCod.items -tearoff 0 -relief raised
 .fraToolbar.mBtnCod.items add command -label "Código en texto" -command {putInlineMarkdown .text "`"}
 .fraToolbar.mBtnCod.items add command -label "Bloque de código" -command {putInlineMarkdown .text "\n```\n"}

button .fraToolbar.mBtnLnk -text "Enlace" -relief flat -command {putTwoFieldsMarkdown .text}
button .fraToolbar.mBtnImg -text "Imagen" -relief flat -command {putTwoFieldsMarkdown .text true}
button .fraToolbar.mBtnR -text "Línea horizontal" -relief flat -command {putHLine .text}

pack .fraToolbar.mBtnH -side left
pack .fraToolbar.mBtnIt -side left
pack .fraToolbar.mBtnB -side left
pack .fraToolbar.mBtnL -side left
pack .fraToolbar.mBtnCod -side left
pack .fraToolbar.mBtnLnk -side left
pack .fraToolbar.mBtnImg -side left
pack .fraToolbar.mBtnR -side left
pack .fraToolbar -side top -anchor c

text .text -yscrollcommand [list .scroll set] -setgrid 1 \
	-height 30 -undo 1 -autosep 1
ttk::scrollbar .scroll -command [list .text yview]
pack .scroll -side right -fill y
pack .text -expand yes -fill both

bind Menu <<MenuSelect>> {
    global $menustatus
    if {[catch {%W entrycget active -label} label]} {
	set label "    "
    }
    set menustatus $label
    update idletasks
}

bind .text <KeyPress> {
    global persistentmd
    set cursor_position [%W index insert]
    if {%k == 36 || %k == 104} {
		# If persistentmd is setted
        if [string length $persistentmd] {
            set line [lindex [split $cursor_position '.'] 0]
            # If last item is empty
            if {[%W get $line.0 $line.end-1c]==$persistentmd} {
                %W delete $line.0 $line.end
                unsetLinePersistentFormat
            } else {
                after idle {
                    putLineMarkdown %W $persistentmd
                }
            }
        }
    }
}

proc setLinePersistentFormat {tw mark} {
    global persistentmd
    set persistentmd $mark
    putLineMarkdown $tw $mark
}

proc unsetLinePersistentFormat {} {
    global persistentmd
    set persistentmd ""
}

proc fileDialog {textarea operation} {
    set types {
		{"Markdown"		{.md}	}
		{"Todos los archivos"		*}}
    if {$operation == "open"} {
		set file [tk_getOpenFile -filetypes $types -parent . ]
		if {[string compare $file ""]} {
			clearText $textarea
			loadFile $textarea $file
		}
    } elseif {$operation == "saveAs"} {
		set file [tk_getSaveFile -filetypes $types -parent . \
			-initialfile sin_nombre -defaultextension .md]
		if {$file != ""} {
			saveFile $textarea $file
		}
		#else cancelado
    }
}

proc newFile {tw} {
	global openedfile
	clearText $tw
	set openedfile ""
}

proc clearText {tw} {$tw delete 1.0 end}

proc loadFile {tw fname} {
	global openedfile
	set f [open $fname]
	while {![eof $f]} {
		$tw insert end [read $f 10000]
	}
	set openedfile $fname
}

proc saveFile {tw fname} {
	global openedfile
	if {$fname == ""} {
		fileDialog $tw "saveAs"
		return
	}
	set x [catch {set fid [open $fname w+]}]
	set y [catch {puts $fid [$tw get 1.0 end-1c]}]
	set z [catch {close $fid}]
	if { $x || $y || $z || ![file exists $fname] || ![file isfile $fname] || ![file readable $fname] } {
		tk_messageBox -parent . -icon error \
			-message "Ocurrió un error al guardar \"$fname\""
	} else {
		tk_messageBox -parent . -icon info \
			-message "Archivo guardado"
		set openedfile $fname
	}
}

proc putHLine {tw} {
	set cursor_position [$tw index insert]
	# If line is not empty begin with LF
	if {[$tw count -displaychars "$cursor_position linestart" "$cursor_position lineend"]} {
		$tw insert "$cursor_position lineend" "\n"
		# Then update cursor_position
		set cursor_position [$tw index insert]
	}
	$tw insert "$cursor_position lineend" "\n-----\n\n"
}

proc putLineMarkdown {tw mark} {
	set selection_range [$tw tag ranges sel]
	# If a selection range is set then separate it to a new line for use as content 
	if {[string length $selection_range]} {
		$tw insert "[lindex $selection_range 0]" "\n"
	}
	# What we are interested in is the line number from cursor position
	set cursor_position [$tw index insert]
	# Add $mark at begining of line
	$tw insert "$cursor_position linestart" "$mark "
}

proc putInlineMarkdown {tw mark} {
	set selection_range [$tw tag ranges sel]
	# If exists a selection use it as content
	if {[string length $selection_range]} {
		$tw insert [lindex $selection_range 1] $mark //1
		$tw insert [lindex $selection_range 0] $mark
	} else {
		set cursor_position [$tw index insert]
		$tw insert $cursor_position "$mark$mark"
		# Move cursor inside the marks
		$tw mark set insert "$cursor_position + [string length $mark] chars"
	}
}

proc putTwoFieldsMarkdown {tw {is_image false}} {
	set selection_range [$tw tag ranges sel]
	# If exists a selection use it as first field content
	if {[string length $selection_range]} {
		# cursor_position will be used for put ! at begining if is_image
		set cursor_position [lindex $selection_range 0]
		$tw insert [lindex $selection_range 1] "\]\(URL\)" //1
		$tw insert [lindex $selection_range 0] "\["
	# If not exists a selection use default texts as first field content
	} else {
		set cursor_position [$tw index insert]
		if {$is_image} {set sufix "alternativo"} else {set sufix "del enlace"}
		$tw insert $cursor_position "\[Texto $sufix\]\(URL\)"
	}
	if {$is_image} {$tw insert $cursor_position !}
}

focus .text
.text mark set insert 0.0
