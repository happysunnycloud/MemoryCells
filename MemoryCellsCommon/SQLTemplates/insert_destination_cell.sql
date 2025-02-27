-- копируем €чейку из одной папки в другую
insert into 
        mc_cells
        (
        folder_id,
        cell_type_id,
        name,
        description,
        content,
        create_datetime,
        update_datetime,
        is_done      
        )
select
        :folder_id as folder_id,
        cell_type_id,
        name,
        description,
        content,
        create_datetime,
        update_datetime,
        is_done                        	
from
        mc_cells
where
        id = :id