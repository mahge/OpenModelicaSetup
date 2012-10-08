#!/bin/bash -x
# script to build the OpenModelica release
# Adrian Pop [adrian.pop@liu.se]
# 2012-10-08

# expects to have these things installed:
#  python 2.7.x
#  nsis installer
#  TortoiseSVN command line tools
#  Qt 4.8.0
#  jdk


# set the path to our tools
export PATH=/c/bin/python273:/c/Program\ Files/TortoiseSVN/bin/:/c/bin/jdk170/bin:/c/bin/nsis/:/c/bin/QtSDK/Desktop/Qt/4.8.0/mingw/bin:$PATH

# set the OPENMODELICAHOME and OPENMODELICALIBRARY
export OPENMODELICAHOME="c:\\dev\\OpenModelica\\build"
export OPENMODELICALIBRARY="c:\\dev\\OpenModelica\\build\\lib\\omlibrary"

# have OMDEV in Msys version
export OMDEV=/c/OMDev/

# update OMDev
cd /c/OMDev/
svn up

# update OpenModelica
cd /c/dev/OpenModelica
svn up
# get the revision
export REVISION=`svn info | grep "Revision:" | cut -d " " -f 2`
# Directory prefix
export PREFIX="/c/dev/OpenModelica_releases/${REVISION}/"

# test if exists and exit if it does
if [ -d "${PREFIX}" ]; then
	echo "Revision ${PREFIX} already exists! Exiting ..."
	exit 0
fi

# create the revision directory
mkdir -p ${PREFIX}
# make the file prefix
export FILE_PREFIX="${PREFIX}OpenModelica-revision-${REVISION}"

# update OpenModelicaSetup
cd /c/dev/OpenModelica/Compiler/OpenModelicaSetup
svn up

# build OpenModelica
cd /c/dev/OpenModelica
make -f Makefile.omdev.mingw clean
make -f Makefile.omdev.mingw omc
make -f Makefile.omdev.mingw install-python

# build the .qm files from .ts files for OMEdit
cd /c/dev/OpenModelica/OMEdit/OMEditGUI/Resources/nls
lrelease *.ts

# build the installer
cd /c/dev/OpenModelica/Compiler/OpenModelicaSetup
makensisw /V4 OpenModelicaSetup.nsi
# move the installer
mv OpenModelica.exe ${FILE_PREFIX}.exe

# gather the svn log
cd /c/dev/OpenModelica
svn log -v -r ${REVISION}:1 > ${FILE_PREFIX}-ChangeLog.txt

# make the readme
export DATESTR=`date +"%Y-%m-%d_%H-%M"`
echo "Automatic build of OpenModelica by testwin.openmodelica.org at date: ${DATESTR} from revision: ${REVISION}" >> ${FILE_PREFIX}-README.txt
echo "Read OpenModelica-*-ChangeLog.txt for more info on changes." >> ${FILE_PREFIX}-README.txt
echo "See also (match revision ${REVISION} to build jobs):" >> ${FILE_PREFIX}-README.txt
echo "  https://test.openmodelica.org/hudson/" >> ${FILE_PREFIX}-README.txt
echo "  http://test.openmodelica.org/~marsj/MSL31/BuildModelRecursive.html" >> ${FILE_PREFIX}-README.txt
echo "  http://test.openmodelica.org/~marsj/MSL32/BuildModelRecursive.html" >> ${FILE_PREFIX}-README.txt
cat >> ${FILE_PREFIX}-README.txt <<DELIMITER
*Instructions to prepare test information if you find a bug:*
 
generate a .mos script file loading all libraries and files your model need call simulate.
// start .mos script
loadModel(Modelica);
loadFile("yourfile.mo");
simulate(YourModel);
// end .mos script

Start this .mos script in a shell with omc and use the debug flags
+d=dumpdaelow,optdaedump,bltdump,dumpindxdae,backenddaeinfo.
Redirect the output stream in file ( > log.txt)

A series of commands to run via cmd.exe
is given below. Note that z: is the drive
where your .mos script is:
c:\> z:
z:\> cd \path\to\script(.mos)\file\
z:\path\to\script(.mos)\file\> \path\to\OpenModelica\bin\omc.exe
+d=dumpdaelow,optdaedump,bltdump,dumpindxdae,backenddaeinfo 
YourScriptFile.mos > log.txt 2>&1

Either send the log.txt file alongwith your bug 
description to OpenModelica@ida.liu.se or file a
bug in our bug tracker:
  https://trac.openmodelica.org/OpenModelica

Happy testing!
DELIMITER
echo " " >> ${FILE_PREFIX}-README.txt
echo "Read more about OpenModelica at https://openmodelica.org" >> ${FILE_PREFIX}-README.txt
echo "Contact us at OpenModelica@ida.liu.se for further issues or questions." >> ${FILE_PREFIX}-README.txt

# make the testsuite-trace
echo "Check HUDSON testserver for the testsuite trace here (match revision ${REVISION} to build jobs): " >> ${FILE_PREFIX}-testsuite-trace.txt
echo "  https://test.openmodelica.org/hudson/" >> ${FILE_PREFIX}-testsuite-trace.txt

