-- получить €чейку с напоминалкой
select
    *, strftime('%Y', remind_datetime) as year
from
    mc_cells    
where
    remind = true
order by remind_datetime asc
limit 1