with loan_data as (
    select 
        l.customer_id,
        l.contract_id,
        l.customer_type,
        l.open_date,
        l.due_date,
        l.principal_amount,
        current_date as calculation_date,
        extract(day from l.due_date - current_date) as days_to_due
    from warehouse.loan_contracts l
    where l.open_date >= date '2024-01-01'
),

bucketized_debt as (
    select 
        customer_id,
        customer_type,
        case 
            when days_to_due <= 30 then 'До 30 дней'
            when days_to_due <= 90 then '31–90 дней'
            when days_to_due <= 180 then '91–180 дней'
            when days_to_due <= 365 then '181–365 дней'
            else 'Свыше 1 года'
        end as term_bucket,
        sum(principal_amount) as total_debt
    from loan_data
    group by customer_id, customer_type, term_bucket
)

select * 
from bucketized_debt
order by customer_type, term_bucket;
