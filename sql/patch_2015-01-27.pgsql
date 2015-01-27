
    -- First, rename all TIMESTAMPed columns to have a 'when_' prefix for automatic identification:
ALTER TABLE analysis_stats          RENAME COLUMN last_update   TO when_updated;
ALTER TABLE job                     RENAME COLUMN completed     TO when_completed;
ALTER TABLE worker                  RENAME COLUMN born          TO when_born;
ALTER TABLE worker                  RENAME COLUMN last_check_in TO when_checked_in;
ALTER TABLE worker                  RENAME COLUMN died          TO when_died;
ALTER TABLE log_message             RENAME COLUMN time          TO when_logged;
ALTER TABLE analysis_stats_monitor  RENAME COLUMN time          TO when_logged;
ALTER TABLE analysis_stats_monitor  RENAME COLUMN last_update   TO when_updated;

    -- Then add one more column to register when a Worker was last seen by the Meadow:
ALTER TABLE worker                  ADD COLUMN    when_seen     TIMESTAMP DEFAULT    NULL;

    -- replace the 'msg' view as the columns implicitly referenced there have been renamed:
DROP VIEW msg;
CREATE OR REPLACE VIEW msg AS
    SELECT a.analysis_id, a.logic_name, m.*
    FROM log_message m
    LEFT JOIN job j ON (j.job_id=m.job_id)
    LEFT JOIN analysis_base a ON (a.analysis_id=j.analysis_id);

    -- UPDATE hive_sql_schema_version
UPDATE hive_meta SET meta_value=64 WHERE meta_key='hive_sql_schema_version' AND meta_value='63';

