# Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# Copyright [2016-2022] EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;


use Cwd;
use File::Spec;
use File::Basename qw/dirname/;
use Test::More;
use Test::Warnings;
use Time::Piece;
use Bio::EnsEMBL::Hive::Utils::Test qw(all_source_files);

if ( not $ENV{TEST_AUTHOR} ) {
  my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
  plan( skip_all => $msg );
}


#chdir into the file's target & request cwd() which should be fully resolved now.
#then go back
my $file_dir = dirname(__FILE__);
my $original_dir = cwd();
chdir($file_dir);
my $cur_dir = cwd();
chdir($original_dir);
my $root = File::Spec->catdir($cur_dir, File::Spec->updir());


=head2 has_apache2_licence

  Arg [1]    : File path to the file to test
  Example    : has_apache2_licence('/my/file.pm');
  Description: Asserts if we can find the short version of the Apache v2.0
               licence and correct Copyright year within the first 30 lines of the given file. You can
               skip the test with a C<no critic (RequireApache2Licence)> tag. We
               also support the American spelling of this.
  Returntype : None
  Exceptions : None

=cut

sub has_apache2_licence {
  my ($file) = @_;
  my $count = 0;
  my $max_lines = 999999;
  my ($found_copyright, $found_url, $found_warranties, $found_sanger_embl_ebi_year, $found_embl_ebi_year) = (0,0,0,0,0);
  my $current_year = Time::Piece->new()->year();

  open my $fh, '<', $file or die "Cannot open $file: $!";
  while(my $line = <$fh>) {
    #last if $count >= $max_lines;
    $found_copyright = 1 if $line =~ /Apache License, Version 2\.0/;
    $found_url = 1 if $line =~ /www.apache.org.+LICENSE-2.0/;
    $found_warranties = 1 if $line =~ /WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND/;
    $found_sanger_embl_ebi_year = 1 if $line =~ /Copyright \[1999\-2015\] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute/;
    $found_embl_ebi_year = 1 if $line =~ /Copyright \[2016\-$current_year\] EMBL-European Bioinformatics Institute/;
    $count++;
  }
  close $fh;
  if($found_copyright && $found_url && $found_warranties && $found_sanger_embl_ebi_year && $found_embl_ebi_year) {
    return pass("$file has a Apache v2.0 licence declaration and correct Copyright year [2016-$current_year]");
  }
  diag("$file is missing Apache v2.0 declaration") unless $found_copyright;
  diag("$file is missing Apache URL")              unless $found_url;
  diag("$file is missing Apache v2.0 warranties")  unless $found_warranties;
  diag("$file is missing Copyright \[1999\-2015\] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute")  unless $found_sanger_embl_ebi_year;
  diag("$file is missing Copyright \[2016\-$current_year\] EMBL-European Bioinformatics Institute")  unless $found_embl_ebi_year;
  return fail("$file does not have an Apache v2.0 licence declaration and correct Copyright year [2016-$current_year] in the first $max_lines lines");
}

my @source_files = all_source_files($root);
#Find all files & run
foreach my $f (@source_files) {
    next if $f =~ /\/sphinx\//;
    next if $f =~ /\/docutils\//;
    next if $f =~ /\/fake_bin\//;
    next if $f =~ /\/deceptive_bin\//;
    next if $f =~ /\/lsf_detection\//;
    next if $f =~ /\/deps\//;
    # Unlicensed files
    next if $f =~ /\.(png|jpg|pdf|pyc|tgz|txt|dot|rst|fa|fastq|md|json|xml)$/;
    next if $f =~ /\/Makefile$/;
    next if $f =~ /\/cpanfile$/;
    next if $f =~ /\/perlcriticrc$/;
    next if $f =~ /\/psql$/;
    next if $f =~ /\/input_job_factory\.sql$/;
    has_apache2_licence($f);
}

done_testing();
