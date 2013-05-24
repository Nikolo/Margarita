use utf8;
package Schema::Result::Menu;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Menu

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

=head1 TABLE: C<menu>

=cut

__PACKAGE__->table("menu");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'menu_id_seq'

=head2 menu_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 page_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 position

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "menu_id_seq",
  },
  "menu_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "page_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "position",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 menu_type

Type: belongs_to

Related object: L<Schema::Result::MenuType>

=cut

__PACKAGE__->belongs_to(
  "menu_type",
  "Schema::Result::MenuType",
  { id => "menu_type_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 page

Type: belongs_to

Related object: L<Schema::Result::Page>

=cut

__PACKAGE__->belongs_to(
  "page",
  "Schema::Result::Page",
  { id => "page_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-04-13 23:03:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CVUpDFBkd4SacQzeqFAzWg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
