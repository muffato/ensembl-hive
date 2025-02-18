Changelog
*********

Version 2.6
===========

   *Summer 2021 "codon" update

Release overview
----------------

Version 2.6 is a stability and usability release, with a number
of small improvements. The primary motivation of this release is
to provide users with a feature- and schema- stable eHive version
that incorporates two important changes for compatibility with Ensembl's
future computing environment. First, the temporary directories used by eHive
processes are determined in a much more flexible manner than in previous
versions, and there is a facility for users to explicitly set temporary
directories if desired. Second, there have been several improvements made
for the guest language "wrappers" - particularly for the Python wrappers.

Major new features and scripts
------------------------------

* Temp directories can be explicitly set by the user as worker submission options, via hive_config.json, or by setting the $TMPDIR environment variable
* new peekJob.pl script to show parameters visible to a particular job
* New --big_red_button option for beekeeper.pl to attempt to stop an entire pipeline, including all Beekeepers and Workers
* New pure Python framework for testing Runnables

General improvements
--------------------

* Various documentation improvements, including a tip sheet
* Root directory environment variables can be with or without "_CVS_"
* Updates for compatibility with new versions of DBI::st
* More flexible checks for db permissions
* CPAN dependencies are cached for faster builds
* Improved handling of SQL errors
* Changes to logging and output to improve both clarity and performance
* Improved deadlock protection for bulk operations on Jobs (e.g. --reset_all_jobs)

Guest language support
----------------------

* GuestLanguage interface now has a build phase to allow pre-compiling
* Python wrappers have been packaged so that they can be added as a requirements.txt compatibility and are more compatible with IDEs
* Python code refactored to harmonise with Ensembl Python standards
* General improvements and bugfixes to the Python wrapper
* Wrappers added to Docker image

Profiling and testing framework
-------------------------------

* Custom categories can be added to generate_timeline.pl
* Improvements to resource_usage view
* New semaphore_job view
* Improved output from the Runnables test interface
* Redirected Beekeeper output to avoid cluttering unit test output

Usability improvements
----------------------

* Beekeeper output improved for clarity and more accurate job counts
* New debug mode prevents the forking of eHive processes that confused the Perl debugger
* JSON output option for tweak_pipeline.pl
* Can now search for analysis logic_names and tags using regexes
* Fixed output bugs in init_pipeline.pl and tweak_pipeline.pl
* Explicit errors thrown when encountering a missing or invalid reg_conf

Version 2.5
===========

   *Spring 2018 edition*

Main highlights of the release
------------------------------

Version 2.5 is a stability and usability release, with a number of
improvements, mostly behind-the-scenes, throughout the system to make it
more reliable and flexible. In addition, there are major updates to the
documentation and examples, as well as improved visualisation tools to
assist users with using eHive to its full potential.

Documentation updates
---------------------

* New comprehensive user manual at http://ensembl-hive.readthedocs.io/
* Improved script help output for coverage and clarity.
* Improved error messages.
* New example pipelines to illustrate Accumulator strategies (under ``modules/Bio/EnsEMBL/Hive/Examples/Kmer``).

Script updates
--------------

* All scripts:

    * Harmonised script options across all scripts where possible.
    * Switches (options that are either on or off, such as `--force`) no longer take a 1 or 0 argument, and can be negated with a "no" prefix. For example, ``--force 1`` is now ``--force`` or ``--can_respecialize 0`` is now ``--nocan_respecialize``.

* beekeeper.pl:

    * Worker respecialization (``--can_respecialize``) is now turned on by default in ``beekeeper.pl`` (but remains off by default in ``runWorker.pl``).
    * New ``--loop_until`` options "FOREVER", "ANALYSIS_FAILURE", "JOB_FAILURE", and "NO_WORK".
    * The Beekeeper can now monitor an eHive pipeline without affecting it by being given read-only database connection parameters.
    * Beekeeper sessions are now tracked in the eHive database, along with their status, start and end time, cause of death, user that launched the Beekeeper, and command-line options.
    * Beekeepers can now be passed a specific ``HiveConfig.json`` with the ``--config_file`` option.

* runWorker.pl:

    * runWorker.pl can now be passed a specific ``HiveConfig.json`` with the ``--config_file`` option.

* visualize_jobs.pl:

    * New visualize_jobs.pl script which shows a Job-level picture of an eHive pipeline, including parameter and Accumulator values.

Database related updates
------------------------

* Database handles now protected from timed-out connections.
* More flexible quoting rules for URL syntax, allowing extra parameters to be passed.
* Passwords are now hidden from process tables.

Runnables
---------

* Runnables written in Java are now supported.
* Improved NotifyByEmail.
* Improvements to ``run_system_command()`` and the SystemCommand Runnable.
* Improved logging, with ``is_error`` replaced by several available ``message_class`` options.

Other improvements
------------------

* New ``hive_default_max_retry_count`` for PipeConfig files to set the retry count for all analyses in one place.

* New utility methods in ``Bio::EnsEMBL::Hive::Utils::Test`` to support test plans.

* Analyses can now be excluded (so that their Jobs will not be claimed by Workers) by setting the new ``is_excluded`` property.

    * Analyses will automatically be excluded when some error conditions are detected.

* Meadow and Worker submission updates:

    * New AccountingDisabled configuration option for Meadows where process accounting is unavailable or unreliable.
    * Pre-registration of Workers for more reliable Worker submission and startup.

* More automated tests and better test coverage.

Also...
-------

* Semaphores now have their own table in the eHive database, supporting cross-database semaphore links.
* Prototype Docker and Docker Swarm support (note, this is considered Alpha software and is not yet suitable for production use).

Removed in 2.5
--------------

* Dynamic ``hive_capacity`` is no longer supported.
* Support for Perl version 5.10 has been dropped for this and future releases of eHive. This version is known to work with 5.10, but it will no longer be tested against this version.


Version 2.4
===========

   *Spring 2016 edition*

Main highlights of the release
------------------------------

* Conditional dataflow on the pipeline structure level. For every dataflow rule you can set up conditions
  that will be computed based on the parameters of the context.
  Multiple conditions can be grouped with an optional common *ELSE* branch where the dataflow will happen by default.
* *INPUT_PLUS* is a lightweight mechanism that allows a parent job to selectively pass its parameters to its children
  without the need to specify which parameters are being passed. It's a significant simplification in comparison
  with what could be achieved with templates, although templates will keep their niche for renaming and evaluating params.
* New style URL parser that understands shorter URLs like ``?table_name=foo``, ``?accu_name=bar&accu_address=[]`` for referring to local objects.
  It also allows to refer to the absoulte/relative SQLite filepath in full. Some compatibility sacrifices had to be made,
  but in version/2.4 the old parsing way has priority over the new one, with a warning to encourage switching to the new format.

.. tip::
   See these three features in action in the Long-multiplication pipelines

*   New configuration mechanism to 'tweak' parameters and attributes of pipelines either during pipeline initialization or afterwards.
    For tweaking things during initialization we have extended ``init_pipeline.pl`` to understand 'tweak' commands -SET , -SHOW and -DELETE.
    For tweaking things after the pipeline database has been created there is a new ``tweak_pipeline.pl`` script that understands the same 'tweaks' ::

            -SET 'pipeline.param[take_time]=20'                     # override a value of a pipeline-wide parameter; can also create an inexistent parameter
            -SET 'pipeline.hive_pipeline_name=new_name'             # override a value of a hive_meta attribute
            -SET 'analysis[take_b_apart].param[base]=10'            # override a value of an analysis-wide parameter; can also create an inexistent parameter
            -SET 'analysis[add_together].analysis_capacity=3'       # override a value of an analysis attribute
            -SET 'analysis[blast%].batch_size=15'                   # override a value of an analysis_stats attribute for all analyses matching a pattern
            -SET 'analysis[part_multiply].resource_class=urgent'    # set the resource class of an analysis (whether a resource class with this name existed or not)
            -SET 'resource_class[urgent].LSF=-q yesteryear'         # update or create a new resource description

    In both contexts you can print out the current value of things::

            -SHOW 'pipeline.hive_pipeline_name'                     # show the pipeline_name
            -SHOW 'pipeline.param[take_time]'                       # show the value of a pipeline-wide parameter
            -SHOW 'analysis[add_together].analysis_capacity'        # show the value of an analysis attribute
            -SHOW 'analysis[add_together].param[foo]'               # show the value of an analysis parameter
            -SHOW 'resource_class[urgent].LSF'                      # show the description of a particular meadow of a resource_class

    Either pipeline-wide or analysis-wide parameters can also be deleted::

            -DELETE 'pipeline.param[foo]'                           # delete a pipeline-wide parameter
            -DELETE 'analysis[add_together].param[bar]'             # delete an analysis-wide parameter

    In addition to the simple attributes analyses also have two "complex" ones: wait_for and flow_into.
    They can either be set from scratch::

            -SET 'analysis[add_together].wait_for=["analysisX","analysisY"]'                # remove all old wait_for rules, establish new ones
            -SET 'analysis[part_multiply].flow_into={1=>"?table_name=intermediate_result"}' # remove all old flow_into rules, establish new ones

    or you can append new ones to the existing pile of rules::

            -SET 'analysis[add_together].wait_for+=["analysisZ","analysisW"]'               # append two new wait_for rules
            -SET 'analysis[part_multiply].flow_into+={1=>"another_sink"}'                   # append a new flow_into rule

    You can only delete the whole set, not individually::

            -DELETE 'analysis[add_together].wait_for'                                       # delete all wait_for rules of an analysis
            -DELETE 'analysis[part_multiply].flow_into'                                     # delete all flow_into rules of an analysis

    You can also check their current content::

            -SHOW 'analysis[add_together].wait_for'                                         # shows the list of wait_for rules of an analysis
            -SHOW 'analysis[part_multiply].flow_into'                                       # shows the list of flow_into rules of an analysis

    The 'tweak' mechanism does not require that you prepare the PipeConfig files with $self->o() references, which significantly simplifies PipeConfigs.

Universal Runnables
-------------------

* ``JobFactory``: non-contiguous split option has been added for those who have to use minibatching
* ``FastaFactory`` has been improved: more input file-formats -which can be compressed-, target output directory
* ``SqlCmd`` supports transactions
* new ``run_system_command()`` method available to all Runnables (defined in ``Process``). It takes care of disconnecting from the eHive database and can capture stderr
* "Bash pipefail" mode is used to catch errors on both sides of pipes in many ``system()`` calls

Developer tools
---------------

* Registry names can generally be used to refer to databases (``go_figure_dbc()``)
* The parameter substitution behaviour when some components are unavailable has been standardised, ``param_exists()`` has been fixed
* An extra ``post_healthcheck()`` API method has been added to Runnables (and the *POST_HEALTHCHECK* status to Jobs) to stop failures in their tracks
* We reenabled cross-database dataflow and control rules and added a special Client/Server version of LongMult pipeline.
* The diagram display code can now display the newly added conditions (with a length limit) and cross-database dataflow or control rules (parts of "foreign" pipelines are shown on different colour background).
* An experimental *Unicode-art* flow diagram drawing code has been implemented (skip the -output parameter in ``generate_graph.pl`` to see)
* eHive's DBAdaptor now has methods to get the list of eHive tables and views
* standaloneJob test method: warnings can be assessed via a regular expression
* Support for Slack WebHook integrations in beekeeper and a dedicated Runnable

Under the hood
--------------

* ``HivePipeline`` object with its collections becomes the center of things, and ``TheApiary`` becomes the centralized way of accessing foreign objects
* A lot of work has been done on improving the test suite to run faster and cover more modules
* A failed ``prepare()`` shows a full stack trace on error
* Speed improvement of storing extended job parameters via adding an MD5 checksum based index
* The parsers of both ``bjobs`` and ``bacct`` have been extended to also support the output format of LSF v.9.1.2.0

And of course numerous bug fixes, many of which have been ported to the previous version branches.

Example pipelines and runnables
-------------------------------

* A new example pipeline that calculates %GC for a collection of sequences has been created. It is configured using the ``GCPct_conf`` PipeConfig.
* All the example *Runnables* and *PipeConfigs* are now grouped together under ``Bio/EnsEMBL/Hive/Examples``.

  * ``DbCmd/`` contains the ``TableDumperZipper_conf`` PipeConfig, which illustrates usage of the ``DbCmd`` Runnable
  * ``FailureTest/`` contains the ``FailureTest_conf`` and ``MemlimitTest_conf`` PipeConfigs, along with the ``FailureTest`` runnable, which illustrate eHive error handling
  * ``GC/`` contains the ``GCPct_conf`` PipeConfig and two new Runnables, ``CalcOverallPercentage`` and ``CountATGC``, which together form a simple example pipeline illustrating the eHive fan and accumulator features.
  * ``Factories/`` contains four PipeConfigs illustrating the use of a *factory* runnable to create fans of jobs. ``CompressFiles_conf``, ``RunListOfCommandsOnFarm_conf``, and ``ApplyToDatabases_conf`` use the ``JobFactory`` runnable to create the fan, whilst ``FastaFactory_conf`` illustrates the use of the more specialised ``FastaFactory`` runnable.
  * ``LongMult/`` contains the long multiplication example pipeline. There are several PipeConfigs that implement this pipeline using different eHive features, such as the parameter stack, the new *INPUT_PLUS* mechanism, and client-server interactions.
  * ``SystemCmd/`` contains ``AnyCommand_conf``, a very simple PipeConfig that runs a single command using SystemCmd.

Version 2.3
===========

    *Spring 2015 edition*

Main highlights of the release
------------------------------

* API for Runnables written in "guest languages" (with reference Python implementation and examples)
* Test suite (inspired by `Roy's original pull request <https://github.com/Ensembl/ensembl-hive/pull/7>`_)
* "TailTrimmer" [ in analyses with nontrivial batch sizes ] several techniques are now used to automatically decrease the batch size 
  towards the end of the analysis in order to speed up the execution of the whole analysis
* Stability improvements that significantly increase efficiency of parallel execution

Higher level features
---------------------

