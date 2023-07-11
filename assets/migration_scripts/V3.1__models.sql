-- Table models_meta
-- This table stores the meta information about the models for each cell type.
CREATE TYPE model_type_e AS ENUM ('lookup_table', 'ecm', 'spm',  'tank', 'p2d', 'other');
CREATE TABLE public.models_meta (
    model_type_id SERIAL PRIMARY KEY,
    model_type model_type_e NOT NULL,
    cell_type_id INTEGER REFERENCES cells_meta (cell_type_id), -- ATL1
    model_type_name TEXT,  -- SPM
    model_type_parameters JSONB,
    other_details JSONB
);

-- Table to store the battery models 
-- This table stores the battery model with version, so as we iterate to develop
-- new versions of individual model types, we can keep track of the versions & stages.
CREATE TYPE model_stage_e AS ENUM ('dev', 'stag', 'prod');
CREATE TYPE model_param_t AS (    parameter_name TEXT,
                                parameter_value NUMERIC,
                                parameter_units TEXT,
                                other_details JSONB
            );  
CREATE TABLE public.models (
    model_id SERIAL PRIMARY KEY,
    model_name TEXT, -- ATL1_SPM1, ATL1 SPM2, ATL1_P2D1 ...
    model_type_id INTEGER REFERENCES models_meta (model_type_id),
    model_physical_params model_param_t[], -- this will store physicsl params like porosity, thickness, etc.
    model_mathematical_params model_param_t[], -- this will store mathematical params like node points etc. from maple,
    model_computational_params model_param_t[], -- this will store computational params like mu_step, mhe_pred_horizon etc.
    model_version TEXT, -- 1, 2, 1, 
    model_stage model_stage_e NOT NULL, -- dev (1, 2, 3, 5) -- staging (1, 3), -- prod (3)
    other_details JSONB
);

-- Partial Unique constraint on models table
-- Only one model of each type can be in production at a time. 
CREATE UNIQUE INDEX models_prod_version_idx ON models (model_type_id) WHERE model_stage = 'prod';
