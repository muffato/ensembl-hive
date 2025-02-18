#!/usr/bin/env perl

use strict;
use warnings;

    # Finding out own path in order to reference own components (including own modules):
use Cwd            ();
use File::Basename ();
BEGIN {
    $ENV{'EHIVE_ROOT_DIR'} ||= File::Basename::dirname( File::Basename::dirname( Cwd::realpath($0) ) );
    unshift @INC, $ENV{'EHIVE_ROOT_DIR'}.'/modules';
}

use Getopt::Long qw(:config no_auto_abbrev);
use Pod::Usage;

use Bio::EnsEMBL::Hive::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Hive::DBSQL::AnalysisJobAdaptor;
use Bio::EnsEMBL::Hive::Utils::URL;

Bio::EnsEMBL::Hive::Utils::URL::hide_url_password();

sub main {
    my ($url, $reg_conf, $reg_type, $reg_alias, $nosqlvc, $before_datetime, $days_ago, $help);

    GetOptions(
                # connect to the database:
            'url=s'                       => \$url,
            'reg_conf|regfile|reg_file=s' => \$reg_conf,
            'reg_type=s'                  => \$reg_type,
            'reg_alias|regname|regname=s' => \$reg_alias,
            'nosqlvc'                   => \$nosqlvc,      # using "nosqlvc" instead of "sqlvc!" for consistency with scripts where it is a propagated option

                # specify the threshold datetime:
            'before_datetime=s'     => \$before_datetime,
            'days_ago=f'            => \$days_ago,

               # other commands/options     
	    'h|help!'               => \$help,  
    ) or die "Error in command line arguments\n";

    if (@ARGV) {
        die "ERROR: There are invalid arguments on the command-line: ". join(" ", @ARGV). "\n";
    }

    if ($help) {
        pod2usage({-exitvalue => 0, -verbose => 2});
    }

    my $hive_dba;
    if($url or $reg_alias) {
        $hive_dba = Bio::EnsEMBL::Hive::DBSQL::DBAdaptor->new(
                -url                            => $url,
                -reg_conf                       => $reg_conf,
                -reg_type                       => $reg_type,
                -reg_alias                      => $reg_alias,
                -no_sql_schema_version_check    => $nosqlvc,
        );
        $hive_dba->dbc->requires_write_access();
    } else {
        die "\nERROR: Connection parameters (url or reg_conf+reg_alias) need to be specified\n";
    }

    my $threshold_datetime_expression;

    if($before_datetime) {
        $threshold_datetime_expression = "'$before_datetime'";
    } else {
        unless($before_datetime or $days_ago) {
            warn "Neither -before_datetime or -days_ago was defined, assuming '-days_ago 7'\n";
            $days_ago = 7;
        }
        $threshold_datetime_expression = "from_unixtime(unix_timestamp(now())-3600*24*$days_ago)";
    }

    my $sql = qq{
    DELETE j FROM job j
     WHERE j.status='DONE'
       AND j.when_completed < $threshold_datetime_expression
    };

    my $dbc = $hive_dba->dbc();
    $dbc->do( $sql );

    # Remove the roles that are not attached to any jobs
    my $sql_roles = q{
    DELETE role
      FROM role LEFT JOIN job USING (role_id)
     WHERE job.job_id IS NULL
    };
    $dbc->do( $sql_roles );

    # Remove the workers that are not attached to any roles, but only the
    # ones that should actually have a role (e.g. have been deleted by the
    # above statement).
    my $sql_workers = q{
    DELETE worker
      FROM worker LEFT JOIN role USING (worker_id)
     WHERE role.role_id IS NULL AND work_done > 0
    };
    $dbc->do( $sql_workers );

    ## Remove old messages not attached to any jobs
    my $sql_log_message = qq{
    DELETE FROM log_message WHERE job_id IS NULL AND time < $threshold_datetime_expression
    };
    $dbc->do( $sql_log_message );

    ## Remove old analysis_stats
    my $sql_analysis_stats = qq{
    DELETE FROM analysis_stats_monitor WHERE time < $threshold_datetime_expression
    };
    $dbc->do( $sql_analysis_stats );
}

main();

__DATA__

=pod

=head1 NAME

hoover_pipeline.pl

=head1 SYNOPSIS

    hoover_pipeline.pl {-url <url> | -reg_conf <reg_conf> -reg_alias <reg_alias>} [ { -before_datetime <datetime> | -days_ago <days_ago> } ]

=head1 DESCRIPTION

hoover_pipeline.pl is a script used to remove old "DONE" Jobs from a continuously running pipeline database

=head1 USAGE EXAMPLES

        # delete all Jobs that have been "DONE" for at least a week (default threshold) :

    hoover_pipeline.pl -url "mysql://ensadmin:${ENSADMIN_PSW}@localhost:3306/lg4_long_mult"


        # delete all Jobs that have been "DONE" for at least a given number of days

    hoover_pipeline.pl -url "mysql://ensadmin:${ENSADMIN_PSW}@localhost:3306/lg4_long_mult" -days_ago 3


        # delete all Jobs "DONE" before a specific datetime:

    hoover_pipeline.pl -url "mysql://ensadmin:${ENSADMIN_PSW}@localhost:3306/lg4_long_mult" -before_datetime "2013-02-14 15:42:50"

=head1 OPTIONS

=over

=item --reg_conf <path>

path to a Registry configuration file

=item --reg_type <string>

type of the registry entry ("hive", "core", "compara", etc - defaults to "hive")

=item --reg_alias <string>

species/alias name for the eHive DBAdaptor

=item --url <url string>

URL defining where eHive database is located

=item --nosqlvc

"No SQL Version Check" - set if you want to force working with a database created by a potentially schema-incompatible API

=item --before_datetime <string>

delete Jobs "DONE" before a specific time

=item --days_ago <num>

delete Jobs that have been "DONE" for at least <num> days

=item -h, --help

show this help message

=back

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

Please subscribe to the eHive mailing list:  http://listserver.ebi.ac.uk/mailman/listinfo/ehive-users  to discuss eHive-related questions or to be notified of our updates

=cut

