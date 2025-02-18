=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2022] EMBL-European Bioinformatics Institute

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

=pod

=head1 NAME

Bio::EnsEMBL::Hive::Utils::Collection - A collection object

=cut

package Bio::EnsEMBL::Hive::Utils::Collection;

use strict;
use warnings;

sub new {
    my $class = shift @_;

    my $self = bless {}, $class;

    $self->listref( shift @_ || [] );

    return $self;
}


sub listref {
    my $self = shift @_;

    if(@_) {
        $self->{'_listref'} = shift @_;
    }
    return $self->{'_listref'};
}


sub list {
    my $self = shift @_;

    return @{ $self->listref };
}


sub present {
    my $self        = shift @_;
    my $candidate   = shift @_;

    foreach my $element (@{ $self->listref }) {
        return 1 if($element eq $candidate);
    }
    return 0;
}


sub add {
    my $self = shift @_;

    push @{ $self->listref }, @_;
}


sub add_once {
    my $self        = shift @_;
    my $candidate   = shift @_;

    unless( $self->present( $candidate ) ) {
        $self->add( $candidate );
    }
}


sub forget {
    my $self        = shift @_;
    my $candidate   = shift @_;

    my $listref = $self->listref;

    for(my $i=scalar(@$listref)-1;$i>=0;$i--) {
        if($listref->[$i] eq $candidate) {
            splice @$listref, $i, 1;
        }
    }
}


sub find_one_by {
    my ($self, %method_to_filter_value) = @_;

    ELEMENT: foreach my $element (@{ $self->listref }) {
        keys %method_to_filter_value;   # sic! This is to "rewind" the each% operator to the beginning each time
        while(my ($filter_name, $filter_value) = each %method_to_filter_value) {
            my $actual_value = (ref($element) eq 'HASH') ? $element->{$filter_name} : $element->$filter_name();
            next ELEMENT unless( defined($actual_value)   # either both defined and equal or neither defined
                                    ? defined($filter_value) && ( (ref($filter_value) eq 'CODE')
                                                                    ? &$filter_value( $actual_value )
                                                                    : ( $filter_value eq $actual_value )
                                                                )
                                    : !defined($filter_value)
                               );
        }
        return $element;
    }

    return undef;   # have to be explicit here to avoid surprises
}


sub find_all_by {
    my ($self, %method_to_filter_value) = @_;

    my @filtered_elements = ();

    ELEMENT: foreach my $element (@{ $self->listref }) {
        keys %method_to_filter_value;   # sic! This is to "rewind" the each% operator to the beginning each time
        while(my ($filter_name, $filter_value) = each %method_to_filter_value) {
            my $actual_value = (ref($element) eq 'HASH') ? $element->{$filter_name} : $element->$filter_name();
            next ELEMENT unless( defined($actual_value)   # either both defined and equal or neither defined
                                    ? defined($filter_value) && ( (ref($filter_value) eq 'CODE')
                                                                    ? &$filter_value( $actual_value )
                                                                    : ( $filter_value eq $actual_value )
                                                                )
                                    : !defined($filter_value)
                               );
        }
        push @filtered_elements, $element;
    }

    return \@filtered_elements;
}


