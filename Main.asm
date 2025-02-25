include 'jclass.inc'

format binary as 'class'

  u4 0xcafebabe           ; magic number
  u2 0,49                 ; minor and major version

  constant_pool
      ;--- Essential Attribute & Method Names ---
      _Code           constant_utf8 'Code'
      _main           constant_utf8 'main'
      _void_arrstr    constant_utf8 '([Ljava/lang/String;)V'

      ;--- Class Name & Superclass ---
      Test_class      constant_class _Test
      _Test           constant_utf8 'Main'
      Object_class    constant_class _Object
      _Object         constant_utf8 'java/lang/Object'

      ;--- System.out and PrintStream References ---
      System.out      constant_fieldref System_class, out_field
      System_class    constant_class _System
      _System         constant_utf8 'java/lang/System'
      out_field       constant_nameandtype _out, PrintStream_type
      _out            constant_utf8 'out'
      PrintStream_type constant_utf8 'Ljava/io/PrintStream;'

      PrintStream_println constant_methodref PrintStream_class, println_method
      PrintStream_class constant_class _PrintStream
      _PrintStream    constant_utf8 'java/io/PrintStream'
      println_method  constant_nameandtype _println, _void_str
      _println        constant_utf8 'println'
      _void_str       constant_utf8 '(Ljava/lang/String;)V'

      ;--- Integer.toString for converting numbers ---
      Integer_toString constant_methodref Integer_class, toString_method
      Integer_class    constant_class _Integer
      _Integer         constant_utf8 'java/lang/Integer'
      toString_method  constant_nameandtype _toString, _str_int
      _toString        constant_utf8 'toString'
      _str_int         constant_utf8 '(I)Ljava/lang/String;'

      ;--- Demo Constants ---
      Hello          constant_utf8 'Hello'
      Hello_again    constant_utf8 'Hello again!'
      number         constant_integer 1234

  end_constant_pool


  ;--- Class Declaration ---
  u2 ACC_PUBLIC+ACC_SUPER    ; access flags
  u2 Test_class              ; this class ("Test")
  u2 Object_class            ; superclass (java/lang/Object)

  interfaces
  end_interfaces

  fields
  end_fields

  methods

    ;--- Main Method: public static void main(String[] args) ---
    method_info ACC_PUBLIC+ACC_STATIC, _main, _void_arrstr
      attribute _Code
        u2 3   ; max_stack – enough to hold System.out, constants, etc.
        u2 1   ; max_locals – one local (the String[] args, unused)
        bytecode
            ; Print "Hello"
            getstatic System.out
            ldc Hello  ; Use the constant pool index for 'Hello'
            invokevirtual PrintStream_println

            ; Print "Hello again!"
            getstatic System.out
            ldc Hello_again  ; Use the constant pool index for 'Hello again!'
            invokevirtual PrintStream_println

            ; Print number (converted to String)
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

  end_methods

  attributes
  end_attributes
