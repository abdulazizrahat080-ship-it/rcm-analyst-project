# RCM Operations Analyst Project
### By Aziz | Targeting: Operations Analyst – RCM @ Commure

---

## Why I Built This

I wanted to build something that actually reflects what I do day to day.
Not a generic SQL project with sales data or employee tables, but something
that sits close to the work I have spent years doing in healthcare revenue cycle (Particularly, In Manipal Hospitals).

This project simulates a real RCM operation(As per my knowledge and understanding). 
The schema, the data, the questions,
and the queries — all of it is grounded in how claims actually move through a
billing system. From submission to denial to appeal to payment posting.

**I did not build this to show that I know SQL. I built it to show that I understand
the business behind the SQL.**

---

## What This Project Covers

Two core RCM domains:

- **Claims & Denials** — denial rates, aging analysis, recovery performance
- **Billing & Payments** — provider collection efficiency, payment trends, executive KPIs

---

## The Schema

Seven tables built to mirror a real RCM data model:

| Table | What it represents |
|---|---|
| `Payers` | Insurance companies and their contracted rates |
| `Providers` | Doctors, their NPI numbers, specialties and facilities |
| `Patients` | Demographics and primary insurance |
| `Claims` | The core billing transaction — status, amounts, patient responsibility |
| `ClaimLines` | Procedure-level detail — CPT codes, diagnosis codes, line payments |
| `DenialReasons` | CARC denial codes, appeal status, recovered amounts |
| `Remittances` | ERA/835 payment transactions — posted vs unposted cash |

The financial flow on every claim:
> **Billed → Allowed → Paid (Insurer) + Patient Responsibility + Contractual Adjustment**

---

## The Queries

The 6 I picked cover the full spectrum of what an
RCM operations analyst would pull on any given week.

| File | What it solves |
|---|---|
| `q1_denial_rate_by_payer.sql` | Denial rate and billed exposure broken down by payer |
| `q2_claim_aging_buckets.sql` | Claim aging analysis with operational severity signals |
| `q3_denial_recovery_performance.sql` | Denial recovery and appeal win rates by CARC code |
| `q4_provider_collection_efficiency.sql` | Provider-level collection and write-off performance |
| `q5_mom_payment_trend.sql` | Month-over-month posted payment trend with running totals |
| `q6_executive_kpi_dashboard.sql` | Full monthly RCM KPI summary for executive reporting |

---

## What I Used

These are not techniques I learned for this project.
These are patterns I have used in real production environments:

- CTE layering for readable, maintainable query structure
- Conditional aggregation with `CASE` inside `SUM` and `COUNT`
- Safe division with `NULLIF` and `CAST` to prevent silent errors
- Window functions — `LAG`, running `SUM OVER` with explicit frame definition
- Defensive `LEFT JOIN` with `ISNULL` for data quality resilience
- `CONVERT` over `FORMAT` for date truncation performance in T-SQL
- Business-driven `ORDER BY` using `CASE` to enforce logical sort sequences

---

## A Few Things I Was Deliberate About

**NULL vs Zero is not the same thing.**
In Q6, the first month's MoM change returns NULL — not zero. Zero would imply
we had activity with no growth. NULL honestly says there is no prior period to compare.
That distinction matters in a management report.

**Severity signals belong in the query.**
In Q2 I added an unprompted severity flag — Critical, High Priority, Monitor, Routine.
The question did not ask for it. But an aging report without operational context
is just a number. The flag tells the billing team what to do with the number.

**Source of truth matters.**
For recovered amounts in Q10 I used `resubmit_date` not `denial_date`.
Recovery happens after resubmission — not when the denial was received.
Getting that wrong shifts your monthly recovery figures into the wrong period.

---

## Dialect

Microsoft SQL Server — T-SQL

---

## About Me

I am a senior SQL analyst with a background in healthcare data (Bangalore, India) 
This project represents a slice of the work I have done throughout my career. Of course, 
not the whole of it, but enough to show how I think about revenue cycle problems
through data.

If you are reading this for the Commure role — I look forward to the conversation.

**Aziz**
