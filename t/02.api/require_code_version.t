#!/usr/bin/env perl
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

use Test::More;
use Data::Dumper;

eval "use Bio::EnsEMBL::Hive::Version 4.0";
ok($@, 'cannot import eHive 4.0');

eval "use Bio::EnsEMBL::Hive::Version 2.0";
ok(!$@, 'can import eHive 2.0');

is(Bio::EnsEMBL::Hive::Version::get_code_version(), $Bio::EnsEMBL::Hive::Version::VERSION, 'get_code_version() returns the code version');

done_testing()
