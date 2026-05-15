----------------------------- Query 4 ------------------------------------------------------------------------

    -- Aggregating provider-level financial KPIs
WITH provider_financial_summary AS (

    SELECT 
        provider_id,

        -- Total submitted claims
        COUNT(*) AS total_claims,

        -- SUM automatically ignores NULL values
        SUM(billed_amount) AS total_billed_amount,

        SUM(allowed_amount) AS total_allowed_amount,

        SUM(paid_amount) AS total_paid_amount,

        -- Contractual adjustment directly from source column
        SUM(adjustment_amount) AS total_contractual_adjustment

    FROM claims

    GROUP BY provider_id

    -- Including only providers having at least 3 claims
    HAVING COUNT(*) >= 3
)

SELECT
    pfs.provider_id,

    -- Replacing missing provider names because of data quality issues (same work done at question 1 for payers) 
  --- Note : We are using ISNULL instead of coalesce for better optimization and performance. Coalesce can take upto as many expressions as we want. 
           --- This is the reasons sql looks for further expressions (if any). ISNULL is faster in that particular situation. 
   
  ISNULL(p.provider_name, 'Not Available') AS provider_name,

    pfs.total_claims,

    pfs.total_billed_amount,

    pfs.total_allowed_amount,

    pfs.total_paid_amount,

    -- Collection rate = paid / billed
    -- NULLIF prevents divide-by-zero errors
    ROUND(
        CAST(pfs.total_paid_amount AS FLOAT)
        / NULLIF(pfs.total_billed_amount, 0) * 100,
        2
    ) AS collection_rate_pct,

    pfs.total_contractual_adjustment,

    -- Write-off rate = (billed - paid) / billed
    ROUND(
        CAST(
            pfs.total_billed_amount - pfs.total_paid_amount
            AS FLOAT
        )
        / NULLIF(pfs.total_billed_amount, 0) * 100,
        2
    ) AS writeoff_rate_pct

FROM provider_financial_summary pfs

-- LEFT JOIN keeps provider rows even if provider mapping is missing
LEFT JOIN providers p
    ON pfs.provider_id = p.provider_id

-- Worst collection performers first
ORDER BY collection_rate_pct ASC;
