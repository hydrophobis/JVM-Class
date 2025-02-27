
ACC_PUBLIC	 = 0x0001
ACC_PRIVATE	 = 0x0002
ACC_PROTECTED	 = 0x0004
ACC_STATIC	 = 0x0008
ACC_FINAL	 = 0x0010
ACC_SUPER	 = 0x0020
ACC_SYNCHRONIZED = 0x0020
ACC_NATIVE	 = 0x0100
ACC_INTERFACE	 = 0x0200
ACC_ABSTRACT	 = 0x0400
ACC_STRICT	 = 0x0800

macro u1 [v] { db v }
macro u2 [v] { db (v) shr 8,(v) and 0FFh }
macro u4 [v] { db (v) shr 24,((v) shr 16) and 0FFh,((v) shr 8) and 0FFh,(v) and 0FFh }

macro constant_pool {

  u2 constant_pool_count
  constant_pool_counter = 1

  struc constant_utf8 [string] \{
    common
      . = constant_pool_counter
      constant_pool_counter = constant_pool_counter + 1
      local ..data,..length
      u1 1
      u2 ..length
      ..data: db string
      ..length = $ - ..data
  \}

  struc constant_integer value \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 3
    u4 value
  \}

  struc constant_float value \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 4
    u4 value
  \}

  struc constant_long value \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 5
    u4 value shr 32,value and 0FFFFFFFFh
  \}

  struc constant_double value \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 6
    u4 value shr 32,value and 0FFFFFFFFh
  \}

  struc constant_class name_index \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 7
    u2 name_index
  \}

  struc constant_string string_index \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 8
    u2 string_index
  \}

  struc constant_fieldref class_index,name_and_type_index \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 9
    u2 class_index
    u2 name_and_type_index
  \}

  struc constant_methodref class_index,name_and_type_index \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 10
    u2 class_index
    u2 name_and_type_index
  \}

  struc constant_interfacemethodref class_index,name_and_type_index \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 11
    u2 class_index
    u2 name_and_type_index
  \}

  struc constant_nameandtype name_index,descriptor_index \{
    . = constant_pool_counter
    constant_pool_counter = constant_pool_counter + 1
    u1 12
    u2 name_index
    u2 descriptor_index
  \}

}

macro end_constant_pool {
  constant_pool_count = constant_pool_counter
  restruc constant_utf8,constant_integer,constant_float,constant_long,constant_double
  restruc constant_class,constant_string
  restruc constant_fieldref,constant_methodref,constant_interfacemethodref,constant_nameandtype
}

macro interfaces {
  u2 interfaces_count
  interfaces_counter = 0
  macro interface interface \{
    interfaces_counter = interfaces_counter + 1
    u2 interface
  \}
}

macro end_interfaces {
  interfaces_count = interfaces_counter
  purge interface
}

macro attributes {
  local count,counter
  attributes_count equ count
  attributes_counter equ counter
  u2 attributes_count
  attributes_counter = 0
  macro attribute attribute_name_index \{
    attributes_counter = attributes_counter + 1
    u2 attribute_name_index
    local start,length
    attribute_start equ start
    attribute_length equ length
    u4 attribute_length
    attribute_start = $
  \}
  macro end_attribute \{
    attribute_length = $ - attribute_start
    restore atribute_start,attribute_length
  \}
}

macro end_attributes {
  attributes_count = attributes_counter
  restore attributes_count,attributes_counter
  purge attribute
}

macro fields {
  u2 fields_count
  fields_counter = 0
  macro field_info access_flags,name_index,descriptor_index \{
    fields_counter = fields_counter + 1
    u2 access_flags
    u2 name_index
    u2 descriptor_index
    attributes
  \}
  macro end_field_info \{ end_attributes \}
}

macro end_fields {
  fields_count = fields_counter
  purge field_info,end_field_info
}

macro methods {
  u2 methods_count
  methods_counter = 0
  macro method_info access_flags,name_index,descriptor_index \{
    methods_counter = methods_counter + 1
    u2 access_flags
    u2 name_index
    u2 descriptor_index
    attributes
  \}
  macro end_method_info \{ end_attributes \}
}

macro end_methods {
  methods_count = methods_counter
  purge method_info,end_method_info
}

