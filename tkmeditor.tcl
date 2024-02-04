#!/usr/bin/wish 
#
# TkMeDitor : Tcl/Tk Markdown Editor
# Version DEV-0.1

package require Tk

# ----- Variables globales -----
set openedfile ""
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
.menu.file add command -label "Nuevo" -command {nuevoArchivo .text}
.menu.file add command -label "Abrir" -command {fileDialog .text "open"}
.menu.file add command -label "Guardar" -command {}
.menu.file add command -label "Guardar como..." -command {fileDialog .text "save"}
.menu.file add separator
.menu.file add command -label "Salir" -command {destroy .}

. configure -menu .menu

frame .fraToolbar

menubutton .fraToolbar.mBtnH -text "T�tulos" -direction below -menu .fraToolbar.mBtnH.items
menu .fraToolbar.mBtnH.items -tearoff 0
foreach bn {1 2 3 4 5 6} {
	.fraToolbar.mBtnH.items add command -label "T�tulo $bn"
} 

button .fraToolbar.mBtnIt -text "Cursiva" -command {putMarkdown .text "*" true} -relief flat
button .fraToolbar.mBtnB -text "Negrita" -command {putMarkdown .text "**" true}  -relief flat

menubutton .fraToolbar.mBtnL -text "Listas" -direction below -menu .fraToolbar.mBtnL.items
menu .fraToolbar.mBtnL.items -tearoff 0
 .fraToolbar.mBtnL.items add command -label "Lista desordenada"
 .fraToolbar.mBtnL.items add command -label "Lista numerada"

menubutton .fraToolbar.mBtnCod -text "C�digo" -direction below -menu .fraToolbar.mBtnCod.items
menu .fraToolbar.mBtnCod.items -tearoff 0 -relief raised
 .fraToolbar.mBtnCod.items add command -label "C�digo en texto" -command {putMarkdown .text "`" true}
 .fraToolbar.mBtnCod.items add command -label "Bloque de c�digo" -command {}

button .fraToolbar.mBtnLnk -text "Enlace" -relief flat
button .fraToolbar.mBtnImg -text "Imagen" -relief flat
button .fraToolbar.mBtnR -text "L�nea horizontal" -relief flat

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

proc fileDialog {textarea operation} {
    set types {
		{"Markdown"		{.md}	}
		{"Todos los archivos"		*}}
    if {$operation == "open"} {
		set file [tk_getOpenFile -filetypes $types -parent . ]
		if {[string compare $file ""]} {
			ClearText $textarea
			loadFile $textarea $file
		}
    } else {
		set file [tk_getSaveFile -filetypes $types -parent . \
		-initialfile sin_nombre -defaultextension .md]
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

proc putMarkdown {tw mark {nested false}} {
	set selection_range [$tw tag ranges sel]
	if {[string length $selection_range]} {
		if {$nested} {
			$tw insert [lindex $selection_range 1] $mark //1
		}
		$tw insert [lindex $selection_range 0] $mark
	} else {
		set cursor_position [$tw index insert]
		if {$nested} {
			$tw insert $cursor_position "$mark$mark"
		}
		$tw mark set insert "$cursor_position + [string length $mark] chars"
		set cursor_position [$tw index insert]
	}
}

focus .text
.text mark set insert 0.0