* support for Runnables written in Python3 and API for extending similar support to other languages (this API may still change)
* coloured Beekeeper output - catches the eye!
* ``SystemCmd`` now runs through ``Capture::Tiny`` , captures the error output from the actual command that gets stored in *log_message*
* ``SystemCmd`` also knows how to capture *MEMLIMIT* events from the underlying Java code 
* ``SystemCmd`` can map specific return codes to dataflow events
* a new ``DbCmd`` runnable that mimics the behaviour of ``db_cmd.pl`` script ; you can also pipe data in or out of the connection to another system command
* ``DbCmd``, ``DatabaseDumper`` and ``MySQLTransfer`` runnable hide passwords in the command lines that they run
* ``beekeeper.pl -unkwn`` option to clean up the workers found to be in *UNKWN* state (at the user's risk!)

Lower level features
--------------------

* record the ``meadow_user`` in each Worker entry -- these values are also used when querying the Meadow to avoid running an equivalent of ``-u all`` in SGE Meadow
* record the ``when_seen`` timestamp in each Worker entry -- when the Worker was last seen as running by the Beekeeper process.
* testing: introduced a Travis-integrated test suite loosely based on `Roy's original pull request <https://github.com/Ensembl/ensembl-hive/pull/7>`_.
  The extended version tests direct API calls, runs individual Runnables (and tests their dataflow/warning events) or whole pipelines
* testing: Travis runs tests against Hive databases stored in local MySQL, PostgreSQL and SQLite databases
* stability [too many simultaneous queries] : detect and log deadlock collisions and retry them for a given number of times before failing
* stability [running out of server connections] : try to resolve the "too many connections" situation by bouncing, waiting and retrying
* stability [running out of local ports] : avoiding *RELOCATED* workers by applying incemental backoff-and-retry approach from Ethernet CSMA/CD protocol
* stability [applying an incorrect patch] : schema patches now have internal SQL-based checks and should not cause much damage if applied in wrong order
  + a new script to create such patches

* the schema version changes to 73
* multiple bug fixes, many of which have been ported to the previous version branches.


Version 2.2
===========

    *Analyses patterns*

* Running and maintenance of pipeline subsets has been made easy with ``-analyses_pattern`` option in ``beekeeper.pl``
  that understands ranges and additive/subtractive merging. You can refer to analyses in many different ways.
  Examples::

        -analyses_pattern 1..9                                  # show scheduling for a range of analysis_ids
        -analyses_pattern 1..9,11..15   -run                    # run a scheduling iteration for two ranges of analysis_ids
        -analyses_pattern fasta%        -sync                   # sync analyses matching a pattern
        -analyses_pattern 1..9-5-report -loop                   # loop over a range except two analyses
        -analyses_pattern 1..9,fasta%   -reset_all_jobs         # reset all jobs belonging to a range and a pattern
        -analyses_pattern foo,bar,baz   -reset_failed_jobs      # reset failed jobs belonging to three analyses by names

* The same option is available in ``runWorker.pl`` to constrain the set of analyses to specialize into (fully works with -can_respecialize 1 mode)

* Detailed log of Scheduler's decision-making process is available

* ``db_cmd.pl`` and ``SystemCmd.pm`` runnable have been reworked and are now better adapted for quoted arguments

* Doxygen API documentation packaged with the code

* Scripts' man pages converted into HTML and packaged with the code

* New docs about installing eHive, running eHive and running MPI jobs with eHive

* Using rawgit to render HTML docs hosted on GitHub (impossible otherwise)

* No schema changes since version/2.1 : the same database should continue to work with newer code without patching


Version 2.1
===========

   *multi-role*

* Improved internal API that allows implicit lazy-loading of objects associated with other objects via their dbIDs

* Objects that make up pipeline's graph can be loaded into cache, which simplifies structural topup of existing pipeline databases

* Diagram-drawing engine was stripped of its' dependence on dbIDs, so diagrams can now be built directly from PipeConfig file(s) using ``-pipeconfig`` option(s)

* ``-analysis_topup`` removed (became the default mode of operation), ``-job_topup`` removed in favour of ``seed_pipeline.pl`` providing same functionality

* ``pipeline_wide_parameters`` moved into a separate table, so hive-specific ``meta`` table is no longer needed, and Ensembl's version can happily coexist

* ``monitor`` table removed in favour of offline ``generate_timeline.pl`` script (that does not require a constantly running ``beekeeper.pl`` for data generation)

* ``pipeline_create_commands()`` is executed even on topup; redefine to return an empty list or use ``-hive_no_init`` if you don't need commands to be executed

* Switched to ``worker_resource_usage`` table, unified resource collection calls for other Meadows, so SGE/CONDOR/etc resources can be shown in guiHive & timeline.

* Introduced ``role`` table and *Role* objects to better track role-switching of multirole Workers

* Added ``Process::complete_early()`` as the blessed way to exit the code early successfully and store a *log_message*

* More careful semaphore rebalancing strategy that can also be switched on or off during pipeline database generation

* Logging and error reporting has been improved and simplified

* Multiple bugs have been fixed


Version 2.0
===========

    *a major 'coreless' release of Hive code*

* Removed dependencies from EnsEMBL core code. You don't need to install Ensembl core to run non-Ensembl pipelines.

* Moved Ensembl-specific configuration to ``EnsemblGeneric_conf``, from which all Ensembl pipelines should now inherit.


Version 1.9
===========

    *largely a maintenance release + preparations for separation from Ensembl core*

* Various preparations to make the code more GitHub-friendly

* A better class hierarchy with less dependencies from Ensembl core code

* At last we have a proper code version test: ``use Bio::EnsEMBL::Hive::Version 1.9;`` works, but ``use Bio::EnsEMBL::Hive::Version 2.0`` currently fails.

* ``beekeeper --version``, ``runWorker.pl --version`` and ``db_cmd.pl --version`` report both code version and Hive database schema version

* Multiple bug fixes


.. raw:: latex

   \begin{comment}

Legacy versions
===============

Before EnsEMBL rel.75
---------------------

::

* Wed Dec 11 12:55:58 2013 +0000 | Leo Gordon | updated schema diagram (PNG) and description (HTML)
* Mon Dec 9 14:19:48 2013 +0000 | Leo Gordon | bugfix: sqlite mode now works again
* Mon Dec 9 14:01:27 2013 +0000 | Leo Gordon | added Apache 2.0 license to all files
* Wed Dec 4 11:26:09 2013 +0000 | Leo Gordon | schema_change: switched some foreign keys to ON DELETE CASCADE (thanks, Harpreet!)
* Wed Dec 4 11:04:14 2013 +0000 | Matthieu Muffato | Updated the list of dependencies
* Wed Dec 4 10:53:17 2013 +0000 | Matthieu Muffato | Added info on how to run lsf_report.pl and generate_timeline.pl
* Wed Dec 4 10:31:51 2013 +0000 | Matthieu Muffato | Removed the option to use a logscale axis, and added a grid in the background
* Mon Dec 2 18:13:29 2013 +0000 | Matthieu Muffato | Another set of rounding errors
* Mon Dec 2 18:01:59 2013 +0000 | Matthieu Muffato | Added a mode to plot the number of pending workers for each analysis
* Mon Dec 2 18:01:30 2013 +0000 | Matthieu Muffato | Neater way to add/substract a worker
* Mon Dec 2 18:00:02 2013 +0000 | Matthieu Muffato | Added a mode to plot the amount of unused CPU cores each analysis
* Mon Dec 2 17:55:13 2013 +0000 | Matthieu Muffato | "Unused memory" instead of "Wasted memory"
* Mon Dec 2 17:01:52 2013 +0000 | Matthieu Muffato | Pulls in the time information (pending time, cpu usage, lifespan)
* Mon Dec 2 09:56:07 2013 +0000 | Matthieu Muffato | Improved the documentation
* Mon Dec 2 09:53:53 2013 +0000 | Matthieu Muffato | Added "verbose" mode
* Mon Dec 2 08:35:35 2013 +0000 | Matthieu Muffato | Not valid any more when counting the wasted memory (rounding errors)
* Sun Dec 1 23:20:35 2013 +0000 | Matthieu Muffato | Added a mode to plot the amount of wasted memory by each analysis
* Sun Dec 1 23:11:11 2013 +0000 | Matthieu Muffato | Also store the meadow_name in lsf_report
* Sun Dec 1 23:10:21 2013 +0000 | Matthieu Muffato | The unit conversion table is constant
* Sun Dec 1 23:03:56 2013 +0000 | Matthieu Muffato | dbname may be undefined
* Sun Dec 1 22:17:37 2013 +0000 | Matthieu Muffato | Added a mode to plot the number of CPU cores used by each analysis
* Sun Dec 1 22:13:24 2013 +0000 | Matthieu Muffato | Added a mode to plot the RAM used by each analysis
* Tue Dec 3 12:19:20 2013 +0000 | Leo Gordon | create a separate directory layer to group log files of the same iteration
* Tue Dec 3 11:56:07 2013 +0000 | Leo Gordon | separate output files by LSF_job_id and LSF_jobarray_index
* Tue Nov 26 11:08:31 2013 +0000 | Leo Gordon | simplify logging of submission output/error streams
* Wed Nov 27 12:19:20 2013 +0000 | Matthieu Muffato | s/profile/timeline/g
* Wed Nov 27 11:46:31 2013 +0000 | Matthieu Muffato | Gets the birth/death events instead of sampling the database. The "NOTHING" curve is not needed any more
* Thu Nov 14 01:01:33 2013 +0000 | Matthieu Muffato | Reads the data from the database once at the beginning, and process it offline
* Wed Sep 11 00:17:51 2013 +0100 | Matthieu Muffato | "DarkSlateGray" looks better for the "NOTHING" curve
* Wed Sep 11 00:09:00 2013 +0100 | Matthieu Muffato | Added documentation
* Wed Sep 11 00:08:42 2013 +0100 | Matthieu Muffato | GNUplot is now controlled via Chart::Gnuplot
* Tue Sep 10 14:31:15 2013 +0100 | Matthieu Muffato | Improved the GNU-plot output
* Tue Sep 10 01:20:28 2013 +0100 | Matthieu Muffato | Only gnuplot has to know about the filtered analysis, the CSV file should still contain all the data
* Tue Sep 10 00:51:55 2013 +0100 | Matthieu Muffato | First version of a script to generate the analysis profile of a pipeline
* Mon Nov 25 16:57:37 2013 +0000 | Leo Gordon | schema_change: detect and register RELOCATED events that used to mess up things on LSF 9.0 ("job rescheduled" in LSF parlance)
* Mon Nov 25 16:54:11 2013 +0000 | Leo Gordon | be more careful with fetch_overdue_workers (Use 5sec threshold to avoid checking recently active Workers. Do not use it at all when performing -all_dead.)
* Mon Nov 25 16:47:35 2013 +0000 | Leo Gordon | bugfix:  last_check_in should only be updated by register_worker_death if the Worker is burying itself
* Mon Nov 25 16:35:16 2013 +0000 | Leo Gordon | cosmetic: added (commented out) warning messages for every external system() call that LSF module runs - simplifies debugging a lot
* Mon Nov 25 14:08:52 2013 +0000 | Leo Gordon | ranked claiming technology: added support for both sqlite and pgsql drivers
* Thu Nov 21 15:40:31 2013 +0000 | Leo Gordon | The last resort: try claiming without an offset (risking a collision)
* Tue Nov 19 11:17:38 2013 +0000 | Leo Gordon | use OFFSET to separate jobs being claimed into ranges
* Mon Nov 18 14:55:11 2013 +0000 | Leo Gordon | No need to left join into worker table - thanks, Javier!
* Tue Nov 12 16:42:32 2013 +0000 | Leo Gordon | ResourceDescription expanded to include both submission_cmd_args and worker_cmd_args. Both args can be specified in a PipeConfig file.
* Tue Nov 12 11:15:56 2013 +0000 | Leo Gordon | increase TotalRunningWorkersMax to 2000
* Mon Nov 11 14:32:04 2013 +0000 | Leo Gordon | added an example of how to turn a csv into a list by param_substitute
* Wed Nov 6 11:13:35 2013 +0000 | Leo Gordon | introducing db_cmd() interface method that takes care of the path to db_cmd.pl
* Tue Nov 5 09:33:37 2013 +0000 | Matthieu Muffato | bugfix: the batch_size parameter should have a hyphen in front of it
* Fri Oct 25 15:28:42 2013 +0100 | Leo Gordon | (1) do not change SEMAPHORED jobs to READY and (2) support more flexibility in choosing which statuses to reset
* Fri Oct 25 11:35:57 2013 +0100 | Leo Gordon | schema change: turned all VARCHAR(<255) into VARCHAR(255) -- should improve experience with long host namest (thanks, MichaelP!)
* Fri Oct 25 10:24:45 2013 +0100 | Leo Gordon | param_required() now automatically sets transient_error(0) before dying, to avoid unnecessary retries (thanks, Matthieu!)
* Thu Oct 24 15:37:36 2013 +0100 | Matthieu Muffato | "expected_size" has to be substituted as well
* Tue Oct 15 11:21:16 2013 +0100 | Matthieu Muffato | bugfix: the query has to be re-substituted for each job
* Tue Oct 8 10:58:22 2013 +0100 | Matthieu Muffato | The SqlHealthcheck runnable can now perform multiple tests
* Fri Sep 27 18:16:11 2013 +0100 | Matthieu Muffato | -reg_conf and -reg_type can be ommitted in db_cmd.pl

After Sept'2013 workshops
-------------------------

::

* Tue Oct 1 16:30:14 2013 +0100 | Leo Gordon | newer Perl required, BioPerl no longer required, seed_pipeline.pl mentioned
* Tue Oct 1 13:03:21 2013 +0100 | Leo Gordon | pipeline_name is now automatically computed from ClassName; simplified workshop's example files and slides
* Fri Sep 27 15:21:04 2013 +0100 | Leo Gordon | added param_exists() method for checking whether a parameter has been initialized at all
* Thu Sep 26 23:57:55 2013 +0100 | Leo Gordon | cleaned up the last (optional) slide on pipeline_wide_parameters; removed the exercise about abstracting out the compressor (formerly from CompressFiles_conf)
* Thu Sep 26 23:54:55 2013 +0100 | Leo Gordon | separated out "long addition" functionality to concentrate on Hive API when writing the Runnable, and not on maths
* Thu Sep 26 10:53:44 2013 +0100 | Leo Gordon | bugfix: ENSCOMPARASW-131. Swapped two rearrange() calls for slicing a hashref
* Wed Sep 25 16:42:47 2013 +0100 | Leo Gordon | bugfix: ENSCOMPARASW-132. When all dependent jobs (>1) fail to be created due to unique constraint, they now correctly update status to READY
* Wed Sep 25 15:43:58 2013 +0100 | Leo Gordon | bugfix: make sure the pipeline works even when b_multiplier only contains digits 0 and 1
* Wed Sep 25 15:03:09 2013 +0100 | Leo Gordon | bugfix: properly support evaluation of complex substituted expressions that yield a hashref

Before Sanger workshop
----------------------

::

* Mon Sep 23 12:29:44 2013 +0100 | Leo Gordon | added "git clone" option
* Mon Sep 23 12:22:07 2013 +0100 | Leo Gordon | some corrections to slides part2
* Sun Sep 22 20:18:42 2013 +0100 | Leo Gordon | part3 of the slides and the solutions (first version)
* Sat Sep 21 22:31:29 2013 +0100 | Leo Gordon | updated slides for parts 1 and 2 and solutions2.tar
* Thu Sep 19 11:25:37 2013 +0100 | Leo Gordon | Sanger version of the first part (re-made in LibreOffice)
* Mon Sep 16 09:30:15 2013 +0100 | Leo Gordon | bugfix: should not assume the presence of JobAdaptor in dataflow
* Fri Sep 13 16:28:13 2013 +0100 | Leo Gordon | alternative substitution syntax #expr( #alpha#*#beta# )expr# and a test script
* Fri Sep 13 11:17:45 2013 +0100 | Leo Gordon | cleanup: two templates that are no longer necessary
* Wed Sep 11 16:45:53 2013 +0100 | Leo Gordon | new colourscheme has arrived!
* Tue Sep 10 16:43:29 2013 +0100 | Leo Gordon | typo bugfix: jobs-->job in SQL
* Tue Sep 10 15:46:40 2013 +0100 | Leo Gordon | bugfix: reset the tried jobs to retry_count=1 and untried ones to retry_count=0 when doing a bulk reset
* Mon Sep 9 13:11:10 2013 +0100 | Leo Gordon | changes made before the talk
* Sun Sep 8 22:58:11 2013 +0100 | Leo Gordon | Preliminary version of slides for the second part of the workshop.
* Sun Sep 8 19:20:02 2013 +0100 | Leo Gordon | bugfix: we should allow any characters apart from { and } in the key
* Sun Sep 8 14:37:43 2013 +0100 | Leo Gordon | cosmetic: a hint for people working on the example
* Sat Sep 7 14:25:36 2013 +0100 | Leo Gordon | added support for EHIVE_HOST and EHIVE_PORT envariables; useful for the workshop environment
* Sat Sep 7 12:35:11 2013 +0100 | Leo Gordon | imported List::Util to be able to run max/min/sum of lists in substituted expressions
* Sat Sep 7 11:26:18 2013 +0100 | Leo Gordon | bugfix: now correctly supports directory names with dots in them

Before EBI workshop
-------------------

::

* Thu Sep 5 16:55:44 2013 +0100 | Leo Gordon | PDF version of the workshop slides from GoogleDocs
* Thu Sep 5 09:37:00 2013 +0100 | Leo Gordon | adding new unit - T for terabytes (mainly to pacify EBIs LSF 8 with a reporting bug)
* Wed Sep 4 21:54:43 2013 +0100 | Leo Gordon | the initial state of MemlimitTest pipeline for the workshop
* Wed Sep 4 13:06:46 2013 +0100 | Leo Gordon | methods dbconn_2_mysql(), dbconn_2_pgsql(), db_connect_command(), db_execute_command() are DEPRECATED - use db_cmd.pl instead
* Wed Sep 4 12:49:04 2013 +0100 | Leo Gordon | added support for -pipeline_url as an input parameter (no need to supply hive_driver or password in this case)
* Wed Sep 4 11:53:23 2013 +0100 | Leo Gordon | allow the port number to be skipped but the colon to be present
* Fri Aug 30 15:09:05 2013 +0100 | Leo Gordon | a new example pipeline designed to fail because of MEMLIMIT in some of the cases
* Tue Aug 27 12:09:20 2013 +0100 | Leo Gordon | bugfix: properly use different memory units to compute the memory req in megabytes
* Fri Aug 23 14:40:51 2013 +0100 | Leo Gordon | now performing deep-stack substitution for whatever is dataflown into tables (rather than just dataflowing the output_id)
* Fri Aug 23 12:48:20 2013 +0100 | Leo Gordon | bugfix: substituting the accu signature on demand from the very depths of emitting job's param_stack
* Fri Aug 23 10:46:46 2013 +0100 | Leo Gordon | bugfix: make sure longer input_id hashes are correctly fetched from analysis_data table in "param stack" mode
* Thu Aug 22 15:49:32 2013 +0100 | Leo Gordon | Simplified interface: now db_cmd.pl understands 'CREATE DATABASE' and 'DROP DATABASE' without parameters, given a full URL.
* Thu Aug 22 14:40:11 2013 +0100 | Leo Gordon | Can now do a mysqldump given a URL or Registry data, using a newly supported -to_params option. Note the necessity of 'eval' before 'mysqldump' (it removes quotes around the password).
* Thu Aug 22 11:13:09 2013 +0100 | Leo Gordon | bugfix: sorting by job_id should be numeric, not alphabetic
* Wed Aug 21 16:13:26 2013 +0100 | Leo Gordon | renamed db_conn.pl to db_cmd.pl to avoid the name clash with already existing term
* Wed Aug 21 15:55:46 2013 +0100 | Leo Gordon | Updated schema diagram and description file that include param_id_stack and accu_id_stack in job table.
* Wed Aug 21 14:53:11 2013 +0100 | Leo Gordon | "parameter stack" implementation using two extra fields in job table. Accu content intended for any job_id has preference over Input_id content for the same job.
* Wed Aug 21 11:34:01 2013 +0100 | Leo Gordon | store and retrieve hive_meta.'hive_use_param_stack'
* Wed Aug 21 11:31:20 2013 +0100 | Leo Gordon | cosmetic: reduce the number of synonymous calls to DBI
* Wed Aug 21 10:14:00 2013 +0100 | Leo Gordon | Dataflowing minimal information out of Runnables, relying on templates in PipeConfig file to extend it if needed
* Tue Aug 20 14:32:51 2013 +0100 | Leo Gordon | shortened connection parameters in docs

After EnsEMBL rel.73
--------------------

::

* Thu Aug 15 16:18:49 2013 +0100 | Leo Gordon | Bugfixes to pacify pgsql: changed a non-functional "HAVING" into a nested SELECT, and changed unsupported SUM() into COUNT(CASE ... )
* Thu Aug 15 16:15:28 2013 +0100 | Leo Gordon | An important comment about UNIX sockets (without a port number) vs TCPIP sockets (with a port number).
* Thu Aug 15 14:30:40 2013 +0100 | Leo Gordon | Expose parts of pipeline_db, make them less EnsEMBL-specific, allow multiple failover initializers and use self-reference if none of them worked. Phasing out $self->o('ENV', ...) expressions
* Thu Aug 15 14:27:43 2013 +0100 | Leo Gordon | Allow skipping the port number; you no longer need to define your port if you are happy with driver's default (thanks to db_conn.pl and core's DBConnection)
* Wed Aug 14 18:44:38 2013 +0100 | Leo Gordon | Registry support is now cenralised in DBAdaptor, so scripts just pass reg_* options into the constructor. Passing -reg_type allows to connect to originally non-Hive Registry entries.
* Wed Aug 14 12:58:04 2013 +0100 | Leo Gordon | make sure diagrams are generated from non-Hive registry entries as long as they are Hive-hybrids
* Wed Aug 14 10:44:29 2013 +0100 | Leo Gordon | Support extra parameters added to the client's command line
* Tue Aug 13 17:13:07 2013 +0100 | Leo Gordon | Start using the new db_conn.pl script instead of building driver-specific commands and running them.
* Tue Aug 13 17:10:45 2013 +0100 | Leo Gordon | Execute individual SQL commands as well as sessions; translate some db-meta SQLite into Bash; control verbosity
* Tue Aug 13 15:18:28 2013 +0100 | Leo Gordon | Schema change: changed the data type of monitor.analysis to TEXT as per Michael Paulini's suggestion, to fit more and longer analysis names.
* Tue Aug 13 15:14:01 2013 +0100 | Leo Gordon | Make this patch less mysql-dependent. Needs testing with PostgreSQL.
* Tue Aug 13 15:12:04 2013 +0100 | Leo Gordon | Allow multiple driver-dependent versions of the same patch; suggest schema patching with db_conn.pl commands.
* Fri Aug 9 15:46:37 2013 +0100 | Leo Gordon | concession for Bio::EnsEMBL::DBSQL::DBConnection that does not support urls
* Fri Aug 9 15:20:49 2013 +0100 | Leo Gordon | A unified dispatching client for databases. Finds the correct database client via -url or -reg_conf/-reg_alias combination.
* Fri Aug 9 15:11:09 2013 +0100 | Leo Gordon | Give a more meaningful warning if EHIVE_ROOT_DIR is not set (probably because an external script is trying to run Hive API)
* Sun Jul 28 20:47:52 2013 +0100 | Leo Gordon | bugfix: count both DONE and PASSED_ON jobs when re-balancing semaphores
* Thu Jul 11 11:30:27 2013 +0100 | Leo Gordon | included a new -nosqlvc flag in beekeeper.pl and runWorker.pl to overcome the version restriction in non-critical cases
* Thu Jul 11 11:28:58 2013 +0100 | Leo Gordon | bugfix: propagate no_sql_schema_version_check parameter through the URLFactory/DBAdaptor loop (should be re-factored at some point)
* Wed Jul 10 16:18:37 2013 +0100 | Leo Gordon | cleaned up the pipeline_create_commands a bit
* Tue Jul 9 17:15:32 2013 +0100 | Leo Gordon | the actual schema change (log_message.worker_id DEFAULT NULL)
* Tue Jul 9 17:03:08 2013 +0100 | Leo Gordon | Log all instances when a semaphore had to be re-balanced
* Tue Jul 9 17:02:04 2013 +0100 | Leo Gordon | schema change: allow recording of log_messages with worker_id=NULL
* Tue Jul 9 16:15:19 2013 +0100 | Leo Gordon | changed the interface of balance_semaphores() : pass in $filter_analysis_id instead of $filter_analysis
* Tue Jul 9 15:59:59 2013 +0100 | Leo Gordon | support selective balancing of semaphores funneling into a specific analysis
* Tue Jul 9 15:44:45 2013 +0100 | Leo Gordon | automate the re-balancing of semaphore_counts - do it when there is nothing running
* Tue Jul 9 15:38:47 2013 +0100 | Leo Gordon | introduced a new -balance option for beekeeper.pl so that semaphore_counts could be force-balanced
* Mon Jul 8 15:48:38 2013 +0100 | Leo Gordon | bugfix: back to using CONCAT -- it looks like || operator is non-standard in MySQL
* Tue Jul 2 16:17:01 2013 +0100 | Leo Gordon | start using procedures.pgsql with two main views ("progress" and "msg")
* Tue Jul 2 16:16:00 2013 +0100 | Leo Gordon | start showing resource_class in "progress" view + some SQL unification
* Tue Jul 2 13:15:37 2013 +0100 | Leo Gordon | bugfix: produce more specific bug report (either cannot connect or hive_meta unavailable)
* Tue Jul 2 12:52:30 2013 +0100 | Leo Gordon | separated the task of URL parsing out of the dba caching mechanism (needs more work)
* Mon Jul 1 12:10:44 2013 +0100 | Leo Gordon | bugfix: make sure we are getting the actual meta_value for hive_use_triggers
* Fri Jun 28 16:53:58 2013 +0100 | Leo Gordon | added 'hive_meta' to the list of tables being dumped
* Fri Jun 28 16:35:59 2013 +0100 | Leo Gordon | docs: documented the -input_id command line option
* Fri Jun 28 16:32:24 2013 +0100 | Leo Gordon | optimization: no point in catching and re-throwing my own throw!
* Fri Jun 28 16:27:09 2013 +0100 | Leo Gordon | bugfix: do not attempt to show AnalysisStats in case of an unspecialized Worker
* Fri Jun 28 11:40:31 2013 +0100 | Leo Gordon | bugfix: substituted the hard-coded value for the formula
* Thu Jun 27 16:17:48 2013 +0100 | Leo Gordon | tell the user whether to update the code to match the database SQL schema version, or which SQL patches to apply to the database
* Thu Jun 27 09:24:33 2013 +0100 | Leo Gordon | start checking Hive SQL schema version (code version against db version) and die on mismatch
* Thu Jun 27 09:19:42 2013 +0100 | Leo Gordon | bugfix: make sure we are only getting one value, not the rowhash
* Wed Jun 26 17:35:03 2013 +0100 | Leo Gordon | use SqlSchemaAdaptor to detect the current code's sql version and record it in 'hive_meta' (leave it out of tables.*sql* files)
* Wed Jun 26 17:32:22 2013 +0100 | Leo Gordon | A new "adaptor" for detection of software's sql version based on the number of available sql patches.
* Tue Jun 25 10:35:25 2013 +0100 | Leo Gordon | move Core 'schema_version' out of tables.* files into HiveGeneric_conf (via ApiVersion), expose it for manipulation and make it available to PipeConfigs
* Tue Jun 25 17:08:48 2013 +0100 | Leo Gordon | re-based MetaContainer (now it has two parents, NakedTableAdaptor is first); using the new version
* Tue Jun 25 17:04:04 2013 +0100 | Leo Gordon | new method(s) to remove objects/rows by a given condition
* Tue Jun 25 10:26:25 2013 +0100 | Leo Gordon | new 'hive_meta' table to keep hive_sql_schema_version (=number of patches), hive_pipeline_name and hive_use_triggers
* Wed Jun 26 16:55:34 2013 +0100 | Leo Gordon | Changed an 'our' global variable to ENV{EHIVE_ROOT_DIR} to allow API-only users to set it and work as usual
* Tue Jun 25 15:35:16 2013 +0100 | Miguel Pignatelli | added -hive_force_init option to documentation
* Tue Jun 25 11:11:45 2013 +0100 | Leo Gordon | bugfix: make sure users' tweaking of Data::Dumper::Maxdepth does not mess up stringify()' s operation
* Mon Jun 24 11:27:33 2013 +0100 | Leo Gordon | cosmetic: moving the sorting of keys into an external subroutine (it will be extended later)
* Mon Jun 24 11:07:25 2013 +0100 | Leo Gordon | Utils/Config.pm no longer depends on ENSEMBL_CVS_ROOT_DIR, which becomes non-essential for non-EnsEMBL applications.
* Fri Jun 21 15:54:28 2013 +0100 | Leo Gordon | bugfix: make sure fetch_all() works with empty tables
* Tue Jun 18 20:11:19 2013 +0100 | Leo Gordon | avoid deadlocks when dataflowing under transactional mode (used in Ortheus Runnable for example)
* Tue Jun 18 18:38:26 2013 +0100 | Leo Gordon | print the failed query

