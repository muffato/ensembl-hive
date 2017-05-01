=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2017] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut


package Bio::EnsEMBL::Hive::Scripts::LoadResourceUsage;

use strict;
use warnings;

use Bio::EnsEMBL::Hive::Valley;

sub add_connection_command_line_options { 1 };

sub command_line_options {
    return [
            'username=s'            => 'username',      # say "-user all" if the pipeline was run by several people
            'source_line=s'         => 'source_line',
            'meadow_type=s'         => ['meadow_type', ''],
    ];
}


sub run {
    my $self = shift;

    # FIXME: should be able to get the hive_dba without the pipeline
    my $queen = $self->param('pipeline')->hive_dba->get_Queen;
    my $meadow_2_pid_wid = $queen->fetch_HASHED_FROM_meadow_type_AND_meadow_name_AND_process_id_TO_worker_id();

    my $valley = Bio::EnsEMBL::Hive::Valley->new();

    if( my $source_line = $self->param('source_line') ) {

        my $meadow = $valley->available_meadow_hash->{$self->param('meadow_type')} || $valley->get_available_meadow_list()->[0];
        warn "Taking the resource_usage data from the source ( $source_line ), assuming Meadow ".$meadow->signature."\n";

        if(my $report_entries = $meadow->parse_report_source_line( $source_line ) ) {
            $queen->store_resource_usage( $report_entries, $meadow_2_pid_wid->{$meadow->type}{$meadow->cached_name} );
        }

    } else {
        warn "Searching for Workers without known resource_usage...\n";

        my $meadow_2_interval = $queen->interval_workers_with_unknown_usage();

        foreach my $meadow (@{ $valley->get_available_meadow_list() }) {

            warn "\nFinding out the time interval when the pipeline was run on Meadow ".$meadow->signature."\n";

            if(my $our_interval = $meadow_2_interval->{ $meadow->type }{ $meadow->cached_name } ) {
                if(my $report_entries = $meadow->get_report_entries_for_time_interval( $our_interval->{'min_born'}, $our_interval->{'max_died'}, $self->param('username') ) ) {
                    $queen->store_resource_usage( $report_entries, $meadow_2_pid_wid->{$meadow->type}{$meadow->cached_name} );
                }
            } else {
                warn "\tNothing new to store for Meadow ".$meadow->signature."\n";
            }
        }
    }

}


1;

__DATA__

=pod

=head1 NAME

    load_resource_usage.pl

=head1 DESCRIPTION

    This script obtains resource usage data for your pipeline from the Meadow and stores it in 'worker_resource_usage' table.
    Your Meadow class/plugin has to support offline examination of resources in order for this script to work.

    Based on the start time of the first Worker and end time of the last Worker (as recorded in pipeline DB),
    it pulls the relevant data out of your Meadow (runs 'bacct' script in case of LSF), parses the report and stores in 'worker_resource_usage' table.
    You can join this table to 'worker' table USING(meadow_name,process_id) in the usual MySQL way
    to filter by analysis_id, do various stats, etc.

    You can optionally provide an an external filename or command to get the data from it (don't forget to append a '|' to the end!)
    and then the data will be taken from your source and parsed from there.

=head1 USAGE EXAMPLES

        # Just run it the usual way: query and store the relevant data into 'worker_resource_usage' table:
    load_resource_usage.pl -url mysql://username:secret@hostname:port/long_mult_test

        # The same, but assuming another user 'someone_else' ran the pipeline:
    load_resource_usage.pl -url mysql://username:secret@hostname:port/long_mult_test -username someone_else

        # Assuming the dump file existed. Load the dumped bacct data into 'worker_resource_usage' table:
    load_resource_usage.pl -url mysql://username:secret@hostname:port/long_mult_test -source long_mult.bacct

        # Provide your own command to fetch and parse the worker_resource_usage data from:
    load_resource_usage.pl -url mysql://username:secret@hostname:port/long_mult_test -source "bacct -l -C 2012/01/25/13:33,2012/01/25/14:44 |" -meadow_type LSF

=head1 OPTIONS

    -help                   : print this help
    -url <url string>       : url defining where hive database is located
    -username <username>    : if it wasn't you who ran the pipeline, the name of that user can be provided
    -source <filename>      : alternative source of worker_resource_usage data. Can be a filename or a pipe-from command.
    -meadow_type <type>     : only used when -source is given. Tells which meadow type the source filename relates to. Defaults to the first available meadow (LOCAL being considered as the last available)

=head1 LICENSE

    Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
    Copyright [2016-2017] EMBL-European Bioinformatics Institute

    Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License
    is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

=head1 CONTACT

    Please subscribe to the Hive mailing list:  http://listserver.ebi.ac.uk/mailman/listinfo/ehive-users  to discuss Hive-related questions or to be notified of our updates

=cut

