# Adeel Asghar [adeel.asghar@liu.se]
# 2011-jul-29 21:01:29

Unicode true

!ifndef PLATFORMVERSION
  !error "Argument PLATFORMVERSION is not set. Call with argument /DPLATFORMVERSION=32 or /DPLATFORMVERSION=64"
!endif

!ifndef OMVERSION
  !error "Argument OMVERSION is not set. Call with argument /DOMVERSION=OpenModelica version tag"
!endif

!ifndef PRODUCTVERSION
  !error "Argument PRODUCTVERSION is not set. Call with argument /DPRODUCTVERSION=OpenModelica version"
!endif

Name OpenModelica${OMVERSION}-${PLATFORMVERSION}bit

# General Symbol Definitions
!define REGKEY "SOFTWARE\OpenModelica"
!define VERSION ${OMVERSION}-${PLATFORMVERSION}bit
!define COMPANY "Open Source Modelica Consortium (OSMC) and Linköping University (LiU)."
!define URL "http://www.openmodelica.org/"
BrandingText "Copyright $2 OpenModelica"  ; The $2 variable is filled in the Function .onInit after calling GetLocalTime function.

# MultiUser Symbol Definitions
!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_DEFAULT_CURRENTUSER
!define MULTIUSER_INSTALLMODE_COMMANDLINE

# MUI Symbol Definitions
!define MUI_ICON "icons\OpenModelica.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_WELCOMEFINISHPAGE_BITMAP "images\openmodelica.bmp"
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_WELCOMEPAGE_TEXT "The installer will guide you through the steps required to install $(^Name) on your computer.$\r$\n$\r$\n$\r$\nThe package includes OpenModelica, a Modelica modeling, compilation and simulation environment based on free software."
!define MUI_STARTMENUPAGE_REGISTRY_ROOT SHCTX
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "OpenModelica"
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Start OpenModelica Connection Editor (OMEdit)"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchOMEdit"
!define MUI_UNICON "icons\OpenModelica.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "images\openmodelica.bmp"

; !defines for use with SHChangeNotify
!ifdef SHCNE_ASSOCCHANGED
!undef SHCNE_ASSOCCHANGED
!endif
!define SHCNE_ASSOCCHANGED 0x08000000
!ifdef SHCNF_FLUSH
!undef SHCNF_FLUSH
!endif
!define SHCNF_FLUSH        0x1000
 
!macro UPDATEFILEASSOC
; Using the system.dll plugin to call the SHChangeNotify Win32 API function so we
; can update the shell.
  System::Call "shell32::SHChangeNotify(i,i,i,i) (${SHCNE_ASSOCCHANGED}, ${SHCNF_FLUSH}, 0, 0)"
!macroend

# Included files
!include MultiUser.nsh
!include Sections.nsh
!include MUI2.nsh
# Include for some of the windows messages defines
!include "winmessages.nsh"
!include "FileAssociation.nsh"
!include "CustomFunctions.nsh"

; HKLM (all users) vs HKCU (current user) defines
!define ENV_HKLM 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
!define ENV_HKCU 'HKCU "Environment"'

# Variables
Var StartMenuGroup

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes
OutFile "OpenModelica.exe"
CRCCheck on
XPStyle on
ShowInstDetails hide
VIProductVersion ${PRODUCTVERSION}
VIAddVersionKey ProductName "OpenModelica"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
ShowUninstDetails hide

# Installer sections
Section "OpenModelica Core" Section1
  SectionIn RO
  SetOverwrite on
  # Create bin directory and copy files in it
  SetOutPath "\\?\$INSTDIR\bin"
  File "..\build\bin\*"
  File "..\OSMC-License.txt"
  # Copy the openssl binaries
!if ${PLATFORMVERSION} == "32"
  File "bin\32bit\libeay32.dll"
  File "bin\32bit\libssl32.dll"
  File "bin\32bit\ssleay32.dll"
!else
  File "bin\64bit\libeay32.dll"
  File "bin\64bit\libssl-1_1-x64.dll"
  File "bin\64bit\ssleay32.dll"
!endif
  # Copy the qt plugins
  File /r /x "*.svn" "$%OMDEV%\tools\msys\mingw${PLATFORMVERSION}\share\qt5\plugins\*"
  # Create the bin\osgPlugins-3.6.5 directory
  SetOutPath "\\?\$INSTDIR\bin\osgPlugins-3.6.5"
  File /r /x "*.svn" "$%OMDEV%\tools\msys\mingw${PLATFORMVERSION}\bin\osgPlugins-3.6.5\*"
  # Create bin\ffi directory and copy files in it
  SetOutPath "\\?\$INSTDIR\bin\ffi"
  File "..\build\bin\ffi\*"
