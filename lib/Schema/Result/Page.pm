use utf8;
package Schema::Result::Page;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Page

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

=head1 TABLE: C<pages>

=cut

__PACKAGE__->table("pages");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'pages_id_seq'

=head2 action

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 controller

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 menu_name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "pages_id_seq",
  },
  "action",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "controller",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "menu_name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 250 },
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
  { "foreign.page_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-03-03 22:24:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GL2eAFG/ITjSBYtzW1Cw3g

__PACKAGE__->many_to_many(
   "grps" => "acls",
   "grp"
);


# You can replace this text with custom content, and it will be preserved on regeneration
1;
