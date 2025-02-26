include 'jclass.asm'

format binary as 'class'

  u4 0xcafebabe           ; magic number
  u2 0,49                 ; minor and major version

  constant_pool
      ;--- Essential Attribute & Method Names ---
      _Code           constant_utf8 'Code'
      _main           constant_utf8 'main'
      _void_arrstr    constant_utf8 '([Ljava/lang/String;)V'

      ;--- Class Name & Superclass ---
      Main_class      constant_class _Main
      _Main           constant_utf8 'Main'
      Super_class    constant_class _Object
      _Object         constant_utf8 'java/lang/Object'

      ;--- System.out and PrintStream References ---
      System.out        constant_fieldref System_class, out_field
      System_class      constant_class _System
      _System           constant_utf8 'java/lang/System'
      out_field         constant_nameandtype _out, PrintStream_type
      _out              constant_utf8 'out'
      PrintStream_type  constant_utf8 'Ljava/io/PrintStream;'

      PrintStream_println constant_methodref PrintStream_class, println_method
      PrintStream_class constant_class _PrintStream
      _PrintStream      constant_utf8 'java/io/PrintStream'
      println_method    constant_nameandtype _println, _void_str
      _println          constant_utf8 'println'
      _void_str         constant_utf8 '(Ljava/lang/String;)V'

      System_loadLibrary       constant_methodref System_class, load_method
      load_method       constant_nameandtype _loadLibrary, _void_str
      _loadLibrary             constant_utf8 'loadLibrary'

      Library_path      constant_utf8 'name'
      Library_path_str  constant_string Library_path

      ;--- Native Method Reference ---
      nativeMethod_ref  constant_methodref Main_class, nativeMethod_type
      nativeMethod_type constant_nameandtype _nativeMethod, _int_void
      _nativeMethod     constant_utf8 'test'
      _str_void         constant_utf8 '()Ljava/lang/String;'


      ;--- Integer.toString for converting numbers ---
      _int_void constant_utf8 '()I'
      Integer_toString constant_methodref Integer_class, toString_method
      Integer_class    constant_class _Integer
      _Integer         constant_utf8 'java/lang/Integer'
      toString_method  constant_nameandtype _toString, _str_int
      _toString        constant_utf8 'toString'
      _str_int         constant_utf8 '(I)Ljava/lang/String;'

      ;--- Demo Constants ---
      Hello          constant_utf8 'Hello'
      Hello_str      constant_string Hello
      Hello_again    constant_utf8 'Hello again!'
      Hello_again_str constant_string Hello_again
      number         constant_integer 1234

  end_constant_pool


  ;--- Class Declaration ---
  u2 ACC_PUBLIC+ACC_SUPER    ; access flags
  u2 Main_class              ; this class
  u2 Super_class            ; superclass (java/lang/Object)

  interfaces
  end_interfaces

  fields
  end_fields

  methods

    ;--- Main Method: public static void main(String[] args) ---
    method_info ACC_PUBLIC+ACC_STATIC, _main, _void_arrstr
      attribute _Code
        u2 4   ; max_stack â enough to hold System.out, constants
        u2 2   ; max_locals â one local (the String[] args, unused)
        bytecode
            ldc Library_path_str  ; Push DLL path ("/workspaces/JVM-Class/lib<name>.so")
            invokestatic System_loadLibrary

            getstatic System.out       ; Load System.out
            invokestatic nativeMethod_ref  ; Call the native method (returns String)
            invokestatic Integer_toString
            invokevirtual PrintStream_println  ; Print the result

            ; Print "Hello"
            getstatic System.out
            ldc Hello_str  ; Use the constant pool index for 'Hello'
            invokevirtual PrintStream_println

            ; Print "Hello again!"
            getstatic System.out
            ldc Hello_again_str  ; Use the constant pool index for 'Hello again!'
            invokevirtual PrintStream_println

            ; Print number (as String)
            getstatic System.out
            ldc number  ; Directly push the constant integer
            invokestatic Integer_toString
            invokevirtual PrintStream_println

            return
        end_bytecode

        exceptions
        end_exceptions
        attributes
        end_attributes
      end_attribute
    end_method_info

    method_info ACC_PUBLIC+ACC_STATIC+ACC_NATIVE, _nativeMethod, _int_void

    end_method_info
  end_methods

  attributes
  end_attributes