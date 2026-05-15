-- ============================================================
--  RCM Operations Analyst Project
--  Role Target : Operations Analyst – RCM @ Commure
--  Dialect     : Microsoft SQL Server (T-SQL)
--  Domains     : Claims & Denials  |  Billing & Payments
-- ============================================================

-- ------------------------------------------------------------
-- 1. PAYERS
-- ------------------------------------------------------------
CREATE TABLE Payers (
    payer_id        INT PRIMARY KEY,
    payer_name      VARCHAR(100)    NOT NULL,
    payer_type      VARCHAR(50)     NOT NULL,
    contract_rate   DECIMAL(5,4)    NOT NULL
);

-- ------------------------------------------------------------
-- 2. PROVIDERS
-- ------------------------------------------------------------
CREATE TABLE Providers (
    provider_id     INT PRIMARY KEY,
    provider_name   VARCHAR(100)    NOT NULL,
    npi             VARCHAR(10)     NOT NULL,
    specialty       VARCHAR(100)    NOT NULL,
    facility        VARCHAR(100)    NOT NULL
);

-- ------------------------------------------------------------
-- 3. PATIENTS
-- ------------------------------------------------------------
CREATE TABLE Patients (
    patient_id      INT PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    dob             DATE            NOT NULL,
    gender          CHAR(1)         NOT NULL,
    state           CHAR(2)         NOT NULL,
    payer_id        INT             NOT NULL REFERENCES Payers(payer_id)
);

-- ------------------------------------------------------------
-- 4. CLAIMS
-- ------------------------------------------------------------
CREATE TABLE Claims (
    claim_id            INT PRIMARY KEY,
    patient_id          INT             NOT NULL REFERENCES Patients(patient_id),
    provider_id         INT             NOT NULL REFERENCES Providers(provider_id),
    payer_id            INT             NOT NULL REFERENCES Payers(payer_id),
    date_of_service     DATE            NOT NULL,
    claim_submit_date   DATE            NOT NULL,
    claim_status        VARCHAR(50)     NOT NULL,
    billed_amount       DECIMAL(10,2)   NOT NULL,
    allowed_amount      DECIMAL(10,2)   NULL,
    paid_amount         DECIMAL(10,2)   NULL,
    adjustment_amount   DECIMAL(10,2)   NULL,
    patient_resp_amount DECIMAL(10,2)   NULL,
    priority_flag       TINYINT         NOT NULL DEFAULT 0
);

-- ------------------------------------------------------------
-- 5. CLAIM LINES
-- ------------------------------------------------------------
CREATE TABLE ClaimLines (
    claim_line_id   INT PRIMARY KEY,
    claim_id        INT             NOT NULL REFERENCES Claims(claim_id),
    cpt_code        VARCHAR(10)     NOT NULL,
    icd10_code      VARCHAR(10)     NOT NULL,
    units           INT             NOT NULL DEFAULT 1,
    line_billed     DECIMAL(10,2)   NOT NULL,
    line_paid       DECIMAL(10,2)   NULL,
    line_status     VARCHAR(50)     NOT NULL
);

-- ------------------------------------------------------------
-- 6. DENIAL REASONS
-- ------------------------------------------------------------
CREATE TABLE DenialReasons (
    denial_id           INT PRIMARY KEY,
    claim_id            INT             NOT NULL REFERENCES Claims(claim_id),
    claim_line_id       INT             NULL     REFERENCES ClaimLines(claim_line_id),
    denial_code         VARCHAR(20)     NOT NULL,
    denial_description  VARCHAR(255)    NOT NULL,
    denial_date         DATE            NOT NULL,
    resubmit_flag       BIT             NOT NULL DEFAULT 0,
    resubmit_date       DATE            NULL,
    appeal_status       VARCHAR(50)     NULL,
    recovered_amount    DECIMAL(10,2)   NULL
);

-- ------------------------------------------------------------
-- 7. REMITTANCES
-- ------------------------------------------------------------
CREATE TABLE Remittances (
    remittance_id       INT PRIMARY KEY,
    payer_id            INT             NOT NULL REFERENCES Payers(payer_id),
    claim_id            INT             NOT NULL REFERENCES Claims(claim_id),
    check_number        VARCHAR(50)     NOT NULL,
    payment_date        DATE            NOT NULL,
    payment_amount      DECIMAL(10,2)   NOT NULL,
    payment_method      VARCHAR(30)     NOT NULL,
    posted_date         DATE            NULL,
    variance_amount     DECIMAL(10,2)   NULL
);
