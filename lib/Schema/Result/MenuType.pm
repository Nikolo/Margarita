use utf8;
package Schema::Result::MenuType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::MenuType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<menu_types>

=cut

__PACKAGE__->table("menu_types");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'menu_types_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "menu_types_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 128 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 menus

Type: has_many

Related object: L<Schema::Result::Menu>

=cut

__PACKAGE__->has_many(
  "menus",
  "Schema::Result::Menu",
  { "foreign.menu_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-16 15:14:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jrco3ArxdAfQ7xo4JHnOLg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
