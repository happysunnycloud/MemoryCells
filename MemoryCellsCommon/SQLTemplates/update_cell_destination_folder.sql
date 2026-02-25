-- обновить папку ¤чейки
update
	mc_cells
set
	folder_id = :folder_id 
where
	id = :id