# JVM-Class
 Java hello world class written in Assembly

This project is compiled with *fasm* and *cargo*<br>
Prints generic strings<br>
Loads a .dll or .so named either name.dll or libname.so and runs the jni function called test<br>
.dll/.so code is in the lib dir

Run ```./build``` to build the lib, the assembly and run the program

Original source of 'jclass.inc' and 
'bytecode.inc' is likely [this](https://foro.elhacker.net/programacion_general/programacion_en_ensamblador_de_java_hola_mundo-t365953.0.html)
spanish forum post
