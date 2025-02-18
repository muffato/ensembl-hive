-- Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
-- Copyright [2016-2022] EMBL-European Bioinformatics Institute
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--      http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.


    -- Allow the monitor.analysis field to be arbitrarily long
    -- to accommodate multiple long analysis names concatenated together
ALTER TABLE monitor ALTER COLUMN analysis SET DATA TYPE TEXT;

    -- UPDATE hive_sql_schema_version
UPDATE hive_meta SET meta_value=51 WHERE meta_key='hive_sql_schema_version' AND meta_value='50';

