
-- Data model design considerations:
-- > Normalized tables for data consistency and reduced redundancy.
-- > Snowflake as target database, for relational data & scalable analytics.
-- > process_type_params and analysis_type_params utilize VARIANT data type to account for flexible schemas. Load as json-formatted string.
--  > analysis_type_params output needs to be flexible to handle both structured data and image files. Use VARIANT data type to store image data as base64-encoded json string.
-- > Primary and foreign keys have NOT NULL constraints.

-- The following cardinality rules are assumed:
-- > Experiments consist of at least one process instance. A process instance belongs to one and only one experiment.
-- > A process instance is run on one and only one piece of equipment. A piece of equipment may be used for one or many process instances. 
-- > A process instance corresponds to one and only one set of process parameters. A set of process parameters can be used for one or many process instances.
-- > A process instance contains at least one sample. A specific sample belongs to one and only one process instance.
-- > A sample will have at least multiple analyses performed on it. A specific analysis belongs to one and only one sample.
-- > An analysis instance corresponds to one and only one set of analysis parameters. A set of analysis parameters may be used for one or many analyses.
-- > An analysis instance is performed by one and only one instrument. An instrument can be used for one or many different analyses.


CREATE TABLE experiments (
  experiment_id INT AUTOINCREMENT PRIMARY KEY,
  researcher_name VARCHAR,
  start_time TIMESTAMP,
  end_time TIMESTAMP
);

CREATE TABLE processes (
  process_id INT AUTOINCREMENT PRIMARY KEY,
  process_type VARCHAR,
  equipment_id INT NOT NULL,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  experiment_id INT NOT NULL,
  CONSTRAINT FK_processes.experiment_id
    FOREIGN KEY (experiment_id)
      REFERENCES experiments(experiment_id)
);

CREATE TABLE samples (
  sample_id INT AUTOINCREMENT PRIMARY KEY,
  process_id INT NOT NULL,
  process_stage INT,
  time TIMESTAMP,
  sample_no INT
  CONSTRAINT FK_samples.process_id
    FOREIGN KEY (process_id)
      REFERENCES processes(process_id)
);

CREATE TABLE instruments (
  instrument_id INT AUTOINCREMENT PRIMARY KEY,
  instrument_type VARCHAR,
  calibration_freq FLOAT,
  last_calibration_date TIMESTAMP
);

CREATE TABLE equipment (
  equipment_id INT AUTOINCREMENT PRIMARY KEY,
  equipment_type VARCHAR,
  location VARCHAR
);

CREATE TABLE process_type_params (
  process_type VARCHAR,
  input VARIANT,
  output VARIANT,
  PRIMARY KEY (process_type)
);

CREATE TABLE analyses (
  analysis_id INT AUTOINCREMENT PRIMARY KEY,
  analysis_type VARCHAR,
  sample_id INT NOT NULL,
  instrument_id INT NOT NULL,
  time TIMESTAMP,
  CONSTRAINT FK_analyses.sample_id
    FOREIGN KEY (sample_id)
      REFERENCES samples(sample_id),
  CONSTRAINT FK_analyses.instrument_id
    FOREIGN KEY (instrument_id)
      REFERENCES instruments(instrument_id)
);

CREATE TABLE analysis_type_params (
  analysis_type VARCHAR PRIMARY KEY,
  input VARIANT,
  output VARIANT
);

