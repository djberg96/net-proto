/*******************************************************
 * proto.c (linux.c)
 *******************************************************/
#include <ruby.h>
#include <version.h>
#include <netdb.h>
#include <string.h>

#ifdef __cplusplus
extern "C"
{
#endif

#define BUF_SIZE 8192

VALUE sProto;

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
static VALUE np_getprotobyname(VALUE klass, VALUE v_proto_name){
   struct protoent* p;
   char buffer[BUF_SIZE];
   VALUE v_proto_num = Qnil;

   SafeStringValue(v_proto_name);

   p = malloc(sizeof(struct protoent));

   setprotoent(0);
   getprotobyname_r(StringValuePtr(v_proto_name), p, buffer, BUF_SIZE, &p);

   if(p){
      v_proto_num = INT2FIX(p->p_proto);
      free(p);
   }

   endprotoent();
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
static VALUE np_getprotobynumber(VALUE klass, VALUE v_proto_num){
   struct protoent* p;
   char buffer[BUF_SIZE];
   char* proto_name;
   VALUE v_proto_name = Qnil;

   p = malloc(sizeof(struct protoent));

   setprotoent(0);
   getprotobynumber_r(NUM2INT(v_proto_num), p, buffer, BUF_SIZE, &p);

   if(p){
      v_proto_name = rb_str_new2(proto_name = p->p_name);
      free(p);
   }

   endprotoent();
   return v_proto_name;
}

/*
 * call-seq:
 *    Proto.getprotoent
 *    Proto.getprotoent{ |struct| ... }
 *
 * In block form, yields each entry from /etc/protocols as a struct of type
 * Proto::ProtoStruct.  In non-block form, returns an array of
 * Proto::ProtoStruct objects.

 * The fields are 'name' (a String), 'aliases' (an Array of String's,
 * though often only one element), and 'proto' (a Fixnum).
 *
 * Example:
 *
 *   Net::Proto.getprotoent.each{ |prot|
 *      p prot.name
 *      p prot.aliases
 *      p prot.proto
 *   }
*/
static VALUE np_getprotoent(VALUE klass){
   struct protoent* p;
   struct protoent* q;
   char buffer[BUF_SIZE];
   VALUE v_alias_array = Qnil;
   VALUE v_array = Qnil;
   VALUE v_struct = Qnil;

   p = malloc(sizeof(struct protoent));
   q = malloc(sizeof(struct protoent));

   if(!rb_block_given_p())
      v_array = rb_ary_new();

   setprotoent(0);

   while(!getprotoent_r(p, buffer, BUF_SIZE, &q)){
      v_alias_array = rb_ary_new();

      while((*p->p_aliases)){
         rb_ary_push(v_alias_array, rb_str_new2(*p->p_aliases));
         (void)*p->p_aliases++;
      }

      v_struct = rb_struct_new(sProto,
         rb_str_new2(p->p_name),
         v_alias_array,
         INT2FIX(p->p_proto)
      );

      OBJ_FREEZE(v_struct); /* This is read-only data */

      if(rb_block_given_p())
         rb_yield(v_struct);
      else
         rb_ary_push(v_array, v_struct);
   }

   free(p);
   free(q);

   endprotoent();

   return v_array; /* nil if a block was given */
}

void Init_proto(){
   VALUE mNet, cProto;

   /* The Net module serves as a namespace only */
   mNet = rb_define_module("Net");

   /* The Proto class encapsulates network protocol information */
   cProto = rb_define_class_under(mNet, "Proto", rb_cObject);

   /* Structure definitions */
   sProto = rb_struct_define("ProtoStruct", "name", "aliases", "proto", 0);

   /* There is no constructor */
   rb_funcall(cProto, rb_intern("private_class_method"), 1, ID2SYM(rb_intern("new")));

   /* Class methods */
   rb_define_singleton_method(cProto, "getprotobyname", np_getprotobyname, 1);
   rb_define_singleton_method(cProto, "getprotobynumber", np_getprotobynumber, 1);
   rb_define_singleton_method(cProto, "getprotoent", np_getprotoent, 0);

   /* 1.0.4: The version of this library. This is a string, not a number */
   rb_define_const(cProto, "VERSION", rb_str_new2(NET_PROTO_VERSION));
}

#ifdef __cplusplus
}
#endif
