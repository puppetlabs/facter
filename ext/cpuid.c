#include <ruby.h>

static VALUE CpuidModule = Qnil;

void Init_cpuid(void);

static VALUE find(VALUE _self, VALUE leaf_param) {
  int result[5] = {0};
  unsigned int leaf = FIX2UINT(leaf_param);
  unsigned int subleaf = 0;

#if defined(__i386__) && defined(__PIC__)
        // ebx is used for PIC purposes on i386, so we need to manually
        // back it up. The compiler's register allocator can't do this
        // for us, because ebx is permanently reserved in its view.
        // see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=47602
        // We may not need this at all on modern GCCs, but ¯\_(ツ)_/¯
        asm volatile(
            "mov %%ebx,%k1; cpuid; xchgl %%ebx,%k1"
            : "=a" (result[0]), "=&r" (result[1]), "=c" (result[2]), "=d" (result[3])
            : "a" (leaf), "c" (subleaf));
#elif defined(__i386__) || defined(__x86_64__)
        asm volatile(
            "cpuid"
            : "=a" (result[0]), "=b" (result[1]), "=c" (result[2]), "=d" (result[3])
            : "a" (leaf), "c" (subleaf));
#endif

  return rb_str_new_cstr((char*)&result[1]);
}

void
Init_cpuid()
{   CpuidModule = rb_define_module("Cpuid");
    rb_define_module_function(CpuidModule, "find", find, 1);
}
