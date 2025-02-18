=pod 

=head1 NAME

    Bio::EnsEMBL::Hive::Examples::LongMult::PipeConfig::SmartLongMult_conf;

=head1 SYNOPSIS

       # initialize the database and build the graph in it (it will also print the value of EHIVE_URL) :
    init_pipeline.pl Bio::EnsEMBL::Hive::Examples::LongMult::PipeConfig::LongMult_conf -password <mypass>

        # optionally also seed it with your specific values:
    seed_pipeline.pl -url $EHIVE_URL -logic_name take_b_apart -input_id '{ "a_multiplier" => "12345678", "b_multiplier" => "3359559666" }'

        # run the pipeline:
    beekeeper.pl -url $EHIVE_URL -loop

=head1 DESCRIPTION

    This is the PipeConfig file for the long multiplication pipeline example.
    The main point of this pipeline is to provide an example of how to write Hive Runnables and link them together into a pipeline.

    Please refer to Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf module to understand the interface implemented here.

    The setting. let's assume we are given two loooooong numbers to multiply. reeeeally long.
    soooo long that they do not fit into registers of the cpu and should be multiplied digit-by-digit.
    For the purposes of this example we also assume this task is very computationally intensive and has to be done in parallel.

    The long multiplication pipeline consists of four "analyses" (types of tasks):
        'redirect_trivial_jobs', 'take_b_apart', 'part_multiply' and 'add_together' that we use to examplify various features of the Hive.

        * A 'redirect_trivial_jobs' job takes in two string parameters, 'a_multiplier' and 'b_multiplier' and checks whether the second one is 0, or a power of 10
          If it is the case, the multiplication is easier to compute and we can flow the result directly to the 'final_result' table

        * A 'take_b_apart' job takes in two string parameters, 'a_multiplier' and 'b_multiplier',
          takes the second one apart into digits, finds what _different_ digits are there,
          creates several jobs of the 'part_multiply' analysis and one job of 'add_together' analysis.
          'take_b_apart' is used when 'redirect_trivial_jobs' could not recognize "trivial" patterns

        * A 'part_multiply' job takes in 'a_multiplier' and 'digit', multiplies them and accumulates the result in 'partial_product' accumulator.

        * An 'add_together' job waits for the first two analyses to complete,
          takes in 'a_multiplier', 'b_multiplier' and 'partial_product' hash and produces the final result in 'final_result' table.

    Please see the implementation details in Runnable modules themselves.

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

=cut


package Bio::EnsEMBL::Hive::Examples::LongMult::PipeConfig::SmartLongMult_conf;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf');  # All Hive databases configuration files should inherit from HiveGeneric, directly or indirectly
use Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf;           # Allow this particular config to use conditional dataflow and INPUT_PLUS


=head2 pipeline_create_commands

    Description : Implements pipeline_create_commands() interface method of Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf that lists the commands that will create and set up the Hive database.
                  In addition to the standard creation of the database and populating it with Hive tables and procedures it also creates two pipeline-specific tables used by Runnables to communicate.

=cut

sub pipeline_create_commands {
    my ($self) = @_;
    return [
        @{$self->SUPER::pipeline_create_commands},  # inheriting database and hive tables' creation

            # additional tables needed for long multiplication pipeline's operation:
        $self->db_cmd('CREATE TABLE final_result (a_multiplier varchar(255) NOT NULL, b_multiplier varchar(255) NOT NULL, result varchar(255) NOT NULL, PRIMARY KEY (a_multiplier, b_multiplier))'),
    ];
}


=head2 pipeline_wide_parameters

    Description : Interface method that should return a hash of pipeline_wide_parameter_name->pipeline_wide_parameter_value pairs.
                  The value doesn't have to be a scalar, can be any Perl structure now (will be stringified and de-stringified automagically).
                  Please see existing PipeConfig modules for examples.

=cut

sub pipeline_wide_parameters {
    my ($self) = @_;
    return {
        %{$self->SUPER::pipeline_wide_parameters},          # here we inherit anything from the base class

        'take_time'     => 1,
    };
}