!if /FILEEXISTS "..\build\bin\omc-semla\*.*"
  # Create bin\omc-semla directory and copy files in it
  SetOutPath "\\?\$INSTDIR\bin\omc-semla"
  File /r "..\build\bin\omc-semla\*"
!endif
  # Create icons directory and copy files in it
  SetOutPath "\\?\$INSTDIR\icons"
  File /r /x "*.svn" "icons\*"
  File "..\OMEdit\OMEditLIB\Resources\icons\omedit.ico"
  File "..\OMOptim\OMOptim\GUI\Resources\omoptim.ico"
  File "..\OMPlot\OMPlot\OMPlotGUI\Resources\icons\omplot.ico"
  File "..\OMShell\OMShell\OMShellGUI\Resources\omshell.ico"
  File "..\OMNotebook\OMNotebook\OMNotebookGUI\Resources\OMNotebook_icon.ico"
  # Create include\omc directory and copy files in it
  SetOutPath "\\?\$INSTDIR\include\omc"
  File /r /x "*.svn" "..\build\include\omc\*"
  # Create lib\omc directory and copy files in it
  SetOutPath "\\?\$INSTDIR\lib\omc"
  File /r /x "*.svn" /x "*.git" "..\build\lib\omc\*"
  # Create lib\python directory and copy files in it
  SetOutPath "\\?\$INSTDIR\lib\python"
  File /r /x "*.svn" /x "*.git" "..\build\lib\python\*"
  # Copy the OMSimulator libs
  SetOutPath "\\?\$INSTDIR\lib"
  File "..\build\lib\libOMSimulator.a"
  File "..\build\lib\libOMSimulatorLua.a"
  # Copy the OMSimulator py files
  SetOutPath "\\?\$INSTDIR\lib\OMSimulator"
  File /r "..\build\lib\OMSimulator\*"
  # Create tools directory and copy files in it
  SetOutPath "\\?\$INSTDIR\tools"
  # copy the setup file / readme
  File "$%OMDEV%\tools\MSYS_SETUP*"
  # Create msys directory and copy files in it
  SetOutPath "\\?\$INSTDIR\tools\msys"
!if ${PLATFORMVERSION} == "32"
  File /r /x "mingw64" /x "group" /x "passwd" /x "pacman.log" /x "tmp\*.*" /x "*.pyc" /x "libQt5*.*" \
      /x "moc.exe" /x "qt*.qch" /x "Qt5*.dll" /x "libwx*.*" /x "libgtk*.*" /x "qtcreator" /x "rcc.exe" \
      /x "testcon.exe" /x "libsicu*.*" /x "libicu*.*" /x "wx*.dll" /x "libosg*.*" /x "Adwaita" /x "OpenSceneGraph" /x "gtk-doc" \
      /x "poppler" /x "man" /x "libdbus.*" /x "tcl*.*" /x "avcodec*.*" /x "windeployqt.exe" /x "python3.5" /x "mingw_osg*.*" \
      /x "ActiveQt" /x "Qt3DCore" /x "Qt3DInput" /x "Qt3DLogic" /x "Qt3DQuick" /x "Qt3DQuickInput" \
      /x "Qt3DQuickRender" /x "Qt3DRender" /x "QtBluetooth" /x "QtCLucene" /x "QtConcurrent" /x "QtCore" \
      /x "QtDBus" /x "QtDesigner" /x "QtDesignerComponents" /x "QtGui" /x "QtHelp" /x "QtLabsControls" \
      /x "QtLabsTemplates" /x "QtLocation" /x "QtMultimedia" /x "QtMultimediaQuick_p" /x "QtMultimediaWidgets" \
      /x "QtNetwork" /x "QtNfc" /x "QtOpenGL" /x "QtOpenGLExtensions" /x "QtPlatformHeaders" /x "QtPlatformSupport" \
      /x "QtPositioning" /x "QtPrintSupport" /x "QtQml" /x "QtQmlDevTools" /x "QtQuick" /x "QtQuickParticles" \
      /x "QtQuickTest" /x "QtQuickWidgets" /x "QtScript" /x "QtScriptTools" /x "QtSensors" /x "QtSerialBus" \
      /x "QtSerialPort" /x "QtSql" /x "QtSvg" /x "QtTest" /x "QtUiPlugin" /x "QtUiTools" /x "QtWebChannel" \
      /x "QtWebKit" /x "QtWebKitWidgets" /x "QtWebSockets" /x "QtWidgets" /x "QtWinExtras" /x "QtXml" /x "QtXmlPatterns" \
      /x "osg" /x "osgAnimation" /x "osgDB" /x "osgFX" /x "osgGA" /x "osgManipulator" /x "osgParticle" /x "osgPresentation" \
      /x "osgQt" /x "osgShadow" /x "osgSim" /x "osgTerrain" /x "osgText" /x "osgUI" /x "osgUtil" /x "osgViewer" \
      /x "osgVolume" /x "osgWidget" /x "clang-cl.exe" /x "clang-check.exe" /x "llvm-lto2.exe" /x "doc" \
      "$%OMDEV%\tools\msys\*"
