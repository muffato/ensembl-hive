=pod

=head1 NAME

    Bio::EnsEMBL::Hive::DataflowRule

=head1 DESCRIPTION

    A data container object (methods are intelligent getters/setters) that corresponds to a row stored in 'dataflow_rule' table

    A dataflow rule is activated when a Bio::EnsEMBL::Hive::AnalysisJob::dataflow_output_id is called at any moment during a RunnableDB's execution.
    The current RunnableDB's analysis ($from_analysis) and the requested $branch_code (1 by default) define the entry conditions,
    and whatever rules match these conditions will generate new jobs with input_ids specified in the dataflow_output_id() call.
    If input_id_template happens to contain a non-NULL value, it will be used to generate the corresponding intput_id instead.

    Jessica's remark on the structure of to_analysis_url:
        Extended from design of SimpleRule concept to allow the 'to' analysis to be specified with a network savy URL like
        mysql://ensadmin:<pass>@ecs2:3361/compara_hive_test/analysis?logic_name='blast_NCBI34'

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


package Bio::EnsEMBL::Hive::DataflowRule;

use strict;
use warnings;

use Bio::EnsEMBL::Hive::TheApiary;
use Bio::EnsEMBL::Hive::DBSQL::DataflowRuleAdaptor;

use base ( 'Bio::EnsEMBL::Hive::Storable' );


sub unikey {
    return [ 'from_analysis', 'branch_code', 'funnel_dataflow_rule', 'unitargets' ];
} 


=head1 AUTOLOADED

    from_analysis_id / from_analysis

    funnel_dataflow_rule_id / funnel_dataflow_rule

=cut


=head2 branch_code

    Function: getter/setter method for the branch_code of the dataflow rule

=cut

sub branch_code {
    my $self = shift @_;

    if(@_) {
        my $branch_name_or_code = shift @_;
        $self->{'_branch_code'} = $branch_name_or_code && Bio::EnsEMBL::Hive::DBSQL::DataflowRuleAdaptor::branch_name_2_code( $branch_name_or_code );
    }
    return $self->{'_branch_code'};
}


sub get_my_targets {
    my $self = shift @_;

    return $self->hive_pipeline->collection_of( 'DataflowTarget' )->find_all_by('source_dataflow_rule', $self);
}


sub get_my_targets_grouped_by_condition {
    my $self        = shift @_;
    my $df_targets  = shift @_;

    $df_targets //= $self->get_my_targets;

    my %my_targets_by_condition = ();
    foreach my $df_target (@$df_targets) {
        my $this_pair = $my_targets_by_condition{ $df_target->on_condition // ''} ||= [ $df_target->on_condition, []];
        push @{$this_pair->[1]}, $df_target;
    }

    return [ sort { ($b->[0]//'') cmp ($a->[0]//'') } values %my_targets_by_condition ];
}


sub _compute_unitargets {
    my $targets = shift;
    return join( ';', map { ($_->on_condition//'').':'.($_->input_id_template//'').':'.$_->to_analysis_url }
                                        sort { ($a->on_condition//'') cmp ($b->on_condition//'')
                                            or ($a->input_id_template//'') cmp ($b->input_id_template//'') }
                                            @$targets);
}

# NOTE: By caching the "unitargets" value, we assume that the list of
# targets will *not* change once the object is loaded. This holds true at
# the moment, but we need to be careful it remains the case in the future,
# otherwise the bits that change the targets would have to invalidate the
# cached value
sub unitargets {
    my $self    = shift @_;

    if (@_) {
        $self->{'_cached_unitargets'} = shift @_;
    }

    unless ($self->{'_cached_unitargets'}) {
        my $targets = $self->get_my_targets;
        $self->{'_cached_unitargets'} = _compute_unitargets( $targets );
    }

    return $self->{'_cached_unitargets'};
}


=head2 toString

    Args       : (none)
    Example    : print $df_rule->toString()."\n";
    Description: returns a stringified representation of the rule
    Returntype : string

=cut

sub toString {
    my $self    = shift @_;
    my $short   = shift @_;

    return join('',
            $short ? () : (
                'DataflowRule[',
                ($self->dbID // ''),
                ']: ',
                $self->from_analysis->logic_name,
            ),
            ' --#',
            $self->branch_code,
            '--> [ ',
            join(', ', map { $_->toString($short) } sort { ($b->on_condition // '') cmp ($a->on_condition // '') } (@{$self->get_my_targets()})),
            ' ]',
            ($self->funnel_dataflow_rule ? ' ---|| ('.$self->funnel_dataflow_rule->toString(1).' )'  : ''),
    );
}

1;