After EnsEMBL rel.72
--------------------

::

* Fri Jun 14 15:17:45 2013 +0100 | Leo Gordon | PostgreSQL: connection parameters are now supplied on the command line (no need to set PG variables by hand)
* Thu Jun 13 16:48:01 2013 +0100 | Leo Gordon | given -job_id Scheduler should take the Analysis into account and only submit a Worker for this Analysis
* Thu Jun 13 16:08:12 2013 +0100 | Leo Gordon | renamed some old patch files so that they would all conform to the same naming format
* Thu Jun 13 16:02:23 2013 +0100 | Leo Gordon | Adding foreign keys to PostgreSQL schema by reusing the MySQL file (the syntax happens to be exactly the same!)
* Thu Jun 13 15:50:38 2013 +0100 | Leo Gordon | Rename tables.sql to tables.mysql (less confusion)
* Thu Jun 13 15:47:15 2013 +0100 | Leo Gordon | allow the accumulated values to be longer than 255 characters
* Thu Jun 13 15:34:40 2013 +0100 | Leo Gordon | synchronized all 3 schema files
* Wed Jun 12 12:21:00 2013 +0100 | Leo Gordon | First attempt to support PostgreSQL in eHive. Use with caution.
* Mon Jun 10 17:00:31 2013 +0100 | Leo Gordon | experimental support for undef values in default_options
* Mon Jun 10 11:25:36 2013 +0100 | Leo Gordon | make sure both DatabaseDumper.pm and drop_hive_tables() know about the 'accu' table
* Mon Jun 10 09:54:38 2013 +0100 | Leo Gordon | report job_id of a created job (STDOUT) or warn that it had been created before (STDERR)
* Thu Jun 6 17:18:11 2013 +0100 | Leo Gordon | sqlite mode now also supports "-hive_force_init 1" flag
* Thu Jun 6 11:50:40 2013 +0100 | Leo Gordon | bugfix: correct destringification of a single undef on a line
* Wed Jun 5 17:11:18 2013 +0100 | Leo Gordon | Slow the example down a bit and allow 2 Workers. In "-can_respecialize 1" mode the two Workers will complete the whole pipeline.
* Wed Jun 5 17:08:33 2013 +0100 | Leo Gordon | Improved output to distinguish multiple Workers' output in the same stream
* Wed Jun 5 11:31:17 2013 +0100 | Leo Gordon | setting "-hive_force_init 1" will cause init_pipeline.pl to drop the database prior to creation (use with care!)
* Tue Jun 4 17:03:05 2013 +0100 | Leo Gordon | added support for stringification/destringification of accumulated values (an element is allowed to be a complex structure)
* Mon Jun 3 22:28:28 2013 +0100 | Leo Gordon | now supports sleeping for a floating point seconds; take_time can be given by a runtime-computed formula such as "1+rand(1)/1000"
* Mon Jun 3 14:12:27 2013 +0100 | Leo Gordon | stop complaining about undefined take_time parameter (set it to 0 by default)
* Mon Jun 3 14:05:53 2013 +0100 | Leo Gordon | Added optional sleeping functionality to Dummy runnable
* Mon Jun 3 11:46:27 2013 +0100 | Leo Gordon | a presentation introducing accumulated dataflow concept
* Sat Jun 1 21:31:34 2013 +0100 | Leo Gordon | added description attribute to Limiter class
* Thu May 30 16:01:33 2013 +0100 | Leo Gordon | bugfix: both queries modifying semaphore_count are wrapped in protected_prepare_execute
* Wed May 29 16:13:09 2013 +0100 | Leo Gordon | bugfix: allow #expr(...)expr# to be properly overriding in the templates as well
* Tue May 28 16:29:23 2013 +0100 | Leo Gordon | Simplified logic to decide whether Scheduler needs a resync. Temporarily ignore limiters and look at the number of workers initially required.
* Tue May 28 15:13:56 2013 +0100 | Leo Gordon | finally implemented LSF's version of count_running_workers() and a Valley aggregator for all visible meadows
* Tue May 28 13:09:39 2013 +0100 | Leo Gordon | bugfix: make sure specializing workers wait while their analysis is being sync'ed
* Tue May 28 12:34:51 2013 +0100 | Leo Gordon | No need to pass $total_workers_to_submit back to beekeeper anymore.
* Thu May 23 10:10:14 2013 +0100 | Leo Gordon | cosmetic: make it explicit that we are importing rearrange() and throw()
* Wed May 22 12:43:00 2013 +0100 | Leo Gordon | removed dependency on check_ref and assert_ref
* Wed May 22 11:13:38 2013 +0100 | Leo Gordon | Hive is no longer directly dependent on BioPerl
* Thu May 16 16:37:49 2013 +0100 | Leo Gordon | All Hive scripts now detect $::hive_root_dir and use it for setting the @INC so manual setting of PERL5LIB is only needed if using API directly
* Tue May 14 16:55:38 2013 +0100 | Leo Gordon | make sure beekeeper.pl runs runWorker.pl from its own scripts directory (ignore the one in the path)
* Tue May 14 16:14:47 2013 +0100 | Leo Gordon | allow the user to choose a particular hive_root_dir (esp. if there are many)
* Thu May 9 13:55:40 2013 +0100 | Leo Gordon | Copied the @-tag annotation from tables.sql to tables.sqlite. Unlike the original mysql version, the SQLite version gives no warnings when processed by sql2html.pl
* Fri May 3 14:46:03 2013 +0100 | Leo Gordon | bugfix: some farms have non-alphanumeric characters in their cluster name
* Wed May 1 11:48:23 2013 +0100 | Leo Gordon | added a new protected_prepare_execute() method to avoid deadlocks and used it twice in AnalysisJobAdaptor, to fix Stephen's deadlocks
* Wed May 1 11:46:48 2013 +0100 | Leo Gordon | moved Hive's extensions to DBConnection into a separate Hive::DBSQL::DBConnection class
* Wed May 1 12:03:10 2013 +0100 | Leo Gordon | added a patch to add 'accu' table to an existing database & fixed sqlite schema
* Tue Apr 30 13:12:33 2013 +0100 | Leo Gordon | updated schema documentation to reflect addition of 'accu' table
* Tue Apr 30 12:48:09 2013 +0100 | Leo Gordon | added support to generate_graph.pl to show accumulated dataflow on the diagram
* Tue Apr 30 11:38:44 2013 +0100 | Leo Gordon | bugfix: do not crash on encountering accumulated dataflow (just ignore it for the moment); work correctly in DisplayStretched mode
* Mon Apr 29 17:12:17 2013 +0100 | Leo Gordon | Modified the LongMult example to use accumulated dataflow
* Mon Apr 29 17:07:56 2013 +0100 | Leo Gordon | added schema & API support for accumulated dataflow
* Tue Apr 23 15:35:35 2013 +0100 | Leo Gordon | changed schema version to 72

Before EnsEMBL rel.72
---------------------

::

* Tue Apr 23 14:50:55 2013 +0100 | Leo Gordon | bugfix: only create 'default' resource_class if it was not actually stored in the database
* Tue Apr 23 13:08:44 2013 +0100 | Leo Gordon | bugfix: check before storing rc (may be necessary in -analysis_topup mode) and warn about consequences of redefining it.
* Tue Apr 23 13:05:37 2013 +0100 | Leo Gordon | API extension: store() now also returns how many actual store operations (as opposed to fetching of already stored ones) it has performed
* Fri Apr 12 16:43:19 2013 +0100 | Leo Gordon | tables.sql was made compatible with Core/Production sql2html.pl and the result is kept in docs/
* Mon Apr 8 12:20:29 2013 +0100 | Miguel Pignatelli [prf1] | Runtime is recorded for failing jobs
* Wed Mar 27 12:16:35 2013 +0000 | Javier Herrero | Added 22 Feb 2013 eHive workshop slides and examples to docs/presentation/
* Tue Mar 26 15:40:19 2013 +0000 | Leo Gordon | Make sure we do not create an analysis with non-hash parameters
* Mon Mar 25 11:05:00 2013 +0000 | Leo Gordon | use param_required() calls wherever a parameter value is required
* Fri Mar 22 16:50:42 2013 +0000 | Leo Gordon | Back to num_required_workers' meaning "how many extra workers we need to add to this analysis"; fixing a scheduling bug/oversensitivity to manual change of batch_size
* Fri Mar 22 15:44:55 2013 +0000 | Leo Gordon | Moved runnable checks into a separate method Analysis::get_compiled_module_name()
* Wed Mar 20 22:44:04 2013 +0000 | Leo Gordon | Do not crash when asked to param_substitute a Regexp, but issue a warning
* Wed Mar 20 13:02:12 2013 +0000 | Leo Gordon | free 'Start' from dealing with 'a_multiplier' by using an input_id_template in PipeConfig instead; renamed 'Start' to 'DigitFactory' to reflect that
* Wed Mar 20 10:35:08 2013 +0000 | Leo Gordon | A new and friendlier README file; defines main concepts and provides contact data
* Thu Mar 14 09:15:53 2013 +0000 | Leo Gordon | bugfix: added missing quotes
* Tue Mar 12 21:45:23 2013 +0000 | Leo Gordon | A 3-analysis pipeline with almost exclusive use of #substitution#; mysql_conn() and mysql_dbname() modified to transform urls as well
* Tue Mar 12 12:06:37 2013 +0000 | Leo Gordon | Improved legend with useful commands
* Tue Mar 12 10:56:55 2013 +0000 | Leo Gordon |     The smallest Hive pipeline example possible. Just one SystemCmd-based analysis.
* Mon Mar 11 23:59:20 2013 +0000 | Leo Gordon | A cleaner example of a two-analysis pipelines with better demonstration of #substitution# and only implicit $self->o() references
* Mon Mar 11 21:13:58 2013 +0000 | Leo Gordon | moved 'go_figure_dbc()' into Utils; supplied defaults for MySQLTransfer to make it quiet
* Tue Mar 12 21:04:14 2013 +0000 | emepyc | This file is now JSON strict
* Tue Mar 12 13:50:33 2013 +0000 | Matthieu Muffato | Do not buffer the resultset (only tested with MySQL)
* Tue Mar 12 11:07:23 2013 +0000 | Matthieu Muffato | bugfix: <= instead of <
* Fri Mar 8 18:41:39 2013 +0000 | Matthieu Muffato | In "topup" mode, concurrent inserts make the row count unreliable
* Tue Mar 5 17:05:21 2013 +0000 | Leo Gordon | Protect generate_graph.pl in table-drawing mode from printing too many rows (by setting a limit in JSON config)
* Tue Mar 5 13:12:32 2013 +0000 | Leo Gordon | Protect generate_graph.pl in job-drawing mode from printing too many jobs (by setting a limit in JSON config)
* Tue Mar 5 13:10:38 2013 +0000 | Leo Gordon | extend a method in JobAdaptor to return a limited number of jobs (for use in generate_graph)
* Fri Mar 1 11:53:39 2013 +0000 | Matthieu Muffato | Fixed a memory leak in data_dbc()
* Thu Feb 28 15:41:46 2013 +0000 | Leo Gordon | cosmetic: renamed README.txt back to README to retain an unbroken history in CVS
* Thu Feb 28 15:37:42 2013 +0000 | Leo Gordon | cosmetic:  added new commits to README and renamed it Changelog; split out the old README.txt (non-Changelog part)