macro bytecode {
  local length
  bytecode_length equ length
  u4 bytecode_length
  bytecode_offset = $
  org 0
}

macro end_bytecode {
  bytecode_length = $
  org bytecode_offset+bytecode_length
  restore bytecode_length
}

macro exceptions {
  local length
  exception_table_length equ length
  u2 exception_table_length
  exception_counter = 0
  macro exception start_pc,end_pc,handler_pc,catch_type \{
    exception_counter = exception_counter + 1
    u2 start_pc
    u2 end_pc
    u2 handler_pc
    u2 catch_type
  \}
}

macro end_exceptions {
  exception_table_length = exception_counter
  restore exception_table_length
}

; BYTECODE

T_BOOLEAN = 4
T_CHAR	  = 5
T_FLOAT   = 6
T_DOUBLE  = 7
T_BYTE	  = 8
T_SHORT   = 9
T_INT	  = 10
T_LONG	  = 11

macro aaload { db 0x32 }

macro aastore { db 0x53 }

macro aconst_null { db 0x01 }

macro aload index { if index>=0 & index<=3
		      db 0x2a+index
		    else if index<100h
		      db 0x19,index
		    else
		      db 0xc4,0x19,(index) shr 8,(index) and 0FFh
		    end if }

macro anewarray class { db 0xbd,(class) shr 8,(class) and 0FFh }

macro areturn { db 0xb0 }

macro arraylength { db 0xbe }

macro astore index { if index>=0 & index<=3
		       db 0x4b+index
		     else if index<100h
		       db 0x3a,index
		     else
		       db 0xc4,0x3a,(index) shr 8,(index) and 0FFh
		     end if }

macro athrow { db 0xbf }

macro baload { db 0x33 }

macro bastore { db 0x54 }

macro bipush byte { if byte>-1 & byte<=5
		     db 0x03+byte
		    else
		     db 0x10,byte
		    end if }

macro caload { db 0x34 }

macro castore { db 0x55 }

macro checkcast class { db 0xc0,(class) shr 8,(class) and 0FFh }

macro d2f { db 0x90 }

macro d2i { db 0x8e }

macro d2l { db 0x8f }

macro dadd { db 0x63 }

macro daload { db 0x31 }

macro dastore { db 0x52 }

macro dcmpg { db 0x98 }

macro dcmpl { db 0x97 }

macro dconst_0 { db 0x0e }

macro dconst_1 { db 0x0f }

macro ddiv { db 0x6f }

macro dload index { if index>=0 & index<=3
		      db 0x26+index
		    else if index<100h
		      db 0x18,index
		    else
		      db 0xc4,0x18,(index) shr 8,(index) and 0FFh
		    end if }

macro dmul { db 0x6b }

macro dneg { db 0x77 }

macro drem { db 0x73 }

macro dreturn { db 0xaf }

macro dstore index { if index>=0 & index<=3
		       db 0x47+index
		     else if index<100h
		       db 0x39,index
		     else
		       db 0xc4,0x39,(index) shr 8,(index) and 0FFh
		     end if }

macro dsub { db 0x67 }

macro dup { db 0x59 }

macro dup_x1 { db 0x5a }

macro dup_x2 { db 0x5b }

macro dup2 { db 0x5c }

macro dup2_x1 { db 0x5d }

macro dup2_x2 { db 0x5e }

macro f2d { db 0x8d }

macro f2i { db 0x8b }

macro f2l { db 0x8c }

macro fadd { db 0x62 }

macro faload { db 0x30 }

macro fastore { db 0x51 }

macro fcmpg { db 0x96 }

macro fcmpl { db 0x95 }

macro fconst_0 { db 0x0b }

macro fconst_1 { db 0x0c }

macro fconst_2 { db 0x0d }

macro fdiv { db 0x6e }

macro fload index { if index>=0 & index<=3
		      db 0x22+index
		    else if index<100h
		      db 0x17,index
		    else
		      db 0xc4,0x17,(index) shr 8,(index) and 0FFh
		    end if }

macro fmul { db 0x6a }

macro fneg { db 0x76 }

macro frem { db 0x72 }

macro freturn { db 0xae }

macro fstore index { if index>=0 & index<=3
		       db 0x43+index
		     else if index<100h
		       db 0x38,index
		     else
		       db 0xc4,0x38,(index) shr 8,(index) and 0FFh
		     end if }

