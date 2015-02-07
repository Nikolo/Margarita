use utf8;
package Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Tag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tags>

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'tags_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "tags_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<tags_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("tags_name_key", ["name"]);

=head1 RELATIONS

=head2 foto_tags

Type: has_many

Related object: L<Schema::Result::FotoTag>

=cut

__PACKAGE__->has_many(
  "foto_tags",
  "Schema::Result::FotoTag",
  { "foreign.id_tag" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-10-16 00:16:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NCzuGMSNRIl/a0xDNl0Z1Q

__PACKAGE__->many_to_many(
  "articles" => "article_tags",
  "id_article"
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
