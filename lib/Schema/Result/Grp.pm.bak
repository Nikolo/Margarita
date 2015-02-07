use utf8;
package Schema::Result::Grp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Grp

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

=head1 TABLE: C<grps>

=cut

__PACKAGE__->table("grps");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'grps_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "grps_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 acls

Type: has_many

Related object: L<Schema::Result::Acl>

=cut

__PACKAGE__->has_many(
  "acls",
  "Schema::Result::Acl",
  { "foreign.grp_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: has_many

Related object: L<Schema::Result::Role>

=cut

__PACKAGE__->has_many(
  "roles",
  "Schema::Result::Role",
  { "foreign.grp_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-05-30 23:51:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pD5zlpC83+UxTC6WtmaRTw


__PACKAGE__->many_to_many(
   "pages" => "acls",
   "page"
);

__PACKAGE__->many_to_many(
   "users" => "roles",
   "user"
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
