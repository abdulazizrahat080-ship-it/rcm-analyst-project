--------------------------------- Query 6 --------------------------------------------------------------------------
--- This is an open-ended, multi-metric question.
--- Consider it like an executive summary.
-- 

-- Monthly claim-level KPI aggregation
WITH initial_monthwise_summary AS (

    SELECT 
        CONVERT(VARCHAR(7), date_of_service, 120) AS month,

        -- Total submitted claims
        COUNT(*) AS total_claims_submitted,

        -- Counting denied claims
        COUNT(
            CASE 
                WHEN claim_status = 'Denied'
                THEN claim_id
            END
        ) AS total_denied_claims,

     
  -- SUM automatically ignores NULL values
  
        SUM(billed_amount) AS total_billed,

        SUM(paid_amount) AS total_paid,

        -- Total billed exposure tied to denied claims
        SUM(
            CASE 
                WHEN claim_status = 'Denied'
                THEN billed_amount
            END
        ) AS total_denied_billed_exposure

    FROM claims

    GROUP BY CONVERT(VARCHAR(7), date_of_service, 120)
),


-- Computing monthly operational rates
  
final_claim_computation AS (

    SELECT 
        month,

        total_claims_submitted,

        total_denied_claims,

        total_billed,

        total_paid,

        -- Overall collection rate = paid / billed
        ROUND(
            CAST(total_paid AS FLOAT)
            / NULLIF(total_billed, 0) * 100,
            2
        ) AS overall_collection_rate_pct,

        -- Denial rate = denied claims / total claims
        ROUND(
            CAST(total_denied_claims AS FLOAT)
            / NULLIF(total_claims_submitted, 0) * 100,
            2
        ) AS denial_rate_pct,

        total_denied_billed_exposure

    FROM initial_monthwise_summary
),

-- Monthly recovery amounts from appeals/resubmissions
recovered_amount_summary AS (

    SELECT 
        CONVERT(VARCHAR(7), resubmit_date, 120) AS month,

        SUM(recovered_amount) AS total_recovered_amount

    FROM denialreasons

    WHERE resubmit_date IS NOT NULL

    GROUP BY CONVERT(VARCHAR(7), resubmit_date, 120)
),

-- Monthly unapplied/unposted cash summary
unposted_cash_summary AS (

    SELECT 
        CONVERT(VARCHAR(7), payment_date, 120) AS month,

        SUM(
            CASE 
                WHEN posted_date IS NULL
                THEN payment_amount
            END
        ) AS total_unposted_cash

    FROM remittances

    GROUP BY CONVERT(VARCHAR(7), payment_date, 120)
)

SELECT 
    fcc.month,

    fcc.total_claims_submitted,

    fcc.total_billed,

    fcc.total_paid,

    fcc.overall_collection_rate_pct,

    fcc.denial_rate_pct,

    fcc.total_denied_billed_exposure,

    -- Replacing NULL recovered values with 0
    ISNULL(
        ras.total_recovered_amount,
        0
    ) AS total_recovered_from_appeals,

    -- Net outstanding = billed - paid - recovered
    fcc.total_billed
    - fcc.total_paid
    - ISNULL(ras.total_recovered_amount, 0)
        AS net_outstanding,

    -- Unposted cash still pending application
  
    ISNULL(
        ucs.total_unposted_cash,
        0
    ) AS total_unposted_cash

FROM final_claim_computation fcc

LEFT JOIN recovered_amount_summary ras
    ON fcc.month = ras.month

-- Joining directly on month from final monthly claim summary
LEFT JOIN unposted_cash_summary ucs
    ON fcc.month = ucs.month

-- Chronological month ordering
ORDER BY fcc.month ASC;