!else
  File /r /x "mingw32" /x "group" /x "passwd" /x "pacman.log" /x "tmp\*.*" /x "*.pyc" /x "libQt5*.*" \
      /x "moc.exe" /x "qt*.qch" /x "Qt5*.dll" /x "libwx*.*" /x "libgtk*.*" /x "qtcreator" /x "rcc.exe" \
      /x "testcon.exe" /x "libsicu*.*" /x "libicu*.*" /x "wx*.dll" /x "libosg*.*" /x "Adwaita" /x "OpenSceneGraph" /x "gtk-doc" \
      /x "poppler" /x "man" /x "libdbus.*" /x "tcl*.*" /x "avcodec*.*" /x "windeployqt.exe" /x "python3.5" /x "mingw_osg*.*" \
      /x "ActiveQt" /x "Qt3DCore" /x "Qt3DInput" /x "Qt3DLogic" /x "Qt3DQuick" /x "Qt3DQuickInput" \
      /x "Qt3DQuickRender" /x "Qt3DRender" /x "QtBluetooth" /x "QtCLucene" /x "QtConcurrent" /x "QtCore" \
      /x "QtDBus" /x "QtDesigner" /x "QtDesignerComponents" /x "QtGui" /x "QtHelp" /x "QtLabsControls" \
      /x "QtLabsTemplates" /x "QtLocation" /x "QtMultimedia" /x "QtMultimediaQuick_p" /x "QtMultimediaWidgets" \
      /x "QtNetwork" /x "QtNfc" /x "QtOpenGL" /x "QtOpenGLExtensions" /x "QtPlatformHeaders" /x "QtPlatformSupport" \
      /x "QtPositioning" /x "QtPrintSupport" /x "QtQml" /x "QtQmlDevTools" /x "QtQuick" /x "QtQuickParticles" \
      /x "QtQuickTest" /x "QtQuickWidgets" /x "QtScript" /x "QtScriptTools" /x "QtSensors" /x "QtSerialBus" \
      /x "QtSerialPort" /x "QtSql" /x "QtSvg" /x "QtTest" /x "QtUiPlugin" /x "QtUiTools" /x "QtWebChannel" \
      /x "QtWebKit" /x "QtWebKitWidgets" /x "QtWebSockets" /x "QtWidgets" /x "QtWinExtras" /x "QtXml" /x "QtXmlPatterns" \
      /x "osg" /x "osgAnimation" /x "osgDB" /x "osgFX" /x "osgGA" /x "osgManipulator" /x "osgParticle" /x "osgPresentation" \
      /x "osgQt" /x "osgShadow" /x "osgSim" /x "osgTerrain" /x "osgText" /x "osgUI" /x "osgUtil" /x "osgViewer" \
      /x "osgVolume" /x "osgWidget" /x "clang-cl.exe" /x "clang-check.exe" /x "llvm-lto2.exe" /x "doc" \
      "$%OMDEV%\tools\msys\*"