macro fsub { db 0x66 }

macro getfield index { db 0xb4,(index) shr 8,(index) and 0FFh }

macro getstatic index { db 0xb2,(index) shr 8,(index) and 0FFh }

macro goto branch { if branch-$>=-8000h & branch-$<8000h
		      offset = word branch-$
		      db 0xa7,(offset) shr 8,(offset) and 0FFh
		    else
		      offset = dword branch-$
		      db 0xc8,(offset) shr 24,((offset) shr 16) and 0FFh,((offset) shr 8) and 0FFh,(offset) and 0FFh
		    end if }

macro goto_w branch { offset = dword branch-$
		      db 0xc8,(offset) shr 24,((offset) shr 16) and 0FFh,((offset) shr 8) and 0FFh,(offset) and 0FFh }

macro i2b { db 0x91 }

macro i2c { db 0x92 }

macro i2d { db 0x87 }

macro i2f { db 0x86 }

macro i2l { db 0x85 }

macro i2s { db 0x93 }

macro iadd { db 0x60 }

macro iaload { db 0x2e }

macro iand { db 0x7e }

macro iastore { db 0x4f }

macro iconst_m1 { db 0x02 }

macro iconst_0 { db 0x03 }

macro iconst_1 { db 0x04 }

macro iconst_2 { db 0x05 }

macro iconst_3 { db 0x06 }

macro iconst_4 { db 0x07 }

macro iconst_5 { db 0x08 }

macro idiv { db 0x6c }

macro if_acmpeq branch { offset = word branch-$
			 db 0xa5,(offset) shr 8,(offset) and 0FFh }

macro if_acmpne branch { offset = word branch-$
			 db 0xa6,(offset) shr 8,(offset) and 0FFh }

macro if_icmpeq branch { offset = word branch-$
			 db 0x9f,(offset) shr 8,(offset) and 0FFh }

macro if_icmpne branch { offset = word branch-$
			 db 0xa0,(offset) shr 8,(offset) and 0FFh }

macro if_icmplt branch { offset = word branch-$
			 db 0xa1,(offset) shr 8,(offset) and 0FFh }

macro if_icmpge branch { offset = word branch-$
			 db 0xa2,(offset) shr 8,(offset) and 0FFh }

macro if_icmpgt branch { offset = word branch-$
			 db 0xa3,(offset) shr 8,(offset) and 0FFh }

macro if_icmple branch { offset = word branch-$
			 db 0xa4,(offset) shr 8,(offset) and 0FFh }

macro ifeq branch { offset = word branch-$
		    db 0x99,(offset) shr 8,(offset) and 0FFh }

macro ifne branch { offset = word branch-$
		    db 0x9a,(offset) shr 8,(offset) and 0FFh }

macro iflt branch { offset = word branch-$
		    db 0x9b,(offset) shr 8,(offset) and 0FFh }

macro ifge branch { offset = word branch-$
		    db 0x9c,(offset) shr 8,(offset) and 0FFh }

macro ifgt branch { offset = word branch-$
		    db 0x9d,(offset) shr 8,(offset) and 0FFh }

macro ifle branch { offset = word branch-$
		    db 0x9e,(offset) shr 8,(offset) and 0FFh }

macro ifnonnull branch { offset = word branch-$
			 db 0xc7,(offset) shr 8,(offset) and 0FFh }

macro ifnull branch { offset = word branch-$
		      db 0xc6,(offset) shr 8,(offset) and 0FFh }

macro iinc index,const { if index<100h & const<80h & const>=-80h
			   db 0x84,index,const
			 else
			   db 0xc4,0x84,(index) shr 8,(index) and 0FFh,(const) shr 8,(const) and 0FFh
			 end if }

macro iload index { if index>=0 & index<=3
		      db 0x1a+index
		    else if index<100h
		      db 0x15,index
		    else
		      db 0xc4,0x15,(index) shr 8,(index) and 0FFh
		    end if }

macro imul { db 0x68 }

macro ineg { db 0x74 }

macro instanceof index { db 0xc1,(index) shr 8,(index) and 0FFh }

macro invokedynamic index { db 0xba,(index) shr 8,(index) and 0FFh,0,0 }