Before and during EnsEMBL rel.71
--------------------------------

::

* Thu Feb 28 10:12:41 2013 +0000 | Leo Gordon | avoid having beekeeper run in submitted-to-the-farm state - detect it, report and quit
* Thu Feb 28 09:47:40 2013 +0000 | Leo Gordon | param_substitution is now default everywhere, no need to call it explicitly
* Thu Feb 28 09:42:33 2013 +0000 | Leo Gordon | added param_required() and param_is_defined() interfaces to Process
* Wed Feb 27 21:34:47 2013 +0000 | Leo Gordon | bugfix: updated examples of how to use JobFactory without and with input_id_template
* Wed Feb 27 19:08:40 2013 +0000 | Leo Gordon | bugfix: changed implementation of data_dbc() to correctly compare things before caching
* Wed Feb 27 14:00:42 2013 +0000 | Leo Gordon | Clone::clone is no longer used, so dependency has been removed
* Fri Feb 22 16:55:12 2013 +0000 | Matthieu Muffato | It is more efficient to give MySQL a LIMIT clause
* Sat Feb 23 00:52:57 2013 +0000 | Leo Gordon | JobFactory uses $overriding_hash to create jobs/rows from input_id_template; 'input_id' parameter deprecated; standaloneJob supports templates.
* Sat Feb 23 00:49:15 2013 +0000 | Leo Gordon | Substitution machinery now supports an extra $overriding_hash that contains parameters with higher precedence than the whole of param() structure
* Fri Feb 22 16:36:19 2013 +0000 | Leo Gordon | fixed several problems with parameter substitution and detection of undefs; added param_required() and param_is_defined()
* Fri Feb 22 10:42:51 2013 +0000 | Leo Gordon | reload the cached data_dbc() value on change of param('db_conn')
* Thu Feb 21 16:14:35 2013 +0000 | emepyc | The modules of the analyses must be accessible
* Fri Feb 15 17:05:20 2013 +0000 | Matthieu Muffato | New runnable to check the size of the resultset of any SQL query
* Tue Feb 19 17:18:06 2013 +0000 | Leo Gordon | removed param_substitute() call from Runnables -- no longer needed, as substitution is automatic
* Tue Feb 19 16:46:05 2013 +0000 | Leo Gordon | a "total" (anything-to-anything) substitution mechanism has been implemented in Hive::Params
* Fri Feb 15 17:04:36 2013 +0000 | Matthieu Muffato | The preferred meadow type must be registered
* Fri Feb 15 17:03:24 2013 +0000 | Matthieu Muffato | The modules of the analysis must be loadable
* Fri Feb 15 17:01:27 2013 +0000 | Matthieu Muffato | In dataflow rules within the same database, the destination analysis must exist
* Fri Feb 15 17:00:38 2013 +0000 | Matthieu Muffato | In control rules within the same database, the condition analysis must exist
* Fri Feb 15 22:25:39 2013 +0000 | Leo Gordon | make sure all LSF pids are quoted, to protect them from tcsh interpretation of square brackets
* Thu Feb 14 16:41:49 2013 +0000 | Leo Gordon | a new script to remove old "DONE" jobs and associated job_file and log_message entries
* Thu Feb 14 10:45:26 2013 +0000 | Leo Gordon | seed_pipeline.pl now shows examples of input_ids of seedable analyses
* Thu Feb 14 09:54:00 2013 +0000 | Leo Gordon | Made $final_clause a parameter of _generic_fetch() & removed default ORDER-BY; hopefully faster
* Wed Feb 13 17:20:14 2013 +0000 | Leo Gordon | In case no -logic_name/-analysis_id was supplied, show the list of analyses that have no incoming dataflow (and so are candidates for seeding)
* Wed Feb 13 13:52:56 2013 +0000 | Leo Gordon | Added perldoc to seed_pipeline.pl script
* Wed Feb 13 13:35:55 2013 +0000 | Leo Gordon | A new script to quickly seed any analysis of any pipeline.
* Wed Feb 13 10:19:08 2013 +0000 | Leo Gordon | hide the calls to URLFactory into the DBAdaptor's constructor
* Tue Feb 12 10:22:02 2013 +0000 | Leo Gordon | hash of resources no longer depends on default_meadow (bugfix)
* Thu Feb 7 11:42:11 2013 +0000 | Kathryn Beal | Updated to release 71
* Wed Feb 6 17:43:21 2013 +0000 | Matthieu Muffato | Tables must be in the right order. Otherwise, the foreign key checks complain
* Fri Jan 25 19:42:28 2013 +0000 | Leo Gordon | resolving conflict: using mine
* Tue Jan 15 11:03:26 2013 +0000 | Matthieu Muffato | Table dataflows are now included into semaphore boxes (bugfix: wrong internal name)
* Fri Jan 25 19:26:36 2013 +0000 | Leo Gordon | diagram improvement: (1) no more "empty boxes" and (2) tables dataflown from a box are shown in their boxes
* Mon Jan 14 13:23:52 2013 +0000 | Leo Gordon | Added a new presentation, moved presentations into a separate folder.
* Fri Jan 11 11:19:11 2013 +0000 | Leo Gordon | cosmetic fix: commented back the debug output that was left uncommented by mistake
* Fri Jan 11 11:07:47 2013 +0000 | Leo Gordon | Added coloured barchart display option and jobs/data display option (no big data checks, use with care on small examples). 'Pad' is now configurable from JSON. Beware: JSON config options have moved around!
* Thu Jan 10 16:14:06 2013 +0000 | Leo Gordon | injected a padding around the pipeline diagram
* Fri Jan 4 17:03:14 2013 +0000 | Leo Gordon | send the fatal "COULDNT CREATE WORKER" message to stderr instead of stdout
* Fri Jan 4 15:10:47 2013 +0000 | Leo Gordon | added command line options -submit_stdout_file and -submit_stderr_file to peek into submission output/error streams
* Fri Jan 4 14:51:35 2013 +0000 | Leo Gordon | using PERLs File::Path::make_path instead of mkdir-p to create hive_log_dir
* Fri Jan 4 11:03:31 2013 +0000 | Leo Gordon | added a LongMult pipeline diagram in completed state (for easier reference)
* Mon Dec 17 12:13:43 2012 +0000 | Leo Gordon | fixed a bug in computing num_required_workers according to the new rules (thanks Matthieu for reporting)
* Wed Dec 12 14:41:16 2012 +0000 | Leo Gordon | bugfix: correctly checking analysis_capacity (thanks Andy for reporting)
* Wed Dec 12 10:44:01 2012 +0000 | Leo Gordon | bugfix: do not proceed with negative numbers of workers for submission (thanks to Matthieu for reporting)
* Thu Dec 6 11:18:59 2012 +0000 | Leo Gordon | bugfix:  -job_limit now works correctly also with respecializing workers
* Thu Dec 6 10:47:07 2012 +0000 | Leo Gordon | fix: 'msg' view now displays the analysis of the job (which is fixed), not that of worker (which may change with time)
* Wed Dec 5 22:25:35 2012 +0000 | Leo Gordon | experimental feature: re-specialization of workers instead of dying from NO_WORK
* Sat Dec 1 19:11:56 2012 +0000 | Leo Gordon | switched to using Limiter class for job_limit and made some related structural changes
* Fri Nov 30 13:47:42 2012 +0000 | Leo Gordon | changed the meaning of 'num_required_workers' to "total estimated number of workers needed for this analysis" ( 'num_running_workers' is now included in it )
* Thu Nov 29 12:21:22 2012 +0000 | Leo Gordon | fresh schema diagram
* Thu Nov 29 11:46:47 2012 +0000 | Leo Gordon | renamed 'job_message' table to 'log_message' and JobMessageAdaptor to LogMessageAdaptor everywhere
* Wed Nov 28 21:40:45 2012 +0000 | Leo Gordon | swapped hive_capacity for analysis_capacity in example PipeConfig files
* Wed Nov 28 21:30:44 2012 +0000 | Leo Gordon | change of default behaviour: hive_capacity is now off by default (=NULL); setting hive_capacity=0 or analysis_capacity=0 stops scheduling AND specialization to a particular analysis
* Wed Nov 28 13:23:48 2012 +0000 | Leo Gordon | cleanup: removed runnable(), output() and parameters() subroutines from Process as no longer used by Compara
* Wed Nov 28 12:21:37 2012 +0000 | Leo Gordon | removed the "compile_module_once" option as the only way to compile modules now is once after specialization
* Tue Nov 27 11:31:00 2012 +0000 | Leo Gordon | secutiry: make sure stringify() always produces perl-parsable structures, so that global settings of Data::Dumper do not affect its results (thanks to Uma and Matthieu for reporting)

During EnsEMBL rel.70
---------------------

::

* Fri Nov 23 14:26:53 2012 +0000 | Leo Gordon | bugifx: create meadow_capacity limiters whether or not there is a limit
* Thu Nov 22 21:26:37 2012 +0000 | Leo Gordon | added a new per-analysis "analysis_capacity" limiter for cases where users want to limit analyses independently
* Thu Nov 22 16:56:36 2012 +0000 | Leo Gordon | switch the Scheduler to using universal Limiter objects (cleaner code, more precise computation and should allow for expansion)
* Thu Nov 22 14:07:21 2012 +0000 | Leo Gordon | moved pending adjustment out of the main scheduling subroutine, which simplified the logic and improved readability
* Thu Nov 22 17:21:22 2012 +0000 | Leo Gordon | Introduced a new 'NO_ROLE' cause_of_death for failures during specialization (not so much of an error, really!)
* Fri Nov 23 11:16:12 2012 +0000 | Leo Gordon | bugfix: avoid specializing in an otherwise BLOCKED analysis that is temporarily in SYNCHING state (thanks to Kathryn for reporting)
* Wed Nov 21 12:23:11 2012 +0000 | Leo Gordon | (multi-meadow scheduler) restrict the set of analyses that a worker with a given meadow_type can specialize into
* Tue Nov 20 15:35:44 2012 +0000 | Leo Gordon | separated the Scheduler's code into a separate module (not an object yet)
* Tue Nov 20 16:57:23 2012 +0000 | Matthieu Muffato | Merge branch 'master' of git.internal.sanger.ac.uk:/repos/git/ensembl/compara/ensembl-hive
* Tue Nov 20 12:35:30 2012 +0000 | Leo Gordon | bugfix: if re-running a job that creates a semaphored group, we no longer die (thanks Miguel for reporting)
* Mon Nov 19 16:25:14 2012 +0000 | Leo Gordon | Added API and schema support for analysis_base.meadow_type / Analysis->meadow_type(), which will be NULL/undef by default
* Mon Nov 19 15:22:44 2012 +0000 | Leo Gordon | proof of concept: all structures passed into calls and back are now meadow-aware
* Fri Nov 16 13:44:01 2012 +0000 | Leo Gordon | pass complete valley-wide stats into schedule_workers without filtering
* Fri Nov 16 10:36:49 2012 +0000 | Leo Gordon | aggregate meadow stats collection in the Valley
* Mon Nov 19 22:16:26 2012 +0000 | Matthieu Muffato | Merge branch 'master' of git.internal.sanger.ac.uk:/repos/git/ensembl/compara/ensembl-hive
* Fri Nov 16 23:27:58 2012 +0000 | Leo Gordon | turn Utils::Graph into Configurable and use the same interface to config as Meadow and Valley
* Sun Nov 18 11:59:06 2012 +0000 | Matthieu Muffato | All the combinations of parameters are tested and cover all possible cases
* Fri Nov 16 15:03:19 2012 +0000 | Leo Gordon | bugfix: no longer leaves CLAIMED jobs after compilation error during specific -job_id execution
* Fri Nov 16 14:29:48 2012 +0000 | Leo Gordon | bugfix: min_batch_time moved to prevent infinite loop in -compile_module_once 0 mode
* Fri Nov 16 12:11:01 2012 +0000 | Leo Gordon | make Valley into Configurable and move SubmitWorkersMax into Valley's context, because it is more "global" than a Meadow
* Fri Nov 16 11:52:51 2012 +0000 | Leo Gordon | concentrate the "Configurable" functionality in one class with the intention to use it wider
* Fri Nov 16 10:48:01 2012 +0000 | Leo Gordon | meadow->signature() is slightly more useful than meadow->toString()
* Thu Nov 15 12:08:11 2012 +0000 | Leo Gordon | removed PendingAdjust option from beekeeper and config file as it never really needs to be unset
* Thu Nov 15 10:37:01 2012 +0000 | Leo Gordon | simplification of the interface: scripts no longer understand --user/--password/--host/--port/--database and require --url instead
* Tue Nov 13 15:19:29 2012 +0000 | Leo Gordon | capture Worker's death message during the new 'SPECIALIZATION' status in job_message/msg (thanks, Thomas!)
* Tue Nov 13 13:07:26 2012 +0000 | Leo Gordon | bugfix: msg view should behave when analysis_id is still NULL
* Tue Nov 13 11:06:01 2012 +0000 | Leo Gordon | feature: jobless workers will now leave module compilation errors in the job_message table (thanks, Kathryn!)

Before EnsEMBL rel.70
---------------------

::

* Mon Nov 12 14:15:40 2012 +0000 | Leo Gordon | updated the release number to 70 in the schema
* Fri Nov 9 13:59:24 2012 +0000 | Leo Gordon | bugfix: worker.log_dir varchar(80) was too limiting, now extended to varchar(255); (thanks, Kathryn!)
* Fri Nov 9 12:05:28 2012 +0000 | Leo Gordon | bugfix: make sure we release claimed jobs from a manually-run worker whose Runnable fails at compilation (thanks, Miguel!)
* Thu Nov 8 10:50:51 2012 +0000 | Leo Gordon | job_count_breakout now also returns the components that go into the breakout_label
* Tue Nov 6 12:55:26 2012 +0000 | Leo Gordon | bugfix: now works on patched schema too
* Tue Nov 6 12:52:34 2012 +0000 | Leo Gordon | substituted fetch_all_failed_jobs() by a more versatile fetch_all_by_analysis_id_status()
* Tue Nov 6 12:23:45 2012 +0000 | Leo Gordon | move job_count_breakout code into AnalysisStats to be called centrally
* Fri Nov 2 14:23:13 2012 +0000 | Leo Gordon | quote and env-substitute runWorker.pl's -url commandline parameter
* Fri Nov 2 15:14:57 2012 +0000 | Leo Gordon | parametrically slow down the LongMult test pipeline using -take_time global parameter
* Fri Nov 2 10:03:39 2012 +0000 | Leo Gordon | cosmetic: removed CVS magic $_Revision and $_Author variables that cause CVS out of sync with Git
* Fri Nov 2 09:59:09 2012 +0000 | Leo Gordon | cosmetic: added a short summary of Git commits to Changelog for CVS-only users
* Thu Nov 1 15:59:55 2012 +0000 | Leo Gordon | bugfix: query in Q::fetch_all_dead_workers_with_jobs() has to reference worker table by its full name
* Thu Nov 1 15:31:36 2012 +0000 | Leo Gordon | clearer display of job_counters in beekeeper's output
* Thu Nov 1 15:16:08 2012 +0000 | Leo Gordon | clearer display of job_counters on the graph; removed misleading and unused remaining_job_count() and cpu_minutes_remaining()
* Thu Nov 1 14:33:42 2012 +0000 | Leo Gordon | Merge branch 'bugfix_greedy_grep'
* Thu Nov 1 12:05:35 2012 +0000 | Leo Gordon | avoid grepping out lines by patterns potentially present in job_name_prefix
* Thu Nov 1 12:00:00 2012 +0000 | Leo Gordon | bugfix: only limit buried-in-haste workers to really dead ones
* Wed Oct 31 13:22:46 2012 +0000 | Leo Gordon | fixing permissions of all files in one go
* Wed Oct 31 13:19:14 2012 +0000 | Leo Gordon | Do not expose the password in workers' url by storing it in an environment variable

After EnsEMBL rel.69
--------------------

2012-10-19 15:45  lg4

	* sql/tables.sql: better match heavy queries with indices on job
	  table

2012-10-19 15:43  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm, DBSQL/AnalysisJobAdaptor.pm:
	  merge reset_and_grab into one subroutine; pre-increment dependent
	  semaphore if re-running a DONE job; use -force flag for
	  force-running an individual job

2012-10-19 15:40  lg4

	* scripts/beekeeper.pl: propagation of -force flag through
	  beekeeper.pl

2012-10-17 12:55  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm, Worker.pm,
	  DBSQL/AnalysisJobAdaptor.pm: moved special-job-reset and
	  special-job-reclaim into the same call, removed the unnecessary
	  fetch in between

