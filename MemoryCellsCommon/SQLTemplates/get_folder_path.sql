-- получить путь до целевой папки
with recursive recu(id, folder_id, name)
as
    (
        select 
            id, folder_id, name
        from
            mc_folders
        where
            id = :id
        union all
        select 
            mc_folders.id, mc_folders.folder_id, mc_folders.name
        from
            mc_folders, recu
        where
            mc_folders.id = recu.folder_id
            and             
            recu.id > 1 
        order by folder_id desc
    )
select 
	id,
	folder_id, 
             name,
             (
                select
                    group_concat(v_recu.name, ' > ')
                from
                    (
                        select
                            id, name
                        from
                            recu
                        order by id asc
                    ) v_recu       
             ) path,
	description,
	content,
	cell_type_id
from 
	mc_folders
where
	id = :id
