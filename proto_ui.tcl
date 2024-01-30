#!/usr/bin/wish
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

menu .menu -tearoff 0
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

menubutton .fraToolbar.mBtnH -text "Titulos" -direction below -menu .fraToolbar.mBtnH.items
menu .fraToolbar.mBtnH.items -tearoff 0
foreach bn {1 2 3 4 5 6} {.fraToolbar.mBtnH.items add command -label "Título $bn" -command {}} 

menubutton .fraToolbar.mBtnIt -text "Cursiva" -direction below 
menubutton .fraToolbar.mBtnB -text "Negrita" -direction below 

menubutton .fraToolbar.mBtnL -text "Listas" -direction below -menu .fraToolbar.mBtnL.items
menu .fraToolbar.mBtnL.items -tearoff 0
 .fraToolbar.mBtnL.items add command -label "Lista desordenada" -command {}
 .fraToolbar.mBtnL.items add command -label "Lista numerada" -command {}

menubutton .fraToolbar.mBtnCod -text "Código" -direction below -menu .fraToolbar.mBtnCod.items
menu .fraToolbar.mBtnCod.items -tearoff 0
 .fraToolbar.mBtnCod.items add command -label "Código en texto" -command {}
 .fraToolbar.mBtnCod.items add command -label "Bloque de código" -command {}

menubutton .fraToolbar.mBtnLnk -text "Enlace" -direction below 
menubutton .fraToolbar.mBtnImg -text "Imagen" -direction below 
menubutton .fraToolbar.mBtnR -text "Línea horizontal" -direction below 

pack .fraToolbar.mBtnH -side left
pack .fraToolbar.mBtnIt -side left
pack .fraToolbar.mBtnB -side left
pack .fraToolbar.mBtnL -side left
pack .fraToolbar.mBtnCod -side left
pack .fraToolbar.mBtnLnk -side left
pack .fraToolbar.mBtnImg -side left
pack .fraToolbar.mBtnR -side left
pack .fraToolbar -side top -anchor c

#frame .fraleft 
#ttk::scrollbar .fraleft.scroll -command ".fraleft.list yview"
#listbox .fraleft.list -yscroll ".fraleft.scroll set" -setgrid 1 -height 12
#pack .fraleft.scroll -side right -fill y
#pack .fraleft.list -side left -expand 1 -fill both
#pack .fraleft -side left -fill y

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
			limpiarTexto $textarea
			cargarTexto $textarea $file
		}
    } else {
		set file [tk_getSaveFile -filetypes $types -parent . \
		-initialfile sin_nombre -defaultextension .md]
    }
}

proc nuevoArchivo {tw} {
	global openedfile
	limpiarTexto $tw
	set openedfile ""
}

proc limpiarTexto {tw} {$tw delete 1.0 end}

proc cargarTexto {tw fname} {
	global openedfile
	set f [open $fname]
	while {![eof $f]} {
		$tw insert end [read $f 10000]
	}
	set openedfile $fname
}
