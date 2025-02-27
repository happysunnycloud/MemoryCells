-- подсчет количества записей принадлежащих папке
select
    count(*) folder_contents_count
from
    mc_cells
where
    folder_id = :folder_id