!endif
  # create OMTLMSimulator directory
  SetOutPath "\\?\$INSTDIR\OMTLMSimulator\bin"
  File /r "..\OMSimulator\OMTLMSimulator\bin\*"
  SetOutPath "\\?\$INSTDIR\OMTLMSimulator\Documentation"
  File /oname=OMTLMSimulator.pdf "..\OMSimulator\OMTLMSimulator\Documentation\TLMPlugin.pdf"
  SetOutPath "\\?\$INSTDIR\OMTLMSimulator\CompositeModels"
  File /r "..\OMSimulator\OMTLMSimulator\CompositeModels\*"
  # Create share directory and copy files in it
  SetOutPath "\\?\$INSTDIR\share"
  File /r /x "*.svn" /x "*.git" "..\build\share\*"
  # Copy the OpenModelica web page & users guide url shortcut
  SetOutPath "\\?\$INSTDIR\share\doc\omc"
  File "..\doc\OpenModelica Project Online.url"
  File "..\doc\OpenModelicaUsersGuide.url"
  # Copy OMSens directory
  SetOutPath "\\?\$INSTDIR\share\OMSens"
  File /r /x ".git*" "..\build\share\OMSens\*"
SectionEnd

Section -Main SEC0000
    # create the file with InstallMode
  FileOpen $4 "$INSTDIR\InstallMode.txt" w
  FileWrite $4 $MultiUser.InstallMode
  FileClose $4
  # set the rights for all users
  AccessControlW::GrantOnFile "$INSTDIR" "(BU)" "FullAccess"
  # Remove any OPENMODELICALIBRARY environment variable
  DeleteRegValue ${ENV_HKCU} OPENMODELICALIBRARY
  DeleteRegValue ${ENV_HKLM} OPENMODELICALIBRARY
  # create environment variables
  IfSilent KeepOMDEV ; if silent install mode is enabled then skip OMDEV message.
  ReadRegStr $R0 ${ENV_HKLM} OMDEV
  ReadRegStr $R1 ${ENV_HKCU} OMDEV
  ${If} $R0 == ""
  ${AndIf} $R1 == ""
    Goto KeepOMDEV
  ${Else}
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
    "OMDEV environment variable is set.  \
    $\n$\nClick `OK` to remove it. \
    $\nClick `Cancel` to keep it. If you choose to keep it then make sure you update it." \
    IDOK RemoveOMDEV \
    IDCANCEL KeepOMDEV
  ${EndIf}
RemoveOMDEV:
  DeleteRegValue ${ENV_HKLM} OMDEV
  DeleteRegValue ${ENV_HKCU} OMDEV
KeepOMDEV:
  StrCmp $MultiUser.InstallMode "AllUsers" 0 +3
    WriteRegExpandStr ${ENV_HKLM} OPENMODELICAHOME "$INSTDIR\"
    Goto +2
    WriteRegExpandStr ${ENV_HKCU} OPENMODELICAHOME "$INSTDIR\"
  # make sure windows knows about the change i.e we created the environment variables.
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

Section -post SEC0001
  # generate group and passwd files for this machine!
  Exec '"$INSTDIR\tools\msys\usr\bin\mkpasswd.exe" -l -c > $INSTDIR\tools\msys\etc\passwd'
  Exec '"$INSTDIR\tools\msys\usr\bin\mkgroup.exe" -l -c > $INSTDIR\tools\msys\etc\group'
  # Rename libeay32.dll and ssleay32.dll as they seem to have issues on some newer Windows versions
  # https://trac.openmodelica.org/OpenModelica/ticket/5909 https://www.openmodelica.org/forum/default-topic/2944-installation-problems
!if ${PLATFORMVERSION} == "32"
  Rename "$INSTDIR\tools\msys\mingw32\bin\libeay32.dll" "$INSTDIR\tools\msys\mingw32\bin\libeay32-O.dll"
  Rename "$INSTDIR\tools\msys\mingw32\bin\ssleay32.dll" "$INSTDIR\tools\msys\mingw32\bin\ssleay32-O.dll"
!else
  Rename "$INSTDIR\tools\msys\mingw64\bin\libeay32.dll" "$INSTDIR\tools\msys\mingw64\bin\libeay32-O.dll"
  Rename "$INSTDIR\tools\msys\mingw64\bin\ssleay32.dll" "$INSTDIR\tools\msys\mingw64\bin\ssleay32-O.dll"
