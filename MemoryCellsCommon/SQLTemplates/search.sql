select
    mc_folders.*,
    mc_cells.id as cell_id    
from
    mc_cells
        left join 
    mc_folders 
        on
    (mc_cells.folder_id = mc_folders.id)    
where 
(    
    select
    upper(
        (
            with recursive
            under_name(test_text, char, level) as 
                (select t.test_text, '', 0
                union
                select test_text, coalesce(lu.u,substr(test_text,level,1)), under_name.level+1
                from under_name
                left join (
                    select 'À' as u, 'à' as l union select 'Á' as u, 'á' as l union select 'Â' as u, 'â' as l union select 'Ã' as u, 'ã' as l union 
                    select 'Ä' as u, 'ä' as l union select 'Å' as u, 'å' as l union select '¨' as u, '¸' as l union select 'Æ' as u, 'æ' as l union 
                    select 'Ç' as u, 'ç' as l union select 'È' as u, 'è' as l union select 'É' as u, 'é' as l union select 'Ê' as u, 'ê' as l union 
                    select 'Ë' as u, 'ë' as l union select 'Ì' as u, 'ì' as l union select 'Í' as u, 'í' as l union select 'Î' as u, 'î' as l union 
                    select 'Ï' as u, 'ï' as l union select 'Ð' as u, 'ð' as l union select 'Ñ' as u, 'ñ' as l union select 'Ò' as u, 'ò' as l union 
                    select 'Ó' as u, 'ó' as l union select 'Ô' as u, 'ô' as l union select 'Õ' as u, 'õ' as l union select 'Ö' as u, 'ö' as l union 
                    select '×' as u, '÷' as l union select 'Ø' as u, 'ø' as l union select 'Ù' as u, 'ù' as l union select 'Ü' as u, 'ü' as l union 
                    select 'Û' as u, 'û' as l union select 'Ú' as u, 'ú' as l union select 'Ý' as u, 'ý' as l union select 'Þ' as u, 'þ' as l union 
                    select 'ß' as u, 'ÿ' as l
                ) lu on substr(test_text,level,1)=lu.l
                where level <= length(test_text)
            )
            select group_concat(char,'') from under_name
        )
    ) upper_text
    from
    (select mc_cells.content test_text) t
) like :search_text