2012-10-16 12:37  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: cosmetic
	  changes

2012-10-16 10:42  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm, scripts/beekeeper.pl: try not
	  to shock the Q::register_worker_death() code with inexistent
	  W->analysis_id

2012-10-16 10:26  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm, scripts/runWorker.pl: moved
	  specializaton call into W::run, so that death messages during
	  specialization could be recorded in W->log_dir

2012-10-15 16:06  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm: print the resource_class_id
	  of the worker

2012-10-15 16:04  lg4

	* scripts/beekeeper.pl: pass either rc_name or logic_name or job_id
	  from beekeeper.pl to runWorker.pl

2012-10-15 10:44  mm14

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: bugfix:
	  $analysis instead of $self->analysis

2012-10-15 10:42  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm: set compile_module_once=1 as
	  default

2012-10-13 12:31  lg4

	* modules/Bio/EnsEMBL/Hive/: URLFactory.pm,
	  PipeConfig/HiveGeneric_conf.pm: allow database names to contain
	  dashes

2012-10-13 11:02  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm, scripts/runWorker.pl,
	  sql/patch_2012-10-13.sql, sql/tables.sql, sql/tables.sqlite: if
	  runWorker.pl is run manually, rc_name may stay NULL in the
	  database

2012-10-12 21:24  lg4

	* docs/: hive_schema.mwb, hive_schema.png: updated schema diagram
	  with worker.resource_class_id

2012-10-12 17:15  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm, scripts/runWorker.pl,
	  sql/foreign_keys.mysql, sql/patch_2012-10-12.sql, sql/tables.sql,
	  sql/tables.sqlite: separating create_new_worker() from
	  specialize_new_worker()

2012-10-11 12:37  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm,
	  sql/triggers.mysql, sql/triggers.sqlite: proper counting of
	  semaphored jobs by triggers and in constructor

2012-10-10 14:45  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm, scripts/runWorker.pl:
	  refactoring of the Q::create_new_worker() and introduction of
	  -force flag

2012-10-10 14:36  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm: we should
	  not leave SYNCHING analysis out (especially if there are not too
	  many READY analyses)

2012-10-10 14:34  lg4

	* modules/Bio/EnsEMBL/Hive/RunnableDB/LongMult/PartMultiply.pm:
	  slow things down a little

2012-10-09 10:48  lg4

	* docs/hive_schema.mwb, docs/hive_schema.png,
	  sql/foreign_keys.mysql: added a DF-to-DF foreign key and
	  refreshed the diagram

2012-10-09 10:25  lg4

	* sql/tables.sqlite: bugfix: forgot to add semaphored_job_count to
	  SQLite schema, now included

2012-10-09 10:22  lg4

	* sql/: patch_2012-10-08.sql, tables.sql, tables.sqlite: turned two
	  unique keys into primary keys (needed by BaseAdaptor)

2012-10-08 16:06  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm: allow the
	  batch_size to be updated via
	  $analysis_stats_adaptor->update($stats);

2012-10-08 12:17  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm, scripts/runWorker.pl: removed
	  the input_id functionality from runWorker as both redundant
	  (standaloneJob) and probably not working

2012-10-08 12:13  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: those
	  "return" statements would have never worked anyway, so I removed
	  them

2012-10-05 16:14  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: extend the
	  param_init() of the garbage-collected jobs to include
	  analysis->parameters() for template substitution (still limited!)

2012-10-05 14:14  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm, sql/patch_2012-10-06.sql,
	  sql/tables.sql, sql/tables.sqlite: cause_of_death="" no longer
	  used for decision making, cause_of_death IS NULL by default and
	  FATALITY renamed UNKNOWN for clarity

2012-10-05 10:09  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm: fetch_failed_workers() is
	  dropped as no longer used, get_hive_current_load() cosmetically
	  touched

2012-10-04 16:47  lg4

	* modules/Bio/EnsEMBL/Hive/AnalysisStats.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  sql/patch_2012-10-05.sql, sql/tables.sql, sql/tables.sqlite:
	  EMPTY state added and definitions of READY and WORKING made more
	  intuitive

2012-10-04 15:45  lg4

	* modules/Bio/EnsEMBL/Hive/AnalysisStats.pm: bugfix: a typo

2012-10-04 15:39  lg4

	* modules/Bio/EnsEMBL/Hive/AnalysisStats.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm,
	  scripts/beekeeper.pl, sql/patch_2012-10-04.sql, sql/tables.sql,
	  sql/tables.sqlite, sql/triggers.mysql, sql/triggers.sqlite:
	  introduced semaphored_job_count, renamed
	  unclaimed_job_count-->ready_job_count, changed reporting, fixed
	  hive_capacity=0

2012-10-03 14:55  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm,
	  DBSQL/AnalysisStatsAdaptor.pm: common denominator for
	  schedule_workers and specialize_new_worker

2012-10-03 14:11  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm, DBSQL/AnalysisAdaptor.pm:
	  Fetching data via AnalysisAdaptor allows to print logic_names of
	  failed analyses

2012-10-03 11:09  lg4

	* scripts/runWorker.pl: print stats if could not create worker
	  anyway, but do not sync in the end (too cryptic)

2012-10-03 10:51  lg4

	* modules/Bio/EnsEMBL/Hive/: DBSQL/AnalysisJobAdaptor.pm,
	  PipeConfig/HiveGeneric_conf.pm: renamed -input_job_id to
	  -prev_job_id to be in sync with other names

2012-10-02 16:47  lg4

	* docs/: hive_schema.mwb, hive_schema.png: updated schema diagrams

2012-10-02 16:18  lg4

	* modules/Bio/EnsEMBL/Hive/Analysis.pm,
	  modules/Bio/EnsEMBL/Hive/AnalysisStats.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  modules/Bio/EnsEMBL/Hive/Utils/Graph.pm,
	  sql/patch_2012-10-02.sql, sql/tables.sql, sql/tables.sqlite:
	  moved failed_job_tolerance, max_retry_count, can_be_empty and
	  priority columns from analysis_stats to analysis_base

2012-10-02 14:56  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: bugfix: do
	  not forget PRE_CLEANUP and POST_CLEANUP states

2012-10-02 13:00  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: bugfix:
	  changed the order of the atomic SEMAPHORED->READY state&counter
	  UPDATE so that it works as intended in SQLite as well

2012-10-02 12:17  lg4

	* sql/tables.sql: added a fake default to last_update field
	  (required by stricter MySQL setup of Vega)

2012-10-02 11:48  lg4

	* modules/Bio/EnsEMBL/Hive/AnalysisStats.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm,
	  sql/tables.sql, sql/tables.sqlite: added specific defaults into
	  analysis_stats and analysis_stats_monitor; re-ordered the fields
	  for easier navigation

2012-10-01 15:58  lg4

	* modules/Bio/EnsEMBL/Hive/: Worker.pm, DBSQL/BaseAdaptor.pm:
	  bugfix: fetch_by_dbID should work now (thanks to ChuangKee and
	  Miguel)

2012-10-01 12:53  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/BaseAdaptor.pm: bugfix:
	  primary_key_constraint now works (thanks to Miguel!)

2012-09-28 11:01  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: bugfix:
	  typo fixed, thanks to Miguel for pointing out!

2012-09-27 16:48  lg4

	* modules/Bio/EnsEMBL/Hive/: AnalysisStats.pm,
	  DBSQL/AnalysisStatsAdaptor.pm, PipeConfig/HiveGeneric_conf.pm:
	  make AnalysisStats a rearrangeable EnsEMBL-style constructor, a
	  proper store method and other preparations

2012-09-27 15:29  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm:
	  simplification of DYNAMIC hive_capacity update code

2012-09-27 12:03  lg4

	* scripts/cmd_hive.pl: retired the cmd_hive.pl script; likely not
	  working and duplicating functionality of more flexible PipeConfig

2012-09-27 10:50  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: bugfix:
	  also release jobs that were in PRE_CLEANUP or POST_CLEANUP states

2012-09-26 15:03  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm, DBSQL/BaseAdaptor.pm:
	  switched Queen to become descendent of Hive::DBSQL::ObjectAdaptor
	  and removed _generic_fetch from it

2012-09-26 12:31  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm, Worker.pm: rearranged
	  Worker's storable getters/setters, introduced and used a proper
	  rearranging new() method

2012-09-26 11:27  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm, Worker.pm: Worker doesnt
	  really need its own reference to db (can go via adaptor)

2012-09-25 16:20  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm: bugfix: GROUP BY now includes
	  a proper prefix of the index

2012-09-25 16:04  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/LongMult_conf.pm,
	  sql/patch_2012-09-25.sql, sql/tables.sql, sql/tables.sqlite:
	  Dropped 'BLOCKED' job status and introduced 'SEMAPHORED' status
	  that is maintained in sync with semaphore_counts; less confusing
	  and more efficient (with new 3-part index)

2012-09-25 12:32  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm, scripts/beekeeper.pl,
	  scripts/runWorker.pl, sql/patch_2012-09-24.sql, sql/tables.sql,
	  sql/tables.sqlite: record each Workers log_dir in the database;
	  simplified the log_dir code and renamed cmdline options
	  accordingly

2012-09-21 22:16  lg4

	* docs/hive_schema.mwb, docs/hive_schema.png,
	  modules/Bio/EnsEMBL/Hive/Analysis.pm,
	  modules/Bio/EnsEMBL/Hive/AnalysisStats.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  scripts/lsf_report.pl, sql/foreign_keys.mysql,
	  sql/patch_2012-09-21.sql, sql/tables.sql, sql/tables.sqlite:
	  moved resource_class_id from analysis_stats and
	  analysis_stats_monitor to analysis_base

2012-09-21 14:46  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/: AnalysisJobAdaptor.pm,
	  AnalysisStatsAdaptor.pm: fetch_all never seems to be executed for
	  these adaptors

2012-09-21 09:34  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow/LSF.pm: bugfix: better parsing of
	  the LSF-job-name

2012-09-20 15:56  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm,
	  DBSQL/AnalysisStatsAdaptor.pm: optimization: worker should not
	  sync analyses it is not ready to run

2012-09-20 11:51  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LOCAL.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LSF.pm, scripts/beekeeper.pl:
	  replaced internal rc_id by rc_name in the Meadow code and in most
	  of the Scheduler; needs testing

2012-09-20 11:44  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/BaseAdaptor.pm: allow JOIN to
	  appear in the constraint and act wisely - so we do not need extra
	  complicated syntax for joining

2012-09-07 11:20  lg4

	* modules/Bio/EnsEMBL/Hive/Extensions.pm: not ready yet to scrap
	  the "Runnable" support

2012-09-07 10:29  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm: (patch offered by Matthieu)
	  Allow the Job to kill the Worker even on succecss

2012-09-05 15:07  mm14

	* modules/Bio/EnsEMBL/Hive/RunnableDB/DatabaseDumper.pm: Updated
	  the list of eHive tables

2012-09-05 15:00  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm, DBSQL/AnalysisJobAdaptor.pm,
	  DBSQL/AnalysisStatsAdaptor.pm: these methods are already defined
	  in the parent class

2012-09-05 10:33  lg4

	* modules/Bio/EnsEMBL/Hive/: AnalysisStats.pm,
	  DBSQL/AnalysisJobAdaptor.pm, DBSQL/AnalysisStatsAdaptor.pm:
	  trimmed the commented-out 'use' statements

2012-09-04 17:07  lg4

	* modules/Bio/EnsEMBL/Hive/Extensions.pm: slimmed down the
	  Extensions module a bit (valuable code already moved into
	  Hive::Analysis)

2012-09-04 17:02  lg4

	* docs/hive_schema.mwb, docs/hive_schema.png,
	  modules/Bio/EnsEMBL/Hive.pm,
	  modules/Bio/EnsEMBL/Hive/Analysis.pm,
	  modules/Bio/EnsEMBL/Hive/AnalysisCtrlRule.pm,
	  modules/Bio/EnsEMBL/Hive/AnalysisStats.pm,
	  modules/Bio/EnsEMBL/Hive/DataflowRule.pm,
	  modules/Bio/EnsEMBL/Hive/Process.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/BaseAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  modules/Bio/EnsEMBL/Hive/Utils/Graph.pm, scripts/cmd_hive.pl,
	  scripts/lsf_report.pl, sql/foreign_keys.mysql,
	  sql/patch_2012-09-04.sql, sql/procedures.mysql,
	  sql/procedures.sqlite, sql/tables.sql, sql/tables.sqlite:
	  substituted the overloaded legacy 'analysis' table by a slimmer
	  'analysis_base'

2012-09-04 10:09  lg4

	* scripts/beekeeper.pl: actually switch to using rc_name in the
	  workers commandline

2012-09-03 12:26  lg4

	* scripts/beekeeper.pl: make sure beekeeper reports the same
	  scheduling plans both when it is actually scheduling and in
	  "reporting" mode

2012-09-03 12:23  lg4

	* scripts/lsf_report.pl: adding rc_name to the lsf_report

2012-09-03 12:21  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow/LOCAL.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LSF.pm, scripts/beekeeper.pl:
	  rc_name support in the beekeeper

2012-09-03 12:20  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm, scripts/runWorker.pl: rc_name
	  support in the Worker

2012-08-29 09:51  lg4

	* modules/Bio/EnsEMBL/Hive/Params.pm: a typo in perldoc

2012-08-28 10:17  lg4

	* modules/Bio/EnsEMBL/Hive/: DBSQL/BaseAdaptor.pm, Queen.pm: this
	  diagnostic information is no longer needed

2012-08-28 10:05  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm: Scheduler should explain that
	  workers are not added because of the pending ones

2012-08-27 14:10  mm14

	* modules/Bio/EnsEMBL/Hive/RunnableDB/DatabaseDumper.pm: eHive
	  tables are always included unless exclude_ehive is defined

2012-08-25 21:09  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm: make
	  sure default is in the beginning of the list

2012-08-25 10:58  mm14

	* modules/Bio/EnsEMBL/Hive/RunnableDB/DatabaseDumper.pm: Updated
	  the eHive table list + fixed typo

2012-08-24 15:49  lg4

	* modules/Bio/EnsEMBL/Hive/: AnalysisJob.pm, DataflowRule.pm,
	  Process.pm, Queen.pm, ResourceClass.pm, Worker.pm: inherit
	  Job,Worker,DFR,RC from Bio::EnsEMBL::Storable, reuse some code

2012-08-24 15:44  lg4

	* sql/tables.sql: starting the rel69...

2012-08-24 14:38  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm: bugfix: make sure there is at
	  least a number in the query (reported by Matthieu)

2012-08-23 12:01  lg4

	* modules/Bio/EnsEMBL/Hive/: ResourceClass.pm,
	  ResourceDescription.pm: renamed to_string into toString for
	  uniformity

2012-08-23 10:45  mm14

	* modules/Bio/EnsEMBL/Hive/RunnableDB/DatabaseDumper.pm: Added a
	  "skip_dump" parameter to ease the restoration of a dump

2012-08-17 15:52  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm: trying to be more careful
	  with references; release jobs' parameters earlier

2012-08-16 12:16  mm14

	* modules/Bio/EnsEMBL/Hive/RunnableDB/DatabaseDumper.pm: Can copy a
	  database to another database

2012-08-16 12:12  lg4

	* modules/Bio/EnsEMBL/Hive/: Process.pm, Worker.pm: change
	  suggested by Matthieu to avoid crashing if the temp_directory has
	  already been deleted by Runnable

2012-08-14 11:57  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  scripts/beekeeper.pl, scripts/cmd_hive.pl,
	  scripts/generate_graph.pl, scripts/runWorker.pl: switch to
	  module->new() notation everywhere, to simplify text searches

2012-08-03 16:31  lg4

	* scripts/ehive_unblock.pl: no longer used as individual jobs are
	  no longer specifically blocked

2012-08-03 16:22  lg4

	* modules/Bio/EnsEMBL/Hive/Process.pm: removed honeycomb support
	  because it is no longer used by Compara modules

2012-08-03 10:36  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/JobMessageAdaptor.pm: hopefully
	  will fix the "was not locked with LOCK TABLES" error message

Before EnsEMBL rel.69
---------------------

2012-08-01 14:23  lg4

	* scripts/: runWorker.pl, standaloneJob.pl: removed the alternative
	  "nowrite" spelling to simplify interface

2012-07-31 17:01  lg4

	* modules/Bio/EnsEMBL/Hive/Process.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm, scripts/standaloneJob.pl:
	  made it possible for a standaloneJob to provide Runnables with a
	  functional worker_temp_directory()

2012-07-31 16:15  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm: moved life_cycle() from
	  Worker.pm into Process.pm and now also calling it from
	  standaloneJob.pl (actually removed from Worker)

2012-07-31 16:13  lg4

	* modules/Bio/EnsEMBL/Hive/Process.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm, scripts/standaloneJob.pl:
	  moved life_cycle() from Worker.pm into Process.pm and now also
	  calling it from standaloneJob.pl

2012-07-25 16:30  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm: only add partial timers'
	  measurement if the job completed successfully

2012-07-24 16:48  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: if running
	  a worker with a specific job_id, the status is set to READY, but
	  the retry_count is set depending on whether PRE_CLEANUP is needed
	  or not

2012-07-24 16:17  lg4

	* modules/Bio/EnsEMBL/Hive/Process.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm,
	  modules/Bio/EnsEMBL/Hive/RunnableDB/FailureTest.pm,
	  sql/patch_2012-07-23.sql, sql/tables.sql: added two states,
	  PRE_CLEANUP (conditional) and POST_CLEANUP (unconditional) to the
	  life cycle of the Job