!endif
  # do post installation actions
  WriteRegStr SHCTX "${REGKEY}" Path $INSTDIR
  WriteUninstaller $INSTDIR\Uninstall.exe
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  # set the output path to temp directory which is used as a start in option for shortcuts.
  SetOutPath "\\?\$TEMP"
  # create shortcuts
  CreateDirectory "$SMPROGRAMS\$StartMenuGroup"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Connection Editor.lnk" "$INSTDIR\bin\OMEdit.exe" \
  "" "$INSTDIR\icons\omedit.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Notebook.lnk" "$INSTDIR\bin\OMNotebook.exe" \
  "" "$INSTDIR\icons\OMNotebook_icon.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Optimization Editor.lnk" "$INSTDIR\bin\OMOptim.exe" \
  "" "$INSTDIR\icons\omoptim.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Shell.lnk" "$INSTDIR\bin\OMShell.exe" \
  "" "$INSTDIR\icons\omshell.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Website.lnk" "$INSTDIR\share\doc\omc\OpenModelica Project Online.url" \
  "" "$INSTDIR\icons\IExplorer.ico"
  SetOutPath "\\?\$INSTDIR\"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Uninstall OpenModelica.lnk" "$INSTDIR\Uninstall.exe" \
  "" "$INSTDIR\icons\OpenModelica.ico"
  CreateDirectory "$SMPROGRAMS\$StartMenuGroup\Documentation"
  SetOutPath ""
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - Users Guide.lnk" "$INSTDIR\share\doc\omc\OpenModelicaUsersGuide.url" \
  "" "$INSTDIR\icons\IExplorer.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - Users Guide.pdf.lnk" "$INSTDIR\share\doc\omc\OpenModelicaUsersGuide-latest.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - MetaProgramming Guide.pdf.lnk" "$INSTDIR\share\doc\omc\SystemDocumentation\OpenModelicaMetaProgramming.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - Modelica Tutorial by Peter Fritzson.pdf.lnk" "$INSTDIR\share\doc\omc\ModelicaTutorialFritzson.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - System Guide.pdf.lnk" "$INSTDIR\share\doc\omc\SystemDocumentation\OpenModelicaSystem.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateDirectory "$SMPROGRAMS\$StartMenuGroup\PySimulator"
  SetOutPath ""
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\PySimulator\README.lnk" "$INSTDIR\share\omc\scripts\PythonInterface\PySimulator\README.md"
  !insertmacro MUI_STARTMENU_WRITE_END
  ${registerExtension} "$INSTDIR\bin\OMEdit.exe" ".mo" "OpenModelica Connection Editor"
  ${registerExtension} "$INSTDIR\bin\OMNotebook.exe" ".onb" "OpenModelica Notebook"
  # make sure windows knows about the change
  !insertmacro UPDATEFILEASSOC
  WriteRegStr SHCTX "SOFTWARE\OpenModelica" InstallMode $MultiUser.InstallMode
  WriteRegStr SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" DisplayName "$(^Name)"
  WriteRegStr SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" DisplayVersion "${VERSION}"
  WriteRegStr SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" Publisher "${COMPANY}"
  WriteRegStr SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" URLInfoAbout "${URL}"
  WriteRegStr SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" DisplayIcon $INSTDIR\Uninstall.exe
  WriteRegStr SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" UninstallString $INSTDIR\Uninstall.exe
  WriteRegDWORD SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" NoModify 1
  WriteRegDWORD SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" NoRepair 1
SectionEnd

# Uninstaller sections
Section "Uninstall"
  FileOpen $4 "$INSTDIR\InstallMode.txt" r
  FileSeek $4 0 ; we want to start reading at the 0th byte
  FileRead $4 $1 ; we read until the end of line (including carriage return and new line) and save it to $1
  FileClose $4 ; and close the file
  StrCmp $1 "AllUsers" 0 +4
    DeleteRegValue ${ENV_HKLM} OPENMODELICAHOME
    SetShellVarContext all
    Goto +3
    DeleteRegValue ${ENV_HKCU} OPENMODELICAHOME
    SetShellVarContext current
  DeleteRegKey SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica"
  Delete $INSTDIR\Uninstall.exe
  # delete the shortcuts and the start menu folder
  !insertmacro MUI_STARTMENU_GETFOLDER Application $R1
  # delete the shortcuts and the start menu folder  
  Delete "$SMPROGRAMS\$R1\OpenModelica Connection Editor.lnk"
  Delete "$SMPROGRAMS\$R1\OpenModelica Notebook.lnk"
  Delete "$SMPROGRAMS\$R1\OpenModelica Optimization Editor.lnk"
  Delete "$SMPROGRAMS\$R1\OpenModelica Shell.lnk"
  Delete "$SMPROGRAMS\$R1\OpenModelica Website.lnk"
  Delete "$SMPROGRAMS\$R1\Uninstall OpenModelica.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - API - HowTo.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - MetaProgramming Guide.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - Modelica Tutorial by Peter Fritzson.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - System Guide.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - Users Guide.pdf.lnk"
  RMDir "$SMPROGRAMS\$R1\Documentation"
  Delete "$SMPROGRAMS\$R1\PySimulator\README.lnk"
  RMDir "$SMPROGRAMS\$R1\PySimulator"
  RMDir "$SMPROGRAMS\$R1"
  ${unregisterExtension} ".mo" "OpenModelica Connection Editor"
  ${unregisterExtension} ".onb" "OpenModelica Notebook"
  # make sure windows knows about the change
  !insertmacro UPDATEFILEASSOC
  DeleteRegValue SHCTX "${REGKEY}" StartMenuGroup
  DeleteRegValue SHCTX "${REGKEY}" Path
  DeleteRegKey SHCTX "${REGKEY}"
  RmDir /r $INSTDIR
  # make sure windows knows about the change i.e we deleted the environment variables.
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

