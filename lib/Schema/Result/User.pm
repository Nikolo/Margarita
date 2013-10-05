use utf8;
package Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'users_id_seq'

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 country

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 city

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 comment

  data_type: 'text'
  is_nullable: 1

=head2 activationid

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 sex

  data_type: 'enum'
  extra: {custom_type_name => "usex",list => ["m","f"]}
  is_nullable: 1

=head2 code

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 birth_date

  data_type: 'date'
  is_nullable: 1

=head2 last_visit

  data_type: 'date'
  is_nullable: 1

=head2 not_receive_mailer

  data_type: 'boolean'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "users_id_seq",
  },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "country",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "city",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "comment",
  { data_type => "text", is_nullable => 1 },
  "activationid",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "sex",
  {
    data_type => "enum",
    extra => { custom_type_name => "usex", list => ["m", "f"] },
    is_nullable => 1,
  },
  "code",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "birth_date",
  { data_type => "date", is_nullable => 1 },
  "last_visit",
  { data_type => "date", is_nullable => 1 },
  "not_receive_mailer",
  { data_type => "boolean", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<users_email_key>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("users_email_key", ["email"]);

=head1 RELATIONS

=head2 articles

Type: has_many

Related object: L<Schema::Result::Article>

=cut

__PACKAGE__->has_many(
  "articles",
  "Schema::Result::Article",
  { "foreign.author" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: has_many

Related object: L<Schema::Result::Role>

=cut

__PACKAGE__->has_many(
  "roles",
  "Schema::Result::Role",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-05-30 23:51:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AO+c83ZK+Ry67WvSaEq60A

__PACKAGE__->many_to_many(
   "grps" => "roles",
   "grp"
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