=head2 pipeline_analyses

    Description : Implements pipeline_analyses() interface method of Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf that defines the structure of the pipeline: analyses, jobs, rules, etc.
                  Here it defines three analyses:
                    * 'redirect_trivial_jobs' that is auto-seeded with a pair of jobs (to check the commutativity of multiplication).
                      Each job will check whether the multiplication can be done quickly (multiplication by 0 or a power of 10) and flow the result to the final_result table
                      Otherwise, it passes on to 'take_b_apart'

                    * 'take_b_apart' with jobs fed from redirect_trivial_jobs#1
                      Each job will dataflow (create more jobs) via branch #2 into 'part_multiply' and via branch #1 into 'add_together'.

                    * 'part_multiply' with jobs fed from take_b_apart#2.
                        It multiplies input parameters 'a_multiplier' and 'digit' and dataflows 'partial_product' parameter into branch #1.

                    * 'add_together' with jobs fed from take_b_apart#1.
                        It adds together results of partial multiplication computed by 'part_multiply'.
                        These results are accumulated in 'partial_product' hash.
                        Until the hash is complete the corresponding 'add_together' job is blocked by a semaphore.

=cut

sub pipeline_analyses {
    my ($self) = @_;
    return [
        {   -logic_name => 'redirect_trivial_jobs',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::Dummy',
            -meadow_type=> 'LOCAL',     # do not bother the farm with such a simple task (and get it done faster)
            -analysis_capacity  =>  2,  # use per-analysis limiter
            -input_ids => [
                { 'a_multiplier' => '9650156169', 'b_multiplier' => '327358788' },
                { 'a_multiplier' => '327358788', 'b_multiplier' => '9650156169' },
            ],
            -flow_into => {
                    # Identify "easy" multiplications and flow their results directly to the table
                    # We use WHEN to detect the cases, and INPUT_PLUS to make parent job's parameters available to the kids
                1 => WHEN(
                        '#b_multiplier# =~ /^0+$/'  => { '?table_name=final_result' => INPUT_PLUS( { 'result' => '0' } ) },
                        '#b_multiplier# =~ /^10*$/' => { '?table_name=final_result' => INPUT_PLUS( { 'result' => '#a_multiplier##expr("0" x (length(#b_multiplier#)-1))expr#' } ) },
                        ELSE 'take_b_apart',
                    ),
            },
        },

        {   -logic_name => 'take_b_apart',
            -module     => 'Bio::EnsEMBL::Hive::Examples::LongMult::RunnableDB::DigitFactory',
            -meadow_type=> 'LOCAL',     # do not bother the farm with such a simple task (and get it done faster)
            -analysis_capacity  =>  2,  # use per-analysis limiter
            -flow_into => {
                    # creating a semaphored fan of jobs; filtering by WHEN; using INPUT_PLUS or templates to top-up the hashes.
                    #
                    # A WHEN block is not a hash, so multiple occurences of each condition (including ELSE) is permitted.
                '2->A' => WHEN(
                                '#digit#>1' => { 'part_multiply' => INPUT_PLUS() },     # make parent job's parameters available to the kids
#                                ELSE           { 'part_multiply' => { 'a_multiplier' => '#a_multiplier#', 'digit' => '#digit#' } },
                          ),
                    # creating a semaphored funnel job to wait for the fan to complete and add the results:
                'A->1' => [ 'add_together'  ],
            },
        },

        {   -logic_name => 'part_multiply',
            -module     => 'Bio::EnsEMBL::Hive::Examples::LongMult::RunnableDB::PartMultiply',
            -analysis_capacity  =>  4,  # use per-analysis limiter
            -flow_into => {
                1 => [ '?accu_name=partial_product&accu_address={digit}&accu_input_variable=product' ],
            },
        },
        
        {   -logic_name => 'add_together',
            -module     => 'Bio::EnsEMBL::Hive::Examples::LongMult::RunnableDB::AddTogether',
            -flow_into => {
                1 => [ '?table_name=final_result' ],
            },
        },
    ];
}

1;

