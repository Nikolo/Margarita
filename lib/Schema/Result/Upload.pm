use utf8;
package Schema::Result::Upload;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Upload

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

=head1 TABLE: C<upload>

=cut

__PACKAGE__->table("upload");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'upload_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 owner_id

  data_type: 'integer'
  is_nullable: 0

=head2 date

  data_type: 'date'
  is_nullable: 1

=head2 file_media_type

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 obj_name

  data_type: 'enum'
  extra: {custom_type_name => "uploadtype",list => ["menu"]}
  is_nullable: 1

=head2 obj_id

  data_type: 'integer'
  is_nullable: 0

=head2 tmpl_keyword

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 tags

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "upload_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "owner_id",
  { data_type => "integer", is_nullable => 0 },
  "date",
  { data_type => "date", is_nullable => 1 },
  "file_media_type",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "obj_name",
  {
    data_type => "enum",
    extra => { custom_type_name => "uploadtype", list => ["menu"] },
    is_nullable => 1,
  },
  "obj_id",
  { data_type => "integer", is_nullable => 0 },
  "tmpl_keyword",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "tags",
  { data_type => "varchar", is_nullable => 1, size => 512 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-04-13 23:03:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0gShIDCU841hzGkRYBQSkw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
