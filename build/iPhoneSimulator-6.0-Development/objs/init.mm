#import <UIKit/UIKit.h>

extern "C" {
    void ruby_sysinit(int *, char ***);
    void ruby_init(void);
    void ruby_init_loadpath(void);
    void ruby_script(const char *);
    void ruby_set_argv(int, char **);
    void rb_vm_init_compiler(void);
    void rb_vm_init_jit(void);
    void rb_vm_aot_feature_provide(const char *, void *);
    void *rb_vm_top_self(void);
    void rb_rb2oc_exc_handler(void);
    void rb_exit(int);
void MREP_6ED486AB028E4213A6DE44A215685C2B(void *, void *);
void MREP_205258B3C86A4DDBBC0243188EBC8B47(void *, void *);
void MREP_98B17D5DE9DB4D27ADC118BCDC0CD88E(void *, void *);
void MREP_DE0B84C7B10640E7B399DDEFE4D5B018(void *, void *);
}

extern "C"
void
RubyMotionInit(int argc, char **argv)
{
    static bool initialized = false;
    if (!initialized) {
	ruby_init();
	ruby_init_loadpath();
        if (argc > 0) {
	    const char *progname = argv[0];
	    ruby_script(progname);
	}
	try {
	    void *self = rb_vm_top_self();
MREP_6ED486AB028E4213A6DE44A215685C2B(self, 0);
MREP_205258B3C86A4DDBBC0243188EBC8B47(self, 0);
MREP_98B17D5DE9DB4D27ADC118BCDC0CD88E(self, 0);
MREP_DE0B84C7B10640E7B399DDEFE4D5B018(self, 0);
	}
	catch (...) {
	    rb_rb2oc_exc_handler();
	}
	initialized = true;
    }
}
