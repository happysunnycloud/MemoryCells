-- обновить папку
update
	mc_folders
set
	name = :name
where
	id = :id