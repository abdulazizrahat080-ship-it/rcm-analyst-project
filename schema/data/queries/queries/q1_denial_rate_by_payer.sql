-- Query 1 : Simple aggregations to find out denial rate and billed exposure by payer. 

WITH base AS (
    SELECT 
        payer_id,
        COUNT(*) AS total_number_of_claims,

  --- Using conditional aggregation to identify and count all the "denied" claims 
  
        COUNT(
            CASE 
                WHEN claim_status = 'Denied' 
                THEN claim_id 
            END
        ) AS total_number_of_denied_claims,

        SUM(billed_amount) AS total_bill_amount,
  
-- another conditional aggregation to compute the "denied" bills 
  
        SUM(
            CASE 
                WHEN claim_status = 'Denied' 
                THEN billed_amount 
                ELSE 0
            END
        ) AS total_bill_amount_for_denials

    FROM claims
    GROUP BY payer_id
),

  
  ---- final computation level 

  final AS (
    SELECT
        payer_id,
        total_number_of_claims,
        total_number_of_denied_claims,

        ROUND(
            CAST(total_number_of_denied_claims AS FLOAT)
            / NULLIF(total_number_of_claims, 0) * 100,
            2
        ) AS denial_rate,

        total_bill_amount,
        total_bill_amount_for_denials
    FROM base
)

  --- main query 
SELECT
    f.payer_id,
  ---- using 'Unknown' for missing payer names (if any) 
    coalesce(p.payer_name,'Unknown') as Payer_Name, 
    f.total_number_of_claims,
    f.total_number_of_denied_claims,
    f.denial_rate,
    f.total_bill_amount,
    f.total_bill_amount_for_denials

FROM final f
  --- using left join because there could be payer ids without a payer name (due to date quality issues in real production)
--- using an inner join may unintentionally drop some of the records. (we simply do not want that) 
  
LEFT JOIN payers p
    ON f.payer_id = p.payer_id

  ---- standard sorting for this kinds of business question 

  ORDER BY f.denial_rate DESC;