2012-07-23 16:49  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/RunnableDB/FailureTest.pm,
	  scripts/standaloneJob.pl, sql/patch_2012-07-22.sql,
	  sql/tables.sql, sql/tables.sqlite: At last rename GET_INPUT into
	  FETCH_INPUT for consistency between the schema and the code (it
	  seems to be harder to patch all the accumulated code)

2012-07-23 12:13  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm, scripts/beekeeper.pl,
	  scripts/runWorker.pl: added -compile_modules_once flag to test
	  the new (slightly faster and more logical) approach

2012-07-16 17:54  mm14

	* scripts/lsf_report.pl: rc_id renamed to resource_class_id

2012-07-03 12:06  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm,
	  scripts/beekeeper.pl: fixed reset_failed_jobs/reset_all_jobs and
	  removed remove_analysis_id

2012-06-29 14:20  lg4

	* docs/hive_schema.mwb, docs/hive_schema.png,
	  modules/Bio/EnsEMBL/Hive/AnalysisStats.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/ResourceDescription.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  scripts/beekeeper.pl, sql/foreign_keys.mysql,
	  sql/patch_2012-06-29.sql, sql/tables.sql, sql/tables.sqlite:
	  replaced rc_id by resource_class_id throughout the schema and
	  added the foreign keys on resource_class_id

2012-06-29 09:41  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm: support
	  'default' as the default resource class (if none is defined) and
	  create the 'default' rc even if not defined in PipeConfig

2012-06-27 16:17  lg4

	* modules/Bio/EnsEMBL/Hive/: AnalysisJob.pm,
	  DBSQL/AnalysisJobAdaptor.pm: simplified logic that controls how
	  semaphores are propagates (preparing for semaphore escaping rule
	  support)

2012-06-26 20:53  lg4

	* sql/tables.sql: to please MySQL Workbench (does not like boolean,
	  does not like leading newlines)

2012-06-26 17:02  mm14

	* sql/procedures.mysql: resource_description is still there

2012-06-26 16:28  mm14

	* sql/procedures.mysql: Added resource_class to the list of removed
	  tables

During EnsEMBL rel.68
---------------------

2012-06-26 12:58  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm: fixed a bug where job failed
	  in COMPILATION state were still set to DONE status

2012-06-26 11:22  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm, scripts/beekeeper.pl: slightly
	  improved output

2012-06-26 11:01  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm, scripts/beekeeper.pl: fixed
	  and cleaned up the code that outputs a list of workers

2012-06-25 16:00  lg4

	* scripts/lsf_report.pl: untested version that corrects the
	  max(dead) by one minute to include the stats on the last worker

2012-06-22 12:51  mm14

	* modules/Bio/EnsEMBL/Hive/Utils/Graph.pm: With the
	  "DisplayStretched" option on: now draws the mid-point of the
	  semaphores next to the boxes instead of under them

2012-06-22 11:51  mm14

	* scripts/lsf_report.pl: Now accepts two parameters on the command
	  line: "start_date" and "end_date"

2012-06-22 11:44  mm14

	* scripts/lsf_report.pl: bugfix: now works if the lines in the
	  bacct output do not start with a space

2012-06-19 16:12  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/: AnalysisJobAdaptor.pm,
	  AnalysisStatsAdaptor.pm: unnecessary uses

2012-06-15 16:43  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Graph.pm: making
	  _allocate_to_subgraph() a member function allows not to pass
	  $config as a parameter every time

2012-06-13 17:13  mm14

	* hive_config.json, modules/Bio/EnsEMBL/Hive/Utils/Graph.pm: Added
	  an option to duplicate the tables and include them into their
	  parent boxes in the graphical output of the pipeline

2012-06-11 12:01  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm: removed
	  commented lines

2012-06-10 10:30  mm14

	* modules/Bio/EnsEMBL/Hive/RunnableDB/DatabaseDumper.pm: Dies if
	  the db driver is not mysql + fixed a bug that prevented
	  "table_list" to be parsed

2012-06-08 20:28  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Graph.pm: group boxes based on
	  funnel rule's midpoint (more boxes)

2012-06-08 16:54  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm: fixed a
	  bug that looked like a feature

2012-06-08 15:46  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm: a
	  rc_id-less format of resource_classes() supported now; DO NOT
	  MIX!!!

2012-06-08 14:50  lg4

	* sql/tables.sqlite: updated sqlite schema: added resource_class
	  and modified resource_description

2012-06-08 14:38  lg4

	* sql/patch_2012-06-08.sql,
	  modules/Bio/EnsEMBL/Hive/ResourceDescription.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  sql/tables.sql: splitting the resource_description table into two

2012-06-08 11:41  lg4

	* modules/Bio/EnsEMBL/Hive/: ResourceClass.pm, DBSQL/DBAdaptor.pm,
	  DBSQL/ResourceClassAdaptor.pm: adding ResourceClass and
	  ResourceClassAdaptor

2012-06-08 11:03  lg4

	* scripts/beekeeper.pl: print meadow->toString instead of
	  meadow->type

2012-06-06 21:07  lg4

	* hive_config.json, modules/Bio/EnsEMBL/Hive/Utils/Graph.pm:
	  reorganized the "Graph" part of the config file

2012-06-01 16:00  lg4

	* scripts/lsf_report.pl, sql/procedures.mysql: moved creation of
	  both 'lsf_report' table and 'lsf_usage' view into
	  scripts/lsf_report.pl

2012-06-01 15:40  lg4

	* sql/procedures.mysql: added an SQL view over analysis, worker and
	  lsf_report tables to show analysis-wide resource usage stats

2012-06-01 15:34  mm14

	* modules/Bio/EnsEMBL/Hive/RunnableDB/DatabaseDumper.pm: New
	  Runnable to create a snapshot of a database

2012-05-31 17:09  lg4

	* hive_config.json, modules/Bio/EnsEMBL/Hive/Meadow.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/Valley.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LOCAL.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LSF.pm, scripts/beekeeper.pl:
	  moved
	  submit_workers_max/pending_adjust/total_workers_max/meadow_options
	  into Config, but they are still configurable from BK's
	  commandline via config_set(); lots of code cleanup on the way

2012-05-31 16:09  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Config.pm: now with a setter
	  function

2012-05-31 11:51  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow/LOCAL.pm: only take the first
	  name, ignore the domain name altogether

2012-05-31 09:32  lg4

	* scripts/: beekeeper.pl, runWorker.pl: removed references to old
	  config file as obsolete

2012-05-31 09:27  lg4

	* scripts/beekeeper.pl: moved run_job_id into a separate variable
	  for clarity

2012-05-30 14:48  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Graph.pm: updated POD about
	  new()'s arguments

2012-05-30 14:38  lg4

	* hive_config.json, modules/Bio/EnsEMBL/Hive/Utils/Graph.pm:
	  SemaphoreBoxes colours moved under "Colours" section

2012-05-30 14:30  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Config.pm,
	  modules/Bio/EnsEMBL/Hive/Utils/Graph.pm,
	  scripts/generate_graph.pl: A personal ~/.hive_config.json will be
	  merged in by default (overriding system defaults)

2012-05-30 12:25  lg4

	* scripts/generate_graph.pl: removed reference to the deleted
	  Util::Graph::Config

2012-05-30 12:16  lg4

	* hive_config.json, modules/Bio/EnsEMBL/Hive/Utils/Graph.pm,
	  modules/Bio/EnsEMBL/Hive/Utils/GraphViz.pm: allow configuring
	  boxes' colourscheme/offset from hive_config.json

2012-05-30 12:00  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Graph.pm,
	  scripts/generate_graph.pl: switching to using the new
	  configuration file+parser

2012-05-30 11:58  lg4

	* hive_config.json, modules/Bio/EnsEMBL/Hive/Utils/Config.pm: a new
	  JSON-based configuration file and parser

Before EnsEMBL rel.68
---------------------

2012-05-28 16:18  lg4

	* README, modules/Bio/EnsEMBL/Hive/ResourceDescription.pm: schema
	  change to allow any short string for meadow_type

2012-05-28 14:10  lg4

	* sql/: patch_2012-05-28.sql, tables.sql: schema change to allow
	  any short string for meadow_type

2012-05-23 15:27  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm: a Valley-wide (potentially
	  multi-meadow) garbage collector

2012-05-23 15:14  lg4

	* scripts/beekeeper.pl: bugfix:
	  schedule_workers_resync_if_necessary should now be run with a
	  $valley argument

2012-05-23 12:07  lg4

	* modules/Bio/EnsEMBL/Hive/Valley.pm, scripts/beekeeper.pl:
	  pipeline_name now gets propagated to all meadows of the Valley
	  (preparatory)

2012-05-23 11:12  lg4

	* modules/Bio/EnsEMBL/Hive/: Valley.pm, Meadow/LOCAL.pm,
	  Meadow/LSF.pm: reuse the meadow->name() method to check for
	  availability [cleanup]

2012-05-23 11:11  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm, scripts/beekeeper.pl: pass in
	  a Valley instead of the current_meadow (preparatory)

2012-05-22 17:58  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow/LOCAL.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LSF.pm, scripts/beekeeper.pl:
	  kill-worker-process-by-worker-id: simplified specific Meadow code
	  by moving general checks out of them

2012-05-22 17:54  lg4

	* modules/Bio/EnsEMBL/Hive/Valley.pm: the Meadow hash is now by
	  type, so no need to iterate to find Meadow-by-Worker

2012-05-22 13:01  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm, scripts/beekeeper.pl:
	  untangling a bit. Queen does not need to re-sync and beekeeper
	  does not need to fetch

2012-05-22 11:50  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm, scripts/beekeeper.pl:
	  simplified output interface from schedule_workers and
	  schedule_workers_resync_if_necessary

2012-05-21 22:47  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow.pm,
	  modules/Bio/EnsEMBL/Hive/Valley.pm, scripts/beekeeper.pl: valley
	  now contains available meadow objects, not classes; beekeeper
	  contains corrected algorithm for killing a worker

2012-05-18 15:12  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/Valley.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LOCAL.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LSF.pm, scripts/runWorker.pl,
	  sql/patch_2012-05-18.sql, sql/tables.sql, sql/tables.sqlite:
	  added schema and API support for meadow_name

2012-05-18 14:00  lg4

	* modules/Bio/EnsEMBL/Hive/Valley.pm: fixed a typo bug

2012-05-17 10:33  lg4

	* scripts/beekeeper.pl: rename meadow_name to meadow_type to match
	  the rest of the repository, before it is too late

2012-05-12 08:47  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow.pm,
	  modules/Bio/EnsEMBL/Hive/Valley.pm, scripts/runWorker.pl: moved
	  meadow identification code to Valley.pm

2012-05-11 16:40  lg4

	* scripts/beekeeper.pl: moved the "meadow-collection" code into a
	  separate class called "Valley"

2012-05-11 16:39  lg4

	* modules/Bio/EnsEMBL/Hive/Valley.pm: a new class to represent a
	  collection of available Meadows

2012-05-10 16:27  lg4

	* scripts/: beekeeper.pl, runWorker.pl: removed obsolete
	  -maximise_concurrency and -batch_size options from both scripts

2012-05-09 12:01  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LOCAL.pm, scripts/beekeeper.pl:
	  bugfix+feature: -local_cpus renamed into -total_workers_max and
	  so made available for any meadow (not just LOCAL). Plus some
	  renames

2012-05-08 17:50  lg4

	* scripts/beekeeper.pl: make beekeeper more Meadow-agnostic and
	  allow it to automatically find alternative Meadow modules in the
	  INC list

2012-05-08 17:49  lg4

	* modules/Bio/EnsEMBL/Hive/Meadow/: LOCAL.pm, LSF.pm: check the
	  availability of this Meadow on the given machine

2012-05-08 17:48  lg4

	* modules/Bio/EnsEMBL/Hive/Utils.pm: new function for finding all
	  modules in a "directory" across the whole INC list

2012-05-02 15:59  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/: AnalysisCtrlRuleAdaptor.pm,
	  DataflowRuleAdaptor.pm: removed create_rule() method that is no
	  longer used

2012-05-02 15:54  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm: explicit
	  new->store rules; retiring create_rule(); switch to using
	  toString()

2012-05-02 15:53  lg4

	* modules/Bio/EnsEMBL/Hive/: AnalysisCtrlRule.pm, DataflowRule.pm:
	  switch to using uniform toString() diagnostic method

2012-05-02 12:10  lg4

	* modules/Bio/EnsEMBL/Hive/: DataflowRule.pm,
	  DBSQL/DataflowRuleAdaptor.pm: move input_id_template
	  stringification into DFR class

2012-05-01 17:04  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisCtrlRuleAdaptor.pm:
	  remove_by_condition_analysis_url() is no longer used by Compara,
	  so has been removed

2012-05-01 16:37  lg4

	* modules/Bio/EnsEMBL/Hive/: Process.pm, Worker.pm: a Process does
	  not need a reference to the Queen

2012-05-01 16:30  lg4

	* modules/Bio/EnsEMBL/Hive/Extensions.pm: analyze_tables() does not
	  seem to be used anymore

2012-05-01 15:55  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm: bugfix: make sure
	  runtime_msec is stored even when a job dies

2012-05-01 10:58  lg4

	* modules/Bio/EnsEMBL/Hive/: Extensions.pm, Process.pm: no longer
	  used

2012-04-23 23:04  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Graph.pm,
	  modules/Bio/EnsEMBL/Hive/Utils/GraphViz.pm,
	  scripts/generate_graph.pl: code for showing semaphores as nested
	  boxes

After EnsEMBL rel.67
--------------------

2012-03-27 12:22  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/: AnalysisJobAdaptor.pm,
	  BaseAdaptor.pm: a typo in comments

2012-03-26 14:59  mm14

	* sql/tables.sqlite: schema_version=67

2012-03-26 14:45  mm14

	* sql/tables.sql: schema_version=67

2012-03-20 11:06  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: code
	  optimization suggested by Matthieu

2012-03-19 17:15  lg4

	* modules/Bio/EnsEMBL/Hive/: AnalysisCtrlRule.pm, AnalysisJob.pm,
	  AnalysisStats.pm, DataflowRule.pm, NakedTable.pm,
	  ResourceDescription.pm: weaken the link back from the object back
	  to the adaptor

2012-03-07 15:27  lg4

	* modules/Bio/EnsEMBL/Hive/RunnableDB/FastaFactory.pm: added
	  support for reading compressed files

2012-03-07 14:41  lg4

	* modules/Bio/EnsEMBL/Hive/: PipeConfig/FastaSplitter_conf.pm,
	  RunnableDB/FastaFactory.pm: a Bio::Seq example factory Runnable
	  and a matching PipeConfig file

2012-03-01 10:31  lg4

	* modules/Bio/EnsEMBL/Hive/Worker.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm,
	  sql/tables.sql, sql/tables.sqlite: improved STDOUT/STDERR
	  redirection into files; removal of job logs on success

2012-03-01 10:29  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/RedirectStack.pm: a special module
	  to deal with stacks of filehandle redirection

2012-02-24 15:59  lg4

	* scripts/beekeeper.pl: pass debug level parameter from
	  beekeeper.pl to runWorker.pl

2012-02-23 13:52  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/BaseAdaptor.pm: bugfix: only store
	  values that have been set - avoid overriding defaults

2012-02-20 16:04  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Graph.pm: attempt to display each
	  funnel below its fan

2012-02-16 16:39  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Graph.pm: diagram tool no longer
	  generates unnecessarily broken edges

2012-02-15 11:26  lg4

	* scripts/lsf_report.pl: restrict to DEAD workers only

2012-02-15 11:14  lg4

	* scripts/lsf_report.pl: documentation and better user interface
	  (dumping and undumping supported)

2012-02-14 16:56  lg4

	* scripts/lsf_report.pl: turned mem and swap into numeric columns;
	  careful with units!

2012-02-14 16:40  lg4

	* scripts/lsf_report.pl: post-mortem loader of worker memory usage
	  information from the LSF

2012-02-14 10:36  lg4

	* modules/Bio/EnsEMBL/Hive/DependentOptions.pm: Pipeline parameters
	  cannot take undefined values. Warn and force into 0

After EnsEMBL rel.66
--------------------

2012-01-31 10:58  lg4

	* sql/triggers.mysql: an optimization: do not touch analysis_stats
	  when job.status or job.analysis is not changing

2012-01-20 16:33  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  sql/tables.sql: changes for rel.66

2011-12-08 13:07  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/LongMult_conf.pm: checked in
	  by mistake last time; took back the changes now

2011-12-08 12:08  lg4

	* modules/Bio/EnsEMBL/Hive/AnalysisStats.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow.pm,
	  modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/Meadow/LSF.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/LongMult_conf.pm,
	  scripts/beekeeper.pl, scripts/runWorker.pl,
	  sql/patch_2011-12-08.sql, sql/tables.sql, sql/tables.sqlite,
	  sql/triggers.mysql, sql/triggers.sqlite: Removed
	  maximise_concurrency and added analysis_stats.priority to guide
	  the scheduler; improved scheduler and LSF meadow

2011-11-29 17:49  lg4

	* modules/Bio/EnsEMBL/Hive/AnalysisJob.pm,
	  modules/Bio/EnsEMBL/Hive/DataflowRule.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/DataflowRuleAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/LongMult_conf.pm,
	  modules/Bio/EnsEMBL/Hive/Utils/Graph.pm,
	  sql/patch_2011-11-29.sql, sql/tables.sql, sql/tables.sqlite: An
	  extension to the dataflow-rule-driven semaphores ('2->A', '3->A'
	  and 'A->1' notation)

2011-11-29 12:59  lg4

	* modules/Bio/EnsEMBL/Hive/RunnableDB/JobFactory.pm: removed
	  'sema_fan_branch_code' parameter since you can now set up a
	  semaphored group via PipeConfig' language

2011-11-28 09:57  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm: no need to check for
	  semaphores when state is already DONE or PASSED_ON

