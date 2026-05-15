------------------------------- Query 5 -----------------------------------------------------------------------


-- Monthly remittance payment summary
WITH year_level_summary AS (

    SELECT 

        -- Creating year-month reporting label
  --- Instead of format, we could have used dateparts or convert function. These two are proved to be more efficient and optimized than FORMAT. 
  ---- For the sake of some variations, we have used format. 
        FORMAT(payment_date, 'yyyy-MM') AS year_month_label,

        -- Counting only posted remittances
        COUNT(
            CASE 
                WHEN posted_date IS NOT NULL 
                THEN remittance_id 
            END
        ) AS number_of_remittances_posted,

        -- Summing only posted payment amounts
        SUM(
            CASE 
                WHEN posted_date IS NOT NULL
                THEN payment_amount
            END
        ) AS total_amount_posted

    FROM remittances

    GROUP BY FORMAT(payment_date, 'yyyy-MM')

    -- Including only months having at least one posted remittance
    HAVING COUNT(
        CASE 
            WHEN posted_date IS NOT NULL 
            THEN 1
        END
    ) > 0
)

SELECT
    year_month_label,

    number_of_remittances_posted,

    total_amount_posted,

    -- Running cumulative posted amount
    SUM(total_amount_posted) OVER (
        ORDER BY year_month_label
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_total_posted,

    -- Month-over-month payment change
    total_amount_posted
    -
 
        LAG(total_amount_posted) OVER (
            ORDER BY year_month_label
        
    ) AS mom_change_posted_amount

FROM year_level_summary

-- Chronological ordering
ORDER BY year_month_label ASC;
