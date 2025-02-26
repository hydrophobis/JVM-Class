macro_rules! jni_function {
    ($name:ident, $return_type:ty, ($($param:ident: $ptype:ty),*), $body:block) => {
        #[unsafe(no_mangle)]
        pub extern "C" fn $name(
            _env: *mut std::ffi::c_void, 
            _class: *mut std::ffi::c_void, 
            $($param: $ptype),*
        ) -> $return_type {
            $body
        }
    };
}

jni_function!(Java_Main_test, i32, (), {
    64
});