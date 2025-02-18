=pod

=head1 NAME

    Bio::EnsEMBL::Hive::DBSQL::AnalysisDataAdaptor

=head1 SYNOPSIS

    $dataDBA = $db_adaptor->get_AnalysisDataAdaptor;

=head1 DESCRIPTION

   analysis_data table holds LONGTEXT data that is currently used as an extension of some fixed-width fields of 'job' table.
   It is no longer general-purpose. Please avoid accessing this table directly or via the adaptor.

=head1 LICENSE

    Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
    Copyright [2016-2022] EMBL-European Bioinformatics Institute

    Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License
    is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

=head1 CONTACT

    Please subscribe to the Hive mailing list:  http://listserver.ebi.ac.uk/mailman/listinfo/ehive-users  to discuss Hive-related questions or to be notified of our updates

=head1 APPENDIX

    The rest of the documentation details each of the object methods.
    Internal methods are preceded with a _

=cut


package Bio::EnsEMBL::Hive::DBSQL::AnalysisDataAdaptor;

use strict;
use warnings;

use Digest::MD5 qw(md5_hex);

use base ('Bio::EnsEMBL::Hive::DBSQL::NakedTableAdaptor');


sub default_table_name {
    return 'analysis_data';
}

=head2 fetch_by_data_to_analysis_data_id

  Arg [1]    : String $input_id
  Example    : $ext_data_id = $analysis_data_adaptor->fetch_by_data_to_analysis_data_id( $input_id );
  Description: Attempts to find an entry in the analysis_data table by its content (data + MD5 checksum)
  Returntype : Integer (dbID of the analysis_data table)

=cut

sub fetch_by_data_to_analysis_data_id {     # It is a special case not covered by AUTOLOAD; note the lowercase _to_
    my ($self, $input_id) = @_;

    my $md5sum = md5_hex($input_id);
    return $self->fetch_by_data_AND_md5sum_TO_analysis_data_id($input_id, $md5sum);
}


sub store_if_needed {
    my ($self, $data) = @_;

    my $storable_hash = {'data' => $data, 'md5sum' => md5_hex($data)};

    $self->store( $storable_hash );

    # We now need to check for collisions ourselves since there is no
    # UNIQUE KEY in the table definition.
    # This is very similar to check_object_present_in_db_by_content()
    # but it returns the *first* analysis_data_id that's been stored
    my $sql = 'SELECT MIN(analysis_data_id) FROM analysis_data WHERE md5sum = ? AND data = ?';
    my $sth = $self->prepare( $sql );
    $sth->execute( $storable_hash->{md5sum}, $data );
    my ($first_dbID) = $sth->fetchrow_array();
    $sth->finish;
    if ($first_dbID != $storable_hash->{analysis_data_id}) {
        # Our row duplicates a previous one, so we need to clean up
        $self->remove($storable_hash);
    }
    return '_extended_data_id ' . $first_dbID;
}

1;