# Installer functions
Function .onInit
  # Read the current local time of the system and then extract the year from it. This value is then used in Branding Text.
  Call GetLocalTime
  Pop $0  ; Day
  Pop $1  ; Month
  Pop $2  ; Year
  ; Check to see if already installed
  ReadRegStr $R2 SHCTX "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" "UninstallString"
  IfFileExists $R2 +1 NotInstalled
    IfSilent uninst ; if silent install mode is enabled then also uninstall silently.
      MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
      "OpenModelica is already installed on your machine. $\n$\nClick `OK` to uninstall and install again. \
      $\nClick `Cancel` to quit the setup." \
      IDOK uninst
      Quit
uninst:
  Push "\Uninstall.exe" ; divider str
  Push $R2 ; input string
  Call GetLastPart
  Pop $R1 ; last part
  Pop $R0 ; first part
  IfSilent +1 +3 ; if silent install mode is enabled then also uninstall silently.
    ExecWait "$R2 /S _?=$R0" ; _? switch blocks until the uninstall is done.
    Goto +2
  ExecWait "$R2 _?=$R0" ; _? switch blocks until the uninstall is done.
  RmDir /r $INSTDIR ; since we are running the Uninstall.exe so it was not deleted in the uninstallation process. Makesure we remove the $INSTDIR.
NotInstalled:
  InitPluginsDir
  !insertmacro MULTIUSER_INIT
  !include x64.nsh
  ; check for /D flag
  ${If} $INSTDIR != ""
    ; /D was used so we don't set the installation path
  ${Else}
    ;set initial value for $INSTDIR
    StrCpy $INSTDIR "$PROGRAMFILES\$(^Name)"
    ${If} ${RunningX64}
    ${AndIf} ${PLATFORMVERSION} == "64"
      ; disable registry redirection (enable access to 64-bit portion of registry)
      SetRegView 64
      ; change install dir 
      StrCpy $INSTDIR "$PROGRAMFILES64\$(^Name)"
    ${EndIf}
  ${EndIf}
  ; check for /S flag
  IfSilent +1 +4 ; in silent install mode set multiuser to AllUsers.
    StrCpy $MultiUser.InstallMode "AllUsers"
    SetShellVarContext all
    Goto +3
  StrCpy $MultiUser.InstallMode "CurrentUser"
  SetShellVarContext current
FunctionEnd

Function LaunchOMEdit
  ; Yes we need to set environment variables before starting OMEdit because nsis can't read the new environment variables set by the installer.
  System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("OPENMODELICAHOME", "$INSTDIR\").r0'
  ; Try to unset OPENMODELICALIBRARY environment variable
  System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("OPENMODELICALIBRARY", NULL).r0'
  ; ExecShell passes the elevated UAC of the installer process to OMEdit and as a result drag and drop on OMEdit will not work. Use Exec instead of ExecShell
  ; ExecShell "" "$INSTDIR\bin\OMEdit.exe"
  Exec '"$WINDIR\explorer.exe" "$INSTDIR\bin\OMEdit.exe"'
FunctionEnd

# Uninstaller functions
Function un.onInit
  # Read the current local time of the system and then extract the year from it. This value is then used in Branding Text.
  Call un.GetLocalTime
  Pop $0  ; Day
  Pop $1  ; Month
  Pop $2  ; Year
  !insertmacro MULTIUSER_UNINIT
FunctionEnd
