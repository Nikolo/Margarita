use utf8;
package Schema::Result::Acl;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Acl

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<acls>

=cut

__PACKAGE__->table("acls");

=head1 ACCESSORS

=head2 grp_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 page_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "grp_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "page_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 RELATIONS

=head2 grp

Type: belongs_to

Related object: L<Schema::Result::Grp>

=cut

__PACKAGE__->belongs_to(
  "grp",
  "Schema::Result::Grp",
  { id => "grp_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-10-16 00:16:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kOlOGct2S1gGf66Uvyz9FA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
