attach database :backup_file_name AS backup_db;

begin;

--Step 1

CREATE TABLE backup_db.mc_folders (
    id           INTEGER PRIMARY KEY AUTOINCREMENT
                         NOT NULL,
    folder_id    INTEGER NOT NULL,
    cell_type_id INTEGER NOT NULL
                         DEFAULT (1),
    name         TEXT    NOT NULL,
    description  TEXT,
    content      TEXT,
    create_datetime text not null default (datetime('now', 'localtime')),
    update_datetime text not null default (datetime('now', 'localtime'))
);

CREATE TABLE backup_db.mc_cells (
    id              INTEGER PRIMARY KEY AUTOINCREMENT
                            NOT NULL,
    folder_id       INTEGER NOT NULL,
    cell_type_id    INTEGER NOT NULL
                            DEFAULT (2),
    name            TEXT    NOT NULL
                            DEFAULT ('*'),
    description     TEXT,
    content         TEXT,
    create_datetime TEXT    NOT NULL
                            DEFAULT (datetime('now', 'localtime') ),
    update_datetime TEXT    NOT NULL
                            DEFAULT (datetime('now', 'localtime') ),
    is_done         BOOLEAN DEFAULT false,
    remind_datetime TEXT    DEFAULT '1899-12-30 00:00:00',
    remind          BOOLEAN DEFAULT false
);

CREATE TRIGGER backup_db.update_datetime_trigger
        BEFORE UPDATE OF id,
                         folder_id,
                         cell_type_id,
                         name,
                         description,
                         content,
                         create_datetime,
                         is_done
            ON mc_cells
      FOR EACH ROW
BEGIN
    UPDATE mc_cells
       SET update_datetime = datetime('now', 'localtime') 
     WHERE id = old.id;
END;

--Step 2

insert into backup_db.mc_folders 
select * from mc_folders;

insert into backup_db.mc_cells
select * from mc_cells;

commit;

detach backup_db;