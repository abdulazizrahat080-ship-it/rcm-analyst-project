------------------------- Query 2 ------------------------------------------------------
--- In the step 1, Calculating the age of every claims (claim_id being the grain) 
--- Here, the reference date is  '2024-05-15'
---- Using datediff function (date function that calculates the difference between two dates) 

WITH claim_age AS (
    SELECT 
        claim_id,
        claim_submit_date,
        claim_status,
        billed_amount,

        DATEDIFF(
            DAY,
            claim_submit_date,
            '2024-05-15'
        ) AS age

    FROM claims
),
  
  -- now that, we have the age of all the claims in regard to a reference date, we would like to put them into buckets (using case)
 -- This is the core business requirement. If claims are very aged, we should take immediate actions as per protocols. 
-- One of the most important usage of case statements are to create categories / derive new information. This is what in this query we are doing 
  
aging_buckets AS (
    SELECT *,
        
        CASE 
            WHEN age <= 30 THEN 'Current'
            WHEN age <= 60 THEN '31-60'
            WHEN age <= 90 THEN '61-90'
            ELSE '90+'
        END AS aging_bucket

    FROM claim_age
)

  --- Final calculation or computation part 
  
SELECT
    aging_bucket,

    COUNT(*) AS number_of_claims,

    SUM(billed_amount) AS total_billed_amount,

    COUNT(
        CASE 
            WHEN claim_status = 'Submitted'
            THEN 1
        END
    ) AS unworked_claims,

  
  -- rounding up to 2 decimal places 
  
  ROUND(AVG(billed_amount), 2) AS avg_billed_amount,

 
  -- This is the most important part for the stakeholders. They do not have to carefully look at every single metrics. 
  -- This particular field would be sufficient to take decisions . 
    CASE

        WHEN aging_bucket = '90+'
             AND AVG(billed_amount) >= 10000
        THEN 'Immediate Escalation'

        WHEN aging_bucket IN ('61-90', '90+')
             AND AVG(billed_amount) >= 5000
        THEN 'High Priority Follow-Up'

        WHEN aging_bucket = '31-60'
             AND AVG(billed_amount) >= 2000
        THEN 'Monitor Closely'

        ELSE 'Routine Follow-Up'

    END AS severity_signal

FROM aging_buckets

GROUP BY aging_bucket

ORDER BY 
  
--- using case statments to sort the data in a proper way 
  
    CASE aging_bucket
        WHEN 'Current' THEN 1
        WHEN '31-60' THEN 2
        WHEN '61-90' THEN 3
        ELSE 4
    END;
