{
I""schema_info":ET[[:version{:oidi:db_typeI"integer:encoding"ISO-8859-1:defaultI"0;	@:allow_nullF:primary_keyF:	type:integer:ruby_defaulti I""users"; T[[:id{;i;I"integer;	@;
I"&nextval('users_id_seq'::regclass);	@;F;T;;;0[:
email{;i;I"	text;	@;
0;F;F;:string;0[:	name{;i;I"	text;	@;
0;F;F;;;0I""applications"; T[[;{;i;I"integer;	@;
I"-nextval('applications_id_seq'::regclass);	@;F;T;;;0[;{;i;I"	text;	@;
0;F;F;;;0[:url{;i;I"	text;	@;
0;F;F;;;0I""permissions"; T[[;{;i;I"integer;	@;
I",nextval('permissions_id_seq'::regclass);	@;F;T;;;0[;{;i;I"	text;	@;
0;F;F;;;0[:description{;i;I"	text;	@;
0;F;F;;;0I""user_permissions"; T[[:user_id{;i;I"integer;	@;
0;F;F;;;0[:application_id{;i;I"integer;	@;
0;F;F;;;0[:permission_id{;i;I"integer;	@;
0;F;F;;;0