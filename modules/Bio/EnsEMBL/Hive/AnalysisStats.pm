#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code

=pod 

=head1 NAME
  Bio::EnsEMBL::Hive::AnalysisStats

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 CONTACT
  Contact Jessica Severin on EnsEMBL::Hive implemetation/design detail: jessica@ebi.ac.uk
  Contact Ewan Birney on EnsEMBL in general: birney@sanger.ac.uk

=head1 APPENDIX
  The rest of the documentation details each of the object methods.
  Internal methods are usually preceded with a _
=cut

package Bio::EnsEMBL::Hive::AnalysisStats;

use strict;

use Bio::EnsEMBL::Analysis;
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Hive::Worker;

sub new {
  my ($class,@args) = @_;
  my $self = bless {}, $class;
  return $self;
}

sub adaptor {
  my $self = shift;
  $self->{'_adaptor'} = shift if(@_);
  return $self->{'_adaptor'};
}

sub update {
  my $self = shift;
  return unless($self->adaptor);
  $self->adaptor->update($self);
}

sub update_status {
  my ($self, $status ) = @_;
  return unless($self->adaptor);
  $self->adaptor->update_status($self->analysis_id, $status);
  $self->status($status);
}

sub analysis_id {
  my $self = shift;
  $self->{'_analysis_id'} = shift if(@_);
  return $self->{'_analysis_id'};
}

sub get_analysis {
  my $self = shift;
  unless($self->{'_analysis'}) {
    $self->{'_analysis'} = $self->adaptor->db->get_AnalysisAdaptor->fetch_by_dbID($self->analysis_id);
  }
  return $self->{'_analysis'};
}

sub status {
  my ($self, $value ) = @_;

  if(defined $value) {
    $self->{'_status'} = $value;
  }
  return $self->{'_status'};
}

sub batch_size {
  my $self = shift;
  $self->{'_batch_size'} = shift if(@_);
  $self->{'_batch_size'}=1 unless($self->{'_batch_size'});
  return $self->{'_batch_size'};
}

sub avg_msec_per_job {
  my $self = shift;
  $self->{'_avg_msec_per_job'} = shift if(@_);
  $self->{'_avg_msec_per_job'}=0 unless($self->{'_avg_msec_per_job'});
  return $self->{'_avg_msec_per_job'};
}

sub cpu_minutes_remaining {
  my $self = shift;
  return ($self->avg_msec_per_job * $self->unclaimed_job_count / 60000);
}

sub hive_capacity {
  my $self = shift;
  $self->{'_hive_capacity'} = shift if(@_);
  return $self->{'_hive_capacity'};
}

sub total_job_count {
  my $self = shift;
  $self->{'_total_job_count'} = shift if(@_);
  return $self->{'_total_job_count'};
}

sub unclaimed_job_count {
  my $self = shift;
  $self->{'_unclaimed_job_count'} = shift if(@_);
  return $self->{'_unclaimed_job_count'};
}

sub done_job_count {
  my $self = shift;
  $self->{'_done_job_count'} = shift if(@_);
  return $self->{'_done_job_count'};
}

sub failed_job_count {
  my $self = shift;
  $self->{'_failed_job_count'} = shift if(@_);
  $self->{'_failed_job_count'} = 0 unless(defined($self->{'_failed_job_count'}));
  return $self->{'_failed_job_count'};
}

sub running_job_count {
  my $self = shift;
  return $self->total_job_count
         - $self->done_job_count
         - $self->unclaimed_job_count
         - $self->failed_job_count;
}

sub num_required_workers {
  my $self = shift;
  $self->{'_num_required_workers'} = shift if(@_);
  return $self->{'_num_required_workers'};
}

sub seconds_since_last_update {
  my( $self, $value ) = @_;
  $self->{'_last_update'} = time() - $value if(defined($value));
  return time() - $self->{'_last_update'};
}

sub determine_status {
  my $self = shift;
  
  if($self->status ne 'BLOCKED') {
    if($self->done_job_count>0 and
       $self->total_job_count == $self->done_job_count + $self->failed_job_count) {
      $self->status('DONE');
    }
    if($self->total_job_count == $self->unclaimed_job_count) {
      $self->status('READY');
    }
    if($self->unclaimed_job_count>0 and
       $self->total_job_count > $self->unclaimed_job_count) {
      $self->status('WORKING');
    }
  }
  return $self;
}
  
sub print_stats {
  my $self = shift;

  return unless($self->get_analysis);
  printf("%30s(%3d) %11s %d:job_msec %d:cpu_min (%d:q %d:r %d:d %d:f %d:t) [%d/%d workers] (%d secs synched)\n",
 #printf("%30s(%3d) %12s jobs(t:%d,q:%d,d:%d,f:%d) b:%d M:%d w:%d (%d secs old)\n",
        $self->get_analysis->logic_name,
        $self->analysis_id,
        $self->status,
        $self->avg_msec_per_job,$self->cpu_minutes_remaining,
        $self->unclaimed_job_count,$self->running_job_count,$self->done_job_count,$self->failed_job_count,$self->total_job_count,
        $self->num_required_workers, $self->hive_capacity,
        $self->seconds_since_last_update,
        );
}

1;