sub _find_all_by_subpattern {    # subpatterns can be combined into full patterns using +-,
    my ($self, $pattern) = @_;

    my $filtered_elements = [];
    $pattern //= '';

    if( $pattern=~/^\d+$/ ) {

        $filtered_elements = $self->find_all_by( 'dbID', $pattern );

    } elsif( $pattern=~/^(\d+)\.\.(\d+)$/ ) {

        $filtered_elements = $self->find_all_by( 'dbID', sub { return $1<=$_[0] && $_[0]<=$2; } );

    } elsif( $pattern=~/^(\d+)\.\.$/ ) {

        $filtered_elements = $self->find_all_by( 'dbID', sub { return $1<=$_[0]; } );

    } elsif( $pattern=~/^\.\.(\d+)$/ ) {

        $filtered_elements = $self->find_all_by( 'dbID', sub { return $_[0]<=$1; } );

    } elsif( $pattern=~/^\w+$/) {

        $filtered_elements = $self->find_all_by( 'name', $pattern );

    } elsif( $pattern=~/^[\w\%]+$/) {

        $pattern=~s/\%/.*/g;
        $filtered_elements = $self->find_all_by( 'name', sub { return $_[0]=~/^${pattern}$/; } );

    } elsif( $pattern=~/^(\w+)==(.*)$/) {

        $filtered_elements = $self->find_all_by( $1, $2 );

    } elsif( $pattern=~/^(\w+)!=(.*)$/) {

        $filtered_elements = $self->find_all_by( $1, sub { return $_[0] ne $2; } );

    } elsif( $pattern=~/^(\w+)<=(.*)$/) {       # NB: the order is important - all digraphs should be parsed before their proper prefixes

        $filtered_elements = $self->find_all_by( $1, sub { return $_[0] <= $2; } );

    } elsif( $pattern=~/^(\w+)>=(.*)$/) {

        $filtered_elements = $self->find_all_by( $1, sub { return $_[0] >= $2; } );

    } elsif( $pattern=~/^(\w+)<(.*)$/) {

        $filtered_elements = $self->find_all_by( $1, sub { return $_[0] < $2; } );

    } elsif( $pattern=~/^(\w+)>(.*)$/) {

        $filtered_elements = $self->find_all_by( $1, sub { return $_[0] > $2; } );

    } elsif( $pattern=~/^(\w+)~(.*)$/) {

        my $field = $1;
        $pattern = $2;
        $pattern =~ s/\%/.*/g;
        $filtered_elements = $self->find_all_by( $field, sub { return $_[0 ]=~ /^(.*,)?${pattern}(,.*)?$/; } );

    } else {
        die "The pattern '$pattern' is not recognized\n";
    }

    return $filtered_elements;
}


=head2 find_all_by_pattern

  Arg [1]    : (optional) string $pattern
  Example    : my $first_fifteen_analyses_and_two_more = $collection->find_all_by_pattern( '1..15,analysis_X,21' );
  Example    : my $two_open_ranges = $collection->>find_all_by_pattern( '..7,10..' );
  Example    : my $double_exclusion = $collection->find_all_by_pattern( '1..15-3..5+4' );
  Example    : my $blast_related_with_exceptions = $collection->find_all_by_pattern( 'blast%-12-%funnel' );
  Description: Filters an arrayref of non-repeating objects from the given collection by interpreting a pattern.
                The pattern can contain individual analyses_ids, individual logic_names,
                open and closed ranges of analysis_ids, wildcard patterns of logic_names,
                merges (+ or ,) and exclusions (-) of the above subsets.
  Exceptions : none
  Caller     : both beekeeper.pl (for scheduling) and runWorker.pl (for specialization)

=cut

sub find_all_by_pattern {
    my ($self, $pattern) = @_;

    if( not defined($pattern) ) {

        return [ $self->list ];

    } else {

        # By using the grouping, we ask Perl to return the pattern and their delimiters
        my @syll = split(/([+\-,])/, $pattern);

        my %uniq = map { ("$_" => $_) } @{ $self->_find_all_by_subpattern( shift @syll ) };   # initialize with the first syllable

        while(@syll) {
            my $operation   = shift @syll;  # by construction this is one of [+-,]
            my $subpattern  = shift @syll;  # can be an empty string

            foreach my $element (@{ $self->_find_all_by_subpattern( $subpattern ) }) {
                if($operation eq '-') {
                    delete $uniq{ "$element" };
                } else {
                    $uniq{ "$element" } = $element;
                }
            }
        }

        return [ values %uniq ];
    }
}


sub dark_collection {       # contain another collection of objects marked for deletion
    my $self = shift @_;

    if(@_) {
        $self->{'_dark_collection'} = shift @_;
    }
    return $self->{'_dark_collection'};
}


sub forget_and_mark_for_deletion {
    my $self        = shift @_;
    my $candidate   = shift @_;

    $self->forget( $candidate );

    unless( $self->dark_collection ) {
        $self->dark_collection( Bio::EnsEMBL::Hive::Utils::Collection->new );
    }
    $self->dark_collection->add( $candidate );
}


sub DESTROY {
    my $self = shift @_;

    $self->listref( [] );
    $self->dark_collection( undef );
}

1;
