-- обновить ремайндер ¤чейки
update
	mc_cells
set
	remind_datetime = :remind_datetime
where
	id = :id