2011-11-28 09:57  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm: making sure
	  semaphores are correctly propagated through gc_dataflow and
	  PASSED_ON state

2011-11-25 10:22  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm: allow
	  more than one input_id_template per analysis

2011-11-24 20:12  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/DataflowRuleAdaptor.pm: bugfix:
	  funnel_branch is no longer initialized to 1 when undef

2011-11-24 20:05  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm: bugfix: correct counting of
	  total_job_number in non-trigger mode

2011-11-24 12:37  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/DataflowRuleAdaptor.pm: bugfix -
	  branch_name_2_code should return 1 on undef

2011-11-23 17:05  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/: Graph.pm, Graph/Config.pm: show
	  the dataflow-generated semaphores on the diagram

2011-11-23 15:52  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/: BaseAdaptor.pm,
	  ObjectAdaptor.pm: bugfix: object adaptor now correctly
	  reconstructs dbID

2011-11-23 12:23  lg4

	* modules/Bio/EnsEMBL/Hive/: PipeConfig/LongMult_conf.pm,
	  PipeConfig/SemaLongMult_conf.pm, RunnableDB/LongMult/README,
	  RunnableDB/LongMult/SemaStart.pm: merge the two ways of running
	  the LongMult pipeline into one

2011-11-23 11:57  lg4

	* modules/Bio/EnsEMBL/Hive/AnalysisJob.pm,
	  modules/Bio/EnsEMBL/Hive/DataflowRule.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisJobAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/DataflowRuleAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/LongMult_conf.pm,
	  sql/patch_2011-11-23.sql, sql/tables.sql, sql/tables.sqlite:
	  integrated semaphored fans/funnels into dataflow rules

2011-11-22 14:47  lg4

	* modules/Bio/EnsEMBL/Hive/AnalysisStats.pm: this value was
	  returned but never used

2011-11-21 16:44  lg4

	* modules/Bio/EnsEMBL/Hive/: AnalysisStats.pm, Queen.pm, Worker.pm,
	  DBSQL/AnalysisJobAdaptor.pm: remove the per-worker batch_size
	  method

2011-11-21 16:40  lg4

	* scripts/: beekeeper.pl, runWorker.pl: remove the per-worker
	  batch_size flag from scripts

2011-11-17 14:56  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm,
	  modules/Bio/EnsEMBL/Hive/Worker.pm,
	  modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm,
	  sql/triggers.mysql, sql/triggers.sqlite: make num_running_workers
	  updatable by triggers + better updates during worker check-in

2011-11-10 14:30  lg4

	* modules/Bio/EnsEMBL/Hive/: AnalysisStats.pm,
	  DBSQL/AnalysisStatsAdaptor.pm: these four methods were neither
	  used by Hive nor by Compara code

2011-11-04 12:05  lg4

	* docs/eHive_install_usage.txt,
	  modules/Bio/EnsEMBL/Hive/DBSQL/BaseAdaptor.pm: DBI with versions
	  older than 1.6 are not supported

2011-10-19 09:54  db8

	* modules/Bio/EnsEMBL/Hive/Meadow/LSF.pm, scripts/beekeeper.pl:
	  WGA/Projection used for CHIMP2.1.4

2011-10-15 10:20  lg4

	* sql/: tables.sql, tables.sqlite: release 65

2011-09-23 11:53  lg4

	*
	  modules/Bio/EnsEMBL/Hive/PipeConfig/RunListOfCommandsOnFarm_conf.pm:
	  An example pipeline that turns lines of a file into jobs and runs
	  them on the farm

2011-09-20 21:15  lg4

	* modules/Bio/EnsEMBL/Hive/Process.pm: extend for other schema
	  types

2011-09-09 09:57  lg4

	* sql/tables.sql: analysis_data may be overcrowded with inserts
	  during dataflow with input_id longer than 255 characters

2011-09-05 17:18  lg4

	* docs/long_mult_example_pipeline.txt: couple of typos

2011-09-05 16:50  lg4

	* docs/eHive_install_usage.txt: checkout seems to work better than
	  export

2011-09-01 16:12  lg4

	* modules/Bio/EnsEMBL/Hive/: DependentOptions.pm,
	  PipeConfig/ApplyToDatabases_conf.pm,
	  PipeConfig/FailureTest_conf.pm,
	  PipeConfig/FileZipperUnzipper_conf.pm,
	  PipeConfig/HiveGeneric_conf.pm, PipeConfig/LongMult_conf.pm,
	  PipeConfig/SemaLongMult_conf.pm,
	  PipeConfig/TableDumperZipper_conf.pm: Incorporate ENV hash into
	  the tree of possible options in order to be able to "require" a
	  value. And a bit of config inheritance cleanup.

2011-08-25 20:37  lg4

	* modules/Bio/EnsEMBL/Hive/: Process.pm, RunnableDB/JobFactory.pm,
	  RunnableDB/MySQLTransfer.pm, RunnableDB/SqlCmd.pm,
	  RunnableDB/SystemCmd.pm: Switching from DBI to DBConnection;
	  data_dbc() as the main focus point; standaloneJob.pl examples of
	  basic building blocks

2011-08-18 15:28  lg4

	* modules/Bio/EnsEMBL/Hive/RunnableDB/: JobFactory.pm, SqlCmd.pm,
	  SystemCmd.pm: show query/cmd/filename when debug is on

2011-08-18 15:23  lg4

	* modules/Bio/EnsEMBL/Hive/Utils/Graph.pm: sqlite databases do not
	  have a host name, so nothing to display here

2011-08-15 10:58  lg4

	* sql/: tables.sql, tables.sqlite: the schema did not allow more
	  than one job_message per second from one attempt. This limitation
	  has been removed

2011-07-26 17:35  lg4

	* modules/Bio/EnsEMBL/Hive/AnalysisJob.pm: allow standalone jobs to
	  emit warnings

2011-07-26 11:45  lg4

	* sql/: tables.sql, tables.sqlite: for the production of rel.64

2011-07-20 19:40  lg4

	* sql/: triggers.mysql, triggers.sqlite: bugfix: more foolproof
	  maths in triggers

2011-07-15 16:42  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm, Worker.pm: moved Worker's
	  call to Queen->safe_synchronize_AnalysisStats into Worker.pm for
	  clarity

2011-07-15 15:13  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm: now it
	  should properly refresh data in the existing object

2011-07-15 14:59  lg4

	* modules/Bio/EnsEMBL/Hive/Queen.pm: do not update counters
	  unnecessarily

2011-07-15 14:23  lg4

	* modules/Bio/EnsEMBL/Hive/: AnalysisStats.pm, Queen.pm: formatting
	  and cleanup

2011-07-15 14:21  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/DBAdaptor.pm,
	  modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  sql/triggers.mysql, sql/triggers.sqlite: more flexible approach:
	  allows to add triggers later by simply by sourcing the triggers
	  file

2011-07-15 11:44  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm,
	  DBSQL/AnalysisStatsAdaptor.pm: perform worker counting centrally
	  in the Queen

2011-07-15 11:14  lg4

	* modules/Bio/EnsEMBL/Hive/DBSQL/AnalysisStatsAdaptor.pm: do not
	  update these fields when triggers in place

2011-07-14 15:58  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm: added a
	  new beekeeper_extra_cmdline_options() interface method for
	  passing cmdline options to beekeeper.pl/runWorker.pl

2011-07-14 15:26  lg4

	* modules/Bio/EnsEMBL/Hive/: Queen.pm, DBSQL/AnalysisJobAdaptor.pm,
	  DBSQL/AnalysisStatsAdaptor.pm, DBSQL/DBAdaptor.pm,
	  PipeConfig/HiveGeneric_conf.pm: optional (cmdline-controlled,
	  off-by-default) support of job-counting triggers

2011-07-14 12:52  lg4

	* modules/Bio/EnsEMBL/Hive/PipeConfig/HiveGeneric_conf.pm,
	  sql/foreign_keys.mysql, sql/foreign_keys.sql,
	  sql/procedures.mysql, sql/procedures.sql: renamed procedures.sql
	  and foreign_keys.sql into .mysql equivalents

2011-07-14 12:47  lg4

	* sql/: triggers.mysql, triggers.sqlite: experimental: do the job
	  counting immediately by SQL triggers rather than periodically by
	  Perl code

2011-07-13 17:24  lg4

	* modules/Bio/EnsEMBL/Hive/Params.pm, scripts/standaloneJob.pl:
	  allow automatic dataflow into tables as well

--------------------------------------------------------------------------------------------------------

13.July, 2011 : Leo

* Worker.pm bugfix : do not perform interval_update if no new jobs were done (to avoid division by zero)

8.July, 2011 : Leo

* Process.pm : do not complain on STDERR that honeycomb_dir is not defined, just return immediately

6.July, 2011 : Leo

* standaloneJob.pl : allow dataflow from it into job table (allow creation of jobs from a DB-less job)
* fixed Hive::RunnableDB::Dummy to work in DB-less mode
* standaloneJob.pl : added automatic dataflow to branch 1
* standaloneJob.pl : added more examples to the POD docs

5.July, 2011 : Leo

* destringify():  fixed a bug that prevented parsing of lists
* allow destringification of values from cmdline parser in Utils.pm
* standaloneJob.pl : allow dataflow from it into tables
* added a compara_db example (with support for compara_dba creation from URLs added to Compara code)

4.July, 2011 : Leo

* JobMessageAdaptor: be numerically strict with the value stored in boolean field
* schema, job_message table: make sure we support PASSED_ON status for jobs that undergo GarbageCollection

2.July, 2011 : Leo

* rationalized dynamic batch_size estimation: it is now done centrally both for single Workers (claiming) and the Queen (sync procedure)

1.July, 2011 : Leo

* bugfix in procedures: show count to be 0 for analyses which have no jobs

30.June, 2011 : Andy

* Old implementation of store_out_files() was generating incompatible SQL for SQLite.
  Prepared statement version developed & have removed the IGNORE component due to the delete which occurs as the first task in the method.

29.June, 2011 : Leo

* rationalized reg_conf/reg_alias names and fixed the way they are passed into runWorker and used in it

16.June, 2011 : Kieron

* POD fixes for Doxygen compatibility

15.June, 2011 : Leo

* big change in JobFactory's interface throughout Hive/Compara. We now address fields by name, not by index (well, by default).
* bugfix in DependentOptions : had to increase the number of allowed iterations to perform all necessary substitutions
* added procedures.sqlite (less powerful, but still something)

14.June, 2011 : Leo

* make dir_revhash available for param substitution

7.June, 2011 : Leo

* bugfix in BaseAdaptor : should only $sth->finish if the handle is defined

3.June, 2011 : Leo

* procedures.sql : when selecting from 'progress' view, show all analyses including the empty ones

2.June, 2011 : Leo

* better support for -analysis_topup functionality: check for multiple analysis sections with the same name in current config file

28.May, 2011 : Leo

* intelligently block dataflow from database-less jobs (and prepare for further addition of database rules)

27.May, 2011 : Leo

* dbh() as the focus point of redirectable SQL handlers (similar to compara_dba() in Compara::BaseRunnable)

26.May, 2011 : Leo

* some common subroutines (including help generation) moving out from scripts into Utils.pm
* first introduction of standaloneJobs.pl script for running jobs outside of the Hive (very basic at the moment)

25.May, 2011 : Leo

* cmd_hive.pl fixed to satisfy foreign key constraints

24.May, 2011 : Leo

* branch names functionality stays, but removed from examples as confusing to the users

23.May, 2011 : Leo

* trying to fix the monitor
* DependentOptions: a module only dedicated to parsing of dependent options (about half of HiveGeneric_conf functionality)
* bugfix in Meadow::LSF - correct parsing of bacct output in non-jobarray cases (long-standing)

21.May, 2011 : Leo

* fixed a bug in AnalysisJobAdaptor that prevented the Hive from claiming non-virgin jobs (introduced during sqlite updates)

20.May, 2011 : Leo

* show analysis_id and done_jobs in Utils::Graph
* removed excess diagnostic messages from generate_graph.pl
* removed excess checks from generate_graph.pl - let's assume the user knows what he is doing
* removed unused ProcessWithParams module

19.May, 2011 : Leo

* looking for a better way to set hive_driver, put it into HiveGeneric_conf and LongMult_conf as an example. Still hacky.
* Adaptors: allow autoincrement fields to be specified in the BaseAdaptor
* Adaptors: attempt to store all columns, including the autoincrement

12.May, 2011 : Leo

* removal of tables in procedures.sql now takes into account the foreign keys (so does it in the right order)
* using DBI-provided methods for unification of the mysql/sqlite-related code, suggested by Andy
* small changes related to production of release_63 (schema_version etc).

11.May, 2011 : Leo

* bugfix: better parsing of "ps" output on MacOSX
* (investigative) trying to find a better way to escape complex delimiters in JobFactory, then abandoned it

10.May, 2011 : Leo

* unification of the mysql/sqlite-related code, suggested by Andy

9.May, 2011 : Leo

* added experimental support of sqlite engine throughout the Hive
* removed dependency from DBI of several scripts (it was redundant)
* fixed a typo in AnalysisData adaptor
* made sure docs (as well as the code) refer to ENSEMBL_CVS_ROOT_DIR

5.May, 2011 : Leo

* stopped providing encode_hash() to encourage using stringify() instead (Compara code has been patched already)

3.May, 2011 : Andy

* importing of Config into Utils::Graph

19.Apr, 2011 : Leo

* another rename in Queen module
* removed analysis_id and logic_name from the basic job_message table to minimize dependences.
    I expect people to use the more informative 'msg' view anyway.

18.Apr, 2011 : Leo

* new schema drawings in docs
* updated version of adaptors' class hierarchy

14.Apr, 2011 : Leo

* using a new BaseAdaptor as the base class for some simpler adaptors
* RunnableDB::LongMult::SemaStart now shows how to use $self->warning for recording non-fatal messages into job_message tbl.
* Hive::PipeConfig modules will now universally be using ENSEMBL_CVS_ROOT_DIR environment variable

13.Apr, 2011 : Leo

* big schema rename: hive->worker, analysis_job->job, analysis_job_file->job_file, analysis_job_id->job_id,
                worker.beekeeper->worker.meadow_type, etc

--------------------------------------------------------------------------------------------------------

30.Mar, 2011 : Leo

* fixed a bug when checking for definedness of branch_name in DataflowRuleAdaptor.pm

29.Mar, 2011 : Leo

* fixed a bug in MySQLTransfer.pm where it never reached automatic dataflow on success
* fixed Process.pm to not import warning() to avoid clashing with ensembl-core's warning

26.Mar-11.Apr, 2011 : Leo

* trying to enforce the 'fetch_by' and 'fetch_all_by' convention for adaptor calls

24.Mar, 2011 : Leo

* some branches can be named instead of numbered (-2, -1, 0, 1)
    and 0 now stands for 'ANYFAILURE' (please use with extreme care!)

23.Mar, 2011 : Leo

* sql/procedures.sql gives timing in minutes as well

18.Mar, 2011 : Leo

* one PREPARE statement per dataflow-to-table call (so works for array of output_ids with identical structure)

16.Mar, 2011 : Leo

* Reviewed some procedures.sql adding a procedure for timing and several tricks suggested by Greg.

10-12.Mar, 2011 : Andy

* Introduced a new script for "off-line" creation of pipeline diagrams based on GraphViz.
    You will have to refrain from direct creation of jobs/analyses/rules in your pipeline
    and do dataflow instead to benefit from the drawing.

9.Mar, 2011 : Leo

* Tried a new debugging trick (dumping the Hive database at key steps in the pipeline)
    and documented it in SystemCmd.pm module.

2.Mar, 2011 : Leo

* -keep_alive option added to the Beekeeper to allow it to loop even when all jobs are done.
    Requested by Bethan for tracking Blast jobs submitted from the web.

1.Feb, 2011 : Miguel 

* fixed init_pipeline.pl that was not propagating an error message from importing a PipeConfig module

27.Jan, 2011 : Leo

* Beekeeper will warn if a pipeline doesn't have a name defined
    (to avoid clashes with other unnamed pipelines on the farm).

21.Jan, 2011 : Leo

* Foreign key constraints have been moved into a separate .sql file,
    to allow the user to switch them all off.

19-20.Jan, 2011 : Leo

* An analysis can now be empty for blocking purposes (blocks only while it contains undone jobs).
    This allows creating more flexible pipelines (that have branches that may never execute, but will not block the rest).

19.Jan, 2011 : Leo

* AnalysisJobAdaptor now retries 3 times to avoid deadlock situations when claiming jobs (may need further attn)

14.Jan, 2011 : Leo

* several textual fields in the schema extended to take longer strings

12.Jan, 2011 : Leo

* MySQLTransfer can now param_substitute()

10-21.Jan, 2011 : Leo

* fixed an issue with $self->o() mechanism in lists (incomplete substitutions).

4-5.Jan, 2011 : Leo

* fixed multiple issues that appeared after introduction of the foreign keys
  but only became visible after some testing (thanks to Gautier for extra testing!).

31.Dec, 2010 : Leo Gordon

* Inplemented the long-standing plan to remove the schema/code dependency on UUIDs.
  Removed the job_claim field from the schema and the code, changed the way jobs are claimed.

28.Dec, 2010 : Leo Gordon

* Updated schema drawings that contain newly added foreign keys

21-23.Dec, 2010 : Leo Gordon

* Added foreign key constraints, figured out that foreign keys ARE enforced in MySQL 5.1.47,
  so had to fix some code (and some ensembl-compara code as well, so keep yours up-to-date).

14.Dec, 2010 : Leo Gordon

* first attempt at creating schema drawings using MySQL Workbench. Drawings added to docs/ .
  A lot of foreign key constraints were missing, which influenced the drawing.
  If they are not enforced by MySQL anyway, why not add just them?

26.Nov, 2010 : Leo Gordon

