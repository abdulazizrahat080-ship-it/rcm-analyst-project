------------------------------ Query 3 ---------------------------------
--- Step 1: Here, we are grouping by multiple columns/fields. Denial code and denial description basically tells the same thing. One is encrypted code another one is description
--- Finding out the total resubmits, recovered amount. 
WITH denial_summary AS (

    SELECT 
        denial_code,
        denial_description,

        COUNT(*) AS total_denials,

        SUM(
            CASE 
                WHEN resubmit_flag = 1 
                THEN 1 
                ELSE 0 
            END
        ) AS total_resubmitted,

        SUM(
            CASE 
                WHEN appeal_status = 'Won' 
                THEN 1 
                ELSE 0 
            END
        ) AS total_won_appeals,

        SUM(
            CASE 
                WHEN recovered_amount IS NOT NULL 
                THEN recovered_amount 
                ELSE 0 
            END
        ) AS total_recovered_amount

    FROM denialreasons

    GROUP BY 
        denial_code,
        denial_description
-- We do not want all aggregated rows. We want those only where denials are more than one. Having is applying filters on aggregated rows. 
    HAVING COUNT(*) > 1
)

SELECT
    denial_code,
    denial_description,

    total_denials,

    total_resubmitted,

  -- Rounding upto 2 decimal points
  -- safe division. Avoiding division by zero
    
  ROUND(
        CAST(total_resubmitted AS FLOAT)
        / NULLIF(total_denials, 0) * 100,
        2
    ) AS resubmission_rate_pct,

    total_won_appeals,

    ROUND(
        CAST(total_won_appeals AS FLOAT)
        / NULLIF(total_denials, 0) * 100,
        2
    ) AS recovery_rate_pct,

    total_recovered_amount

FROM denial_summary

ORDER BY total_recovered_amount DESC;