macro invokeinterface index,count { db 0xb9,(index) shr 8,(index) and 0FFh,count }

macro invokespecial index { db 0xb7,(index) shr 8,(index) and 0FFh }

macro invokestatic index { db 0xb8,(index) shr 8,(index) and 0FFh }

macro invokevirtual index { db 0xb6,(index) shr 8,(index) and 0FFh }

macro ior { db 0x80 }

macro irem { db 0x70 }

macro ireturn { db 0xac }

macro ishl { db 0x78 }

macro ishr { db 0x7a }

macro istore index { if index>=0 & index<=3
		       db 0x3b+index
		     else if index<100h
		       db 0x36,index
		     else
		       db 0xc4,0x36,(index) shr 8,(index) and 0FFh
		     end if }

macro isub { db 0x64 }

macro iushr { db 0x7c }

macro ixor { db 0x82 }

macro jsr branch { if branch-$>=-8000h & branch-$<8000h
		     offset = word branch-$
		     db 0xa8,(offset) shr 8,(offset) and 0FFh
		   else
		     offset = dword branch-$
		     db 0xc9,(offset) shr 24,((offset) shr 16) and 0FFh,((offset) shr 8) and 0FFh,(offset) and 0FFh
		   end if }

macro jsr_w branch { offset = dword branch-$
		     db 0xc9,(offset) shr 24,((offset) shr 16) and 0FFh,((offset) shr 8) and 0FFh,(offset) and 0FFh }

macro l2d { db 0x8a }

macro l2f { db 0x89 }

macro l2i { db 0x88 }

macro ladd { db 0x61 }

macro laload { db 0x2f }

macro land { db 0x7f }

macro lastore { db 0x50 }

macro lcmp { db 0x94 }

macro lconst_0 { db 0x09 }

macro lconst_1 { db 0x0a }

macro ldc index { if index<100h
		   db 0x12,index
		  else
		   db 0x13,(index) shr 8,(index) and 0FFh
		  end if}

macro ldc_w index { db 0x13,(index) shr 8,(index) and 0FFh }

macro ldc2_w index { db 0x14,(index) shr 8,(index) and 0FFh }

macro ldiv { db 0x6d }

macro lload index { if index>=0 & index<=3
		      db 0x1e+index
		    else if index<100h
		      db 0x16,index
		    else
		      db 0xc4,0x16,(index) shr 8,(index) and 0FFh
		    end if }

macro lmul { db 0x69 }

macro lneg { db 0x75 }

; macro lookupswitch { db 0xab,... }

macro lor { db 0x81 }

macro lrem { db 0x71 }

macro lreturn { db 0xad }

macro lshl { db 0x79 }

macro lshr { db 0x7b }

macro lstore index { if index>=0 & index<=3
		       db 0x3f+index
		     else if index<100h
		       db 0x37,index
		     else
		       db 0xc4,0x37,(index) shr 8,(index) and 0FFh
		     end if }

macro lsub { db 0x65 }

macro lushr { db 0x7d }

macro lxor { db 0x83 }

macro monitorenter { db 0xc2 }

macro monitorexit { db 0xc3 }

macro multianewarray index,dimensions { db 0xc5,(index) shr 8,(index) and 0FFh,dimensions }

macro new index { db 0xbb,(index) shr 8,(index) and 0FFh }

macro newarray atype { db 0xbc,atype }

macro nop { db 0x00 }

macro pop { db 0x57 }

macro pop2 { db 0x58 }

macro putfield index { db 0xb5,(index) shr 8,(index) and 0FFh }

macro putstatic index { db 0xb3,(index) shr 8,(index) and 0FFh }

macro ret index { if index<100h
		    db 0xa9,index
		  else
		    db 0xc4,0xa9,(index) shr 8,(index) and 0FFh
		  end if }

macro return { db 0xb1 }

macro saload { db 0x35 }

macro sastore { db 0x56 }

macro sipush short { db 0x11,(short) shr 8,(short) and 0FFh }

macro swap { db 0x5f }

; macro tableswitch { db 0xaa,... }

macro breakpoint { db 0xca }

macro impdep1 { db 0xfe }

macro impdep2 { db 0xff }
macro impdep2 { db 0xff }
