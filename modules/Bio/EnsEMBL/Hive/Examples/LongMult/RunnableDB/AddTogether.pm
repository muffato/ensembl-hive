=pod 

=head1 NAME

    Bio::EnsEMBL::Hive::Examples::LongMult::RunnableDB::AddTogether

=head1 SYNOPSIS

    Please refer to Bio::EnsEMBL::Hive::Examples::LongMult::PipeConfig::LongMult_conf pipeline configuration file
    to understand how this particular example pipeline is configured and ran.

=head1 DESCRIPTION

    'Bio::EnsEMBL::Hive::Examples::LongMult::RunnableDB::AddTogether' is the final step of the pipeline that, naturally,
    adds the products together and dataflows the result (which gets normally stored in 'final_result' table).

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


package Bio::EnsEMBL::Hive::Examples::LongMult::RunnableDB::AddTogether;

use strict;
use warnings;

use Bio::EnsEMBL::Hive::TheApiary;

use base ('Bio::EnsEMBL::Hive::Process');


=head2 param_defaults

    Description : Implements param_defaults() interface method of Bio::EnsEMBL::Hive::Process that defines module defaults for parameters.

=cut

sub param_defaults {

    return {
        'intermediate_table_url'    => undef,                       # if defined, take data from there rather than from accu
        'final_table_url'           => '?table_name=final_result',  # used by post_healthcheck() to fetch the final result from
        'partial_product'           => { },                         # to be used when b_multiplier only contains digits '0' and '1'
        'take_time'                 => 0,                           # how much time run() method will spend in sleeping state
    };
}


=head2 fetch_input

    Description : Implements fetch_input() interface method of Bio::EnsEMBL::Hive::Process that is used to read in parameters and load data.
                  Here all relevant partial products are fetched from the 'partial_product' accumulator and stored in a hash for future use.

    param('a_multiplier'):  The first long number (a string of digits - doesn't have to fit a register).

    param('b_multiplier'):  The second long number (also a string of digits).

    param('take_time'):     How much time to spend sleeping (seconds).

=cut

sub fetch_input {   # fetch all the (relevant) precomputed products
    my $self = shift @_;

    my $a_multiplier            = $self->param_required('a_multiplier');
    my $intermediate_table_url  = $self->param('intermediate_table_url');
    my $partial_product;

    if($intermediate_table_url) {      # special compatibility mode, where data is fetched from a given table
        my $intermediate_table = Bio::EnsEMBL::Hive::TheApiary->find_by_url( $intermediate_table_url, $self->input_job->hive_pipeline );
        $partial_product = $self->param('partial_product', $intermediate_table->adaptor->fetch_by_a_multiplier_HASHED_FROM_digit_TO_partial_product( $a_multiplier ) );
    } else {
        $partial_product = $self->param('partial_product');
    }

    $partial_product->{1} = $a_multiplier;
    $partial_product->{0} = 0;
}

=head2 run

    Description : Implements run() interface method of Bio::EnsEMBL::Hive::Process that is used to perform the main bulk of the job (minus input and output).
                  The only thing we do here is make a call to the function that will add together the intermediate results.

=cut

sub run {   # call the function that will compute the stuff
    my $self = shift @_;

    my $a_multiplier    = $self->param_required('a_multiplier');
    my $b_multiplier    = $self->param_required('b_multiplier');
    my $partial_product = $self->param('partial_product');

    $self->param('result', _add_together($a_multiplier, $b_multiplier, $partial_product));

    sleep( $self->param('take_time') );
}


=head2 write_output

    Description : Implements write_output() interface method of Bio::EnsEMBL::Hive::Process that is used to deal with job's output after the execution.
                  Dataflows both original multipliers and the final result down branch-1, which will be routed into 'final_result' table.

=cut

sub write_output {  # store and dataflow
    my $self = shift @_;

    $self->dataflow_output_id({
        'result'       => $self->param('result'),
    }, 1);
}


=head2 post_healthcheck

    Description : Implements post_healthcheck() interface method of Bio::EnsEMBL::Hive::Process that is used to healthcheck the result of the job's execution.
                  Here it assumes that the location of the final result has been given through the 'final_table_url' parameter (it can be a partial URL).
                  If the destination of the data changes, make sure you either set this URL correctly or undefine it (in which case the healthcheck will not be run).

=cut

sub post_healthcheck {
    my $self = shift @_;

    my $a_multiplier    = $self->param_required('a_multiplier');
    my $b_multiplier    = $self->param_required('b_multiplier');
    my $final_result;
    my $location_desc;

    if( my $final_table_url = $self->param('final_table_url') ) {

        my $final_table     = Bio::EnsEMBL::Hive::TheApiary->find_by_url( $final_table_url, $self->input_job->hive_pipeline );
           $final_result    = $final_table->adaptor->fetch_by_a_multiplier_AND_b_multiplier_TO_result( $a_multiplier, $b_multiplier);
           $location_desc   = "stored in '$final_table_url' table";
    } else {
           $final_result    = $self->param('result');
           $location_desc   = "not stored";
    }

    my $correct_or_not  = ($a_multiplier * $b_multiplier == $final_result) ? 'CORRECT' : 'INCORRECT';

    $self->warning("The result ($location_desc) for ${a_multiplier} x ${b_multiplier} is $final_result, this result is $correct_or_not");
}


=head2 _add_together

    Description: this is a private function (not a method) that adds all the products with a shift

=cut

sub _add_together {
    my ($a_multiplier, $b_multiplier, $partial_product) = @_;

    my @accu  = ();

    my @b_digits = reverse split(//, $b_multiplier);
    foreach my $b_index (0..(@b_digits-1)) {
        my $b_digit = $b_digits[$b_index];
        my $product = $partial_product->{$b_digit};

        die "The partial product of $a_multiplier x $b_digit has not arrived at AddTogether stage - please check your wiring!" unless(defined($product));

        my @p_digits = reverse split(//, $product);
        foreach my $p_index (0..(@p_digits-1)) {
            $accu[$b_index+$p_index] += $p_digits[$p_index];
        }
    }

    foreach my $a_index (0..(@accu-1)) {
        my $a_digit       = $accu[$a_index];
        my $carry         = int($a_digit/10);
        $accu[$a_index]   = $a_digit % 10;
        $accu[$a_index+1] += $carry;
    }

        # get rid of the leading zero
    unless($accu[@accu-1]) {
        pop @accu;
    }

    return join('', reverse @accu);
}

1;

