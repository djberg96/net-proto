/***********************
 * proto.c (windows.c)
 ***********************/
#include <ruby.h>
#include <version.h>
#include <windows.h>

#ifdef __cplusplus
extern "C"
{
#endif

/*
 * call-seq:
 *    Proto.getprotobyname(name)
 *
 * Given a protocol string, returns the corresponding number, or nil if not
 * found.
 *
 * Examples:
 *
 *    Net::Proto.getprotobyname("tcp")   # => 6
 *    Net::Proto.getprotobyname("bogus") # => nil
*/
static VALUE np_getprotobyname(VALUE klass, VALUE rbProtoName){
   struct protoent* p;
   VALUE v_proto_num = Qnil;

   SafeStringValue(rbProtoName);
   p = getprotobyname(StringValuePtr(rbProtoName));
   
   if(p)
      v_proto_num = INT2FIX(p->p_proto);

   return v_proto_num;
}

/*
 * call-seq:
 *    Proto.getprotobynumber(num)
 *
 * Given a protocol number, returns the corresponding string, or nil if not
 * found.
 *
 * Examples:
 *
 *    Net::Proto.getprotobynumber(6)   # => "tcp"
 *    Net::Proto.getprotobynumber(999) # => nil
 */
static VALUE np_getprotobynumber(VALUE klass, VALUE v_proto_num)
{
   struct protoent* p;
   VALUE v_proto_name = Qnil;

   p = getprotobynumber(NUM2INT(v_proto_num));

   if(p)
      v_proto_name = rb_str_new2(p->p_name);

   return v_proto_name;
}

void Init_proto()
{
   VALUE mNet, cProto;
   
   /* The Net module serves only as a namespace */
   mNet = rb_define_module("Net");
   
   /* The Proto class encapsulates network protocol information */
   cProto = rb_define_class_under(mNet, "Proto", rb_cObject);

   /* Class Methods */
   rb_define_singleton_method(cProto,"getprotobyname",np_getprotobyname,1);
   rb_define_singleton_method(cProto,"getprotobynumber",np_getprotobynumber,1);

   /* There is no constructor */
   rb_funcall(cProto, rb_intern("private_class_method"), 1, ID2SYM(rb_intern("new")));

   /* 1.0.4: The version of this library. This is a string, not a number */
   rb_define_const(cProto, "VERSION", rb_str_new2(NET_PROTO_VERSION));
}

#ifdef __cplusplus
}
#endif
