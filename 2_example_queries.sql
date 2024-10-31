-- In the above example, how did the carbon content trend from one process to the next?

-- ASSUMPTIONS: User already knows experiment_id of example (assume experiment_id = 88)
-- A process may have multiple samples collected. If so, take the carbon content of most recent sample for each process.
-- Carbon content delta is calculated by taking difference of carbon content of current process minus that of previous process.

SELECT
p.process_id,
p.process_type,
carbon_content_process - LAG(carbon_content_process, 1, 0) OVER (ORDER BY p.start_time) AS carbon_content_delta
FROM
    (SELECT 
    p.process_id,
    p.process_type,
    p.start_time,
    FIRST_VALUE(atp.output:carbon_content) OVER (ORDER BY s.time DESC) AS carbon_content_process
    FROM experiments e
    JOIN processes p ON e.experiment_id = p.experiment_id
    JOIN samples s ON p.process_id = s.process_id
    JOIN analyses a ON s.sample_id = a.sample_id
    JOIN analysis_type_params atp ON a.analysis_type = atp.analysis_type
    JOIN instruments i ON a.instrument_id = i.instrument_id
    WHERE e.experiment_id = 88 AND a.analysis_type = 'carbon content' AND i.instrument_type = 'combustion analyzer'
    GROUP BY p.process_id, p.process_type, p.start_time) sub
ORDER BY p.start_time;



-- Can the data from the combustion analyzer be trusted? (i.e., when was it last calibrated?)

-- ASSUMPTIONS: An instrument is considered trustworthy if it has been calibrated within 180 days of the analysis date.
-- Create a calibration_flag variable: 1 for calibration pass, 0 for calibration fail.
-- If there are multiple samples within a process, if calibration fails for any single sample, it fails for the entire process.

SELECT
p.process_id,
p.process_type,
carbon_content_process - LAG(carbon_content_process, 1, 0) OVER (ORDER BY p.start_time) AS carbon_content_delta,
calibration_flag
FROM
    (SELECT 
    p.process_id,
    p.process_type,
    p.start_time,
    FIRST_VALUE(atp.output:carbon_content) OVER (ORDER BY s.time DESC) AS carbon_content_process,
    MIN(CASE WHEN DATEDIFF(DAY, i.last_calibration_date, a.time) <= 180 THEN 1 ELSE 0 END) AS calibration_flag
    FROM experiments e
    JOIN processes p ON e.experiment_id = p.experiment_id
    JOIN samples s ON p.process_id = s.process_id
    JOIN analyses a ON s.sample_id = a.sample_id
    JOIN analysis_type_params atp ON a.analysis_type = atp.analysis_type
    JOIN instruments i ON a.instrument_id = i.instrument_id
    WHERE e.experiment_id = 88 AND a.analysis_type = 'carbon content' AND i.instrument_type = 'combustion analyzer'
    GROUP BY p.process_id, p.process_type, p.start_time) sub
ORDER BY p.start_time;