* changed JobFactory so that parts of it can be re-used by subclassing. Examples in ensembl-compara.

26.Oct, 2010 : Leo Gordon

* fixed a long-standing bug: input_id was supposed to be able to set things (according to compara code)

19-22.Oct, 2010 : Leo Gordon

* Fixed both rule adaptors and the HiveGeneric_conf to prevent them from creating duplicated rules
  when a PipeConfig is re-run.

8.Oct, 2010 : Leo Gordon

A new MySQLTransfer.pm Hive Runnable to copy tables over (an amazingly popular task in our pipelines).
Does an integrity check and fails if underlying mysqldump fails.

1.Oct, 2010 : Leo Gordon

* runWorker.pl only prints the worker once per stream.
  So if output is redirected to a file, both the file and the output will contain it.

30.Sept-19.Oct, 2010 : Leo Gordon

* detected a strange behaviour of a Worker that was running a RunnableDB
  with 'runaway next' statements. Since it was not possible to fix it (seems to be Perl language issue),
  the Worker's code does its best to detect this and exit. Please check that your RunnableDBs do not have runaway nexts.

------------------------------------[previous 'stable' tag]----------------------------------

21-22 Sept, 2010 : Leo Gordon

* a new switch -worker_output_dir allows a particular worker to send its stdout/stderr into the given directory
    bypassing the -hive_output_dir if specified.

* streamlining runWorker.pl-Queen.pm communication so that runWorker.pl is now a very lightweight script
    (only manages the parameters and output, but no longer runs actual unique functionality)

20 Sept, 2010 : Leo Gordon

* big change: added gc_dataflow (jobs dying because of MEMLIMIT or RUNLIMIT can now be automatically sent
    to another analysis with more memory or longer runtime limit. Schema change + multiple code changes.

16 Sept, 2010 : Leo Gordon

* code cleanup and unification of parameter names (older names still supported but not encouraged)

13-14 Sept, 2010 : Leo Gordon

* big change: creating a separate Params class, making it a base class for AnalysisJob,
  and removing parameter parsing/reading/setting functionality from the Process. No need in ProcessWithParams now.
  This is a big preparation for post-mortem dataflow for resource-overusing jobs.

11 Sept, 2010 : Leo Gordon

* schema change: we are producing release 60!

* bugfix: -alldead did not set 'cause_of_death', now it always sets 'FATALITY' (should we invoke proper GarbageCollection?)

7-9 Sept, 2010 : Leo Gordon

* autoflow() should be a property of a job, not the process. Moved and optimized.

* avoiding filename/pid collisions in Worker::worker_temp_directory, improved reliability.

* removed some Extensions by creating proper hive adaptors (AnalysisAdaptor and MetaContainer)

* changed the way a RunnableDB declares its module defaults. NB!

2-3 Sept, 2010 : Leo Gordon

* optimizing the reliability and the time spent on finding out why LSF killed the jobs

* let MEMLIMIT jobs go into 'FAILED' state from the first attempt (don't waste time retrying)

31 Aug - 1 Sept, 2010 : Leo Gordon

* Added support for finding out WHY a worker is killed by the LSF (MEMLIMIT, RUNLIMIT, KILLED_BY_USER),
  the schema is extended to allow this information to be recorded in the 'hive' table.

24 Aug, 2010 : Leo Gordon

* experimental: Queen, Meadow, Meadow::LOCAL and Meadow::LSF changed to make it possible to run several beekeepers
  owned by different users over the same database.  They _should_not_ collide, but it has not been very thoroughly tested.

23 Aug, 2010 : Leo Gordon

* Worker now reports the reason why it decides to die + good working example (FailureTest framework)

20 Aug, 2010 : Leo Gordon

* Added a generic Stopwatch.pm module to allow for fine timing to be done in a cleaner way

* Added the ability for Runnables to throw messages (which will be recorded in 'job_error' table)
  not to be necessarily associated with the job's failure. This change involved schema change as well.

* 'job_error' table is renamed to 'job_message' with the extra field (is_error=0|1) added

13 Aug, 2010 : Javier Herrero

* scripts/cmd_hive.pl: Better support for adding new jobs to an existing analysis. Also, supports adding one single job

13 Aug, 2010 : Leo Gordon

* AnalysisJob and Worker were changed to allow jobs to decide whether it makes any sense to restart them or not.

* a command line switch -retry_throwing_jobs and a corresponding getter/setter method was added to
    beekeeper.pl, runWorker.pl and Worker.pm to let the user decide whether to restart failing jobs or not.

11-12 Aug, 2010 : Leo Gordon

* A new table 'job_error' was added to keep track of jobs' termination messages (thrown via 'throw' or 'die'),
  this involved schema change and lots of changes in the modules.

* Another big new change is that the Workers no longer die when a Job dies. At least, not by default.
  If a Worker managed to catch a dying Job, this fact is registered in the database, but the Worker keeps on taking other jobs.

9-10 Aug, 2010 : Leo Gordon

* RunnableDB::Test renamed into RunnableDB::FailureTest and extended, PipeConfig::FailureTest_conf added to drive this module.
  (this was testing ground preparation for job_error introduction)

16 July, 2010 : Leo Gordon

* added -hive_output_dir to beekeeper.pl so that it could be set/overridden from the command line

* dir_revhash is now an importable Util subroutine that is used by both Worker and JobFactory

14 July, 2010 : Leo Gordon

* fixed Meadow::LOCAL so that MacOS's ps would also be supported. eHive now runs locally on Macs :)

13 July, 2010 : Leo Gordon

* added ability to compute complex expressions while doing parameter substitution

12 July, 2010 : Leo Gordon

* added the slides of my HiveTalk_12Jul2010 into docs/

* changed the ambiguous 'output_dir' getter/setter into two methods:
    worker_output_dir (if you set it - it will output directly into the given directory) and
    hive_output_dir (if you set it, it will perform *reverse_decimal* hashing of the worker_id and create a directory for that particular worker)

2 July, 2010 : Leo Gordon

* [Bugfix] Process::dataflow_output_id() is simplified and generalized

* [Feature/experimental] ProcessWithParams::param_substitute() can now understand #stringifier:param_name# syntax,
    several stringifiers added (the syntax is not final, and the stringifiers will probably move out of the module)

* [Feature] TableDumperZipper_conf can now understand negative patterns:
    it is an example how to emulate the inexistent in MySQL 5.1 syntax "SHOW TABLES NOT LIKE "%abc%"
    my using queries from information_schema.tables

* [Cleanup] the 'did' parameter was finally removed from SystemCmd and SqlCmd to avoid confusion
    (the same functionality is already incapsulated into AnalysisJobAdaptor)

* [Feature] SqlCmd can now produce mysql_insert_ids and pass them on as params.
    This allows us to grab auto-incremented values on PipeConfig level (see Compara/PipeConfig for examples)

* [Convenience] beekeeper.pl and runWorker.pl can take dbname as a "naked" command line option
    (which makes the option's syntax even closer to that of mysql/mysqldump)

* [Convenience] -job_id is now the standard option name understood by beekeeper.pl and runWorker.pl
    (older syntax is kept for compatibility)

* [Cleanup] Some unused scripts have been removed from sql/ directory,
    drop_hive_tables() added to procedures.sql

* [Bugfix] claim_analysis_status index on analysis_job table has been fixed in tables.sql
    and a corresponding patch file added


13 June, 2010 : Leo Gordon

* Added support for dataflow-into-tables, see LongMult example.

10 June, 2010 : Leo Gordon

* A bug preventing users from setting hive_output_dir via pipeline_wide_parameters has been fixed.

3 June, 2010 : Leo Gordon

* one important workaround for LSF command line parsing bug
    (the LSF was unable to create job arrays where pipeline name started from certain letters)

* lots of new documentation added and old docs removed (POD documentation in modules as well as eHive initialization/running manuals).
    Everyone is encouraged to use the new init_pipeline.pl and PipeConfig-style configuration files.

* a schema change that makes it possible to have multiple input_id_templates per dataflow branch
    (this feature is already accessible via API, but not yet implemented in init_pipeline.pl)

* JobFactory now understands multi-column input and intput_id templates can be written to refer to individual columns.
    The 'inputquery' mode has been tested and it works.
    Both 'inputfile' and 'inputcmd' should be able to split their input on param('delmiter'), but this has not yet been tested.


12 May, 2010 : Leo Gordon

* init_pipeline.pl can be given a PipeConfig file name instead of full module name.

* init_pipeline.pl has its own help that displays pod documentation (same mechanism as other eHive scripts)

* 3 pipeline initialization modes supported:
    full (default), -analysis_topup (pipeline development mode) and -job_topup (add more data to work with)


11 May, 2010 : Leo Gordon

* We finally have a universal framework for commandline-configurable pipelines' setup/initialization.
    Each pipeline is defined by a Bio::EnsEMBL::Hive::PipeConfig module
    that derives from Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf .
    Compara pipelines derive from Bio::EnsEMBL::Compara::PipeConfig::ComparaGeneric_conf .
    These configuration modules are driven by ensembl-hive/scripts/init_pipeline.pl script.

    Having set up what is an 'option' in your config file, you can then supply values for it
    from the command line. Option interdependency rules are also supported to a certain extent,
    so you can supply *some* options, and rely on the rules to compute the rest.

* Several example PipeConfig files have been written to show how to build pipelines both 'standard blocks'
    (SystemCmd, SqlCmd, JobFactory, Dummy, etc) and from RunnableDBs written specifically for the task
    (components of LongMult pipeline).

* Both eHive RunnableDB::* and PipeConfig::* modules have been POD-documented.

* A new 'input_id_template' feature has been added to the dataflow mechanism to allow for more flexibility
    when integrating external scripts or unsupported software into eHive pipelines.
    You can now dataflow from pretty much anything, even if the Runnable did not support dataflow natively.
    The corresponding schema patch is in ensembl-hive/sql

* pipeline-wide parameters (kept in 'meta' table) no longer have to be scalar.
    Feel free to use arrays or hashes if you need them. init_pipeline.pl also supports multilevel options.

* SqlCmd now has a concept of 'sessions': you can supply several queries in a list that will be executed
    one after another. If a query creates a temporary table, all the following ones down the list
    will be able to use it.

* SqlCmd can run queries against any database - not necessarily the eHive one. You have to supply a hashref
    of connection parameters via $self->param('db_conn') to make it work. It still runs against the eHive
    database by default.

* JobFactory now supports 4 sources: inputlist, inputfile, inputquery and inputcmd.
    *All* of them now support deep param_substitution. Enjoy.

* NB! JobFactory's substituted parameter syntax changed:
    it no longer understands '$RangeStart', '$RangeEnd' and '$RangeCount'.
    But it understands '#_range_start#', '#_range_end#' and '#_range_count#' - should be pretty easy to fix.

* several smaller bug fixes and optimizations of the code have also been done.
    A couple of utility methods have moved places, but it looks like they were mostly used internally. 
    Shout if you have lost anything and we'll try to find it together.


26 March, 2010 : Leo Gordon

* branch_code column in analysis_job table is unnecessary and was removed

    Branching using branch_codes is a very important and powerful mechanism,
    but it is completely defined in dataflow_rule table.

    branch_code() WAS at some point a getter/setter method in AnalysisJob,
    but it was only used to pass parameters around in the code (now obsolete),
    and this information was never reflected in the database,
    so analysis_job.branch_code was always 1 no matter what.

* stringification using Data::Dumper with parameters was moved out of init_pipelines and JobFactory.pm
    and is now in a separate Hive::Utils.pm module (Hive::Utils::stringify can be imported, inherited or just called).
    It is transparently called by AnalysisJobAdaptor when creating jobs which allows
    to pass input_ids as hashrefs and not strings. Magic happens on the adaptor level.

* Queen->flow_output_job() method has been made obsolete and removed from the Queen.pm
    Dataflow is now completely handled by Process->dataflow_output_id() method,
    which now handles arrays/fans of jobs and semaphores (later on this).
    Please always use dataflow_output_id() if you need to create a new job or fan of jobs,
    as this is the top level method for doing exactly this.
    Only call the naked adaptor's method if you know what you're doing.

* JobFactory module has been upgraded (simplified) to work through dataflow mechanism.
    It no longer can create analyses, but that's not necessary as it should be init_pipeline's job.
    Family pipeline has been patched to work with the new JobFactory module.

* branched dataflow was going to meet semaphores at some point, the time is near.
    dataflow_output_id() is now semaphore aware, and can propagate semaphores through the control graph.
    A new fan is hooked on its own semaphore; when the semaphored_job is not specified we do semaphore propagation.
    Inability to create a job in the fan is tracked and the corresponding semaphore_count decreased
    (so users do not have to worry about it).

* LongMult examples have been patched to work with the new dataflow_output_id() method.

* init_pipeline.pl is now more flexible and can understand simplified syntax for dataflow/control rules


22 March, 2010 : Leo Gordon

* Bio::EnsEMBL::Hive::ProcessWithParams is the preferred way of parsing/passing around the parameters.
    Module-wide, pipeline-wide, analysis-wide and job-wide parameters and their precedence.

* A new init_pipeline.pl script to create and populate pipelines from a perl hash structure.
    Tested with ensembl-hive/docs/long_mult_pipeline.conf and ensembl-compara/scripts/family/family_pipeline.conf . It works.

* Bio::EnsEMBL::Hive::RunnableDB::SystemCmd now supports parameter substitution via #param_name# patterns.
    See usage examples in the ensembl-compara/scripts/family/family_pipeline.conf

* There is a new Bio::EnsEMBL::Hive::RunnableDB::SqlCmd that does that it says,
    and also supports parameter substitution via #param_name# patterns.
    See usage examples in the ensembl-compara/scripts/family/family_pipeline.conf

* Bio::EnsEMBL::Hive::RunnableDB::JobFactory has 3 modes of operation: inputlist, inputfile, inputquery.
    See usage examples in the ensembl-compara/scripts/family/family_pipeline.conf

* some rewrite of the Queen/Adaptors code to give us more developmental flexibility

* support for semaphores (job-level control rules) in SQL schema and API
    - partially tested, has some quirks, waiting for a more serious test by Albert

* support for resource requirements in SQL schema, API and on init_pipeline config file level
    Tested in the ensembl-compara/scripts/family/family_pipeline.conf . It works.


3 December, 2009 : Leo Gordon

beekeeper.pl, runWorker.pl and cmd_hive.pl
got new built-in documentation accessible via perldoc or directly.


2 December, 2009 : Leo Gordon

Bio::EnsEMBL::Hive::RunnableDB::LongMult example toy pipeline has been created
to show how to do various things "adult pipelines" perform
(job creation, data flow, control blocking rules, usage of intermediate tables, etc).

Read Bio::EnsEMBL::Hive::RunnableDB::LongMult for a step-by-step instruction
on how to create and run this pipeline.


30 November, 2009 : Leo Gordon

Bio::EnsEMBL::Hive::RunnableDB::JobFactory module has been added.
It is a generic way of creating batches of jobs with the parameters
given by a file or a range of ids.
Entries in the file can also be randomly shuffled.


13 July, 2009 : Leo Gordon

Merging the "Meadow" code from this March' development branch.
Because it separates LSF-specific code from higher level, it will be easier to update.

-------------------------------------------------------------------------------------------------------

Albert, sorry - in the process of merging into the development branch I had to remove your HIGHMEM code.
I hope it is a temporary measure and we will be having hive-wide queue control soon.
If not - you can restore the pre-merger state by updating with the following command:

    cvs update -r lg4_pre_merger_20090713

('maximise_concurrency' option was carried over)

-------------------------------------------------------------------------------------------------------


3 April, 2009 : Albert Vilella

  Added a new maximise_concurrency 1/0 option. When set to 1, it will
  fetch jobs that need to be run in the adequate order as to maximise
  the different number of analyses being run. This is useful for cases
  where different analyses hit different tables and the overall sql
  load can be kept higher without breaking the server, instead of
  having lots of jobs for the same analysis trying to hit the same
  tables.

  Added quick HIGHMEM option. This option is useful when a small
  percent of jobs are too big and fail in normal conditions. The
  runnable can check if it's the second time it's trying to run the
  job, if it's because it contains big data (e.g. gene_count > 200)
  and if it isn't already in HIGHMEM mode. Then, it will call
  reset_highmem_job_by_dbID and quit::

   if ($self->input_job->retry_count == 1) {
     if ($self->{'protein_tree'}->get_tagvalue('gene_count') > 200 && !defined($self->worker->{HIGHMEM})) {
       $self->input_job->adaptor->reset_highmem_job_by_dbID($self->input_job->dbID);
       $self->DESTROY;
       throw("Alignment job too big: send to highmem and quit");
     }
   }

  Assuming there is a

   beekeeper.pl -url <blah> -highmem -meadow_options "<lots of mem>"

   running, or a 
   
   runWorker.pl <blah> -highmem 1

   with lots of mem running, it will fetch the HIGHMEM jobs as if they
   were "READY but needs HIGHMEM".

   Also added a modification to Queen that will not synchronize as
   often when more than 450 jobs are running and the load is above
   0.9, so that the queries to analysis tables are not hitting the sql
   server too much.

23 July, 2008 : Will Spooner
  Removed remaining ensembl-pipeline dependencies.

11 March, 2005 : Jessica Severin
  Project is reaching a very stable state.  New 'node' object Bio::EnsEMBL::Hive::Process
  allows for independence from Ensembl Pipeline and provides extended process functionality
  to manipulate hive job objects, branch, modify hive graphs, create jobs, and other hive
  process specific tasks.  Some of this extended 'Process' API may still evolve.

7 June, 2004 : Jessica Severin
  This project is under active development and should be classified as pre-alpha
  Most of the design has been settled and I'm in the process of implementing the details
  but entire objects could disappear or drastically change as I approach the end.
  Watch this space for further developments

11 March, 2005 : Jessica Severin

.. raw:: latex

   \end{comment}

