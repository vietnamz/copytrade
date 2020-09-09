##
##  Creates or updates the tables needed for management of Flow sequences and bins
##
##
##  Warning: backup your database before running this script
##
##  If you are modify the tables be sure to update the version numbers
##  returned by major(), minor() or revision() and add an appropriate
##  update_to_M_m_r proceedure.
##



CREATE DATABASE IF NOT EXISTS copytrade;
USE copytrade;


DROP FUNCTION IF EXISTS table_exists;
DELIMITER $$
CREATE FUNCTION table_exists ( in_table_name VARCHAR(255) ) RETURNS INT
NO SQL
BEGIN
  DECLARE l_found INT DEFAULT 0;
  DECLARE l_tmper VARCHAR(255) DEFAULT '';

  DECLARE result_csr cursor FOR
    SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
                                          WHERE TABLE_SCHEMA='flow_bins' AND
                                          TABLE_NAME LIKE in_table_name;


  DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_found=-1;

  OPEN result_csr;
    result_loop: LOOP

    FETCH result_csr INTO l_tmper;

    IF l_found=-1 THEN
      LEAVE result_loop;
    END IF;

    SET l_found=1;
    LEAVE result_loop;

    END LOOP result_loop;

  CLOSE result_csr;


  RETURN l_found;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS add_message;
DELIMITER $$
CREATE PROCEDURE add_message( in_msg VARCHAR(255) )
BEGIN

    CREATE TABLE IF NOT EXISTS messages(
      message VARCHAR(255)
    ) ;

    INSERT INTO messages VALUES( in_msg );
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS major;
DELIMITER $$
CREATE FUNCTION major () RETURNS INT
NO SQL
BEGIN
  RETURN 3;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS minor;
DELIMITER $$
CREATE FUNCTION minor () RETURNS INT
NO SQL
BEGIN
  RETURN 0;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS revision;
DELIMITER $$
CREATE FUNCTION revision () RETURNS INT
NO SQL
BEGIN
  RETURN 25;
END $$
DELIMITER ;


# set the version number to x,y,z
DROP PROCEDURE IF EXISTS set_version;
DELIMITER $$
CREATE PROCEDURE set_version( in_major INT, in_minor INT, in_revision INT )
BEGIN

    DROP TABLE IF EXISTS version;

    CREATE TABLE version (
      major INT UNSIGNED NOT NULL,
      minor INT UNSIGNED NOT NULL,
      revision INT UNSIGNED NOT NULL
    );

    INSERT INTO version VALUES( in_major, in_minor, in_revision );

END $$
DELIMITER ;


DROP FUNCTION IF EXISTS current_version_less_than;
DELIMITER $$
CREATE FUNCTION current_version_less_than( in_major INT, in_minor INT, in_revision INT ) RETURNS INT
NO SQL
BEGIN

    DECLARE l_major INT;
    DECLARE l_minor INT;
    DECLARE l_revision INT;

    SELECT major, minor, revision INTO l_major, l_minor, l_revision FROM version;

    IF l_major < in_major THEN
        RETURN 1;
    END IF;

    IF l_major > in_major THEN
        RETURN 0;
    END IF;


    IF l_minor < in_minor THEN
        RETURN 1;
    END IF;

    IF l_minor > in_minor THEN
        RETURN 0;
    END IF;


    IF l_revision < in_revision THEN
        RETURN 1;
    END IF;

    IF l_revision > in_revision THEN
        RETURN 0;
    END IF;

    RETURN 0;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS create_or_update_database;
DELIMITER $$
CREATE PROCEDURE create_or_update_database()
BEGIN

    CALL add_message( CONCAT( "Script ran at: ", NOW() ) );

    IF table_exists( 'version' )=1 THEN
        CALL add_message( 'database already exists. updating...' );
        CALL update_database();
        CALL add_message( '...updated' );
    ELSE
        CALL add_message( 'building bins database...' );
        CALL build_database();
        CALL set_version( major(), minor(), revision() );
        CALL add_message( '...built' );
    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_database;
DELIMITER $$
CREATE PROCEDURE update_database()
BEGIN

    # base version was 0.1.2
    CALL update_to_0_1_3();
    CALL update_to_0_1_4();
    CALL update_to_0_1_5();
    CALL update_to_0_1_6();
    CALL update_to_0_1_7();
    CALL update_to_0_1_8();
    CALL update_to_0_1_9();
    CALL update_to_0_1_10();
    CALL update_to_0_1_11();
    CALL update_to_0_1_12();
    CALL update_to_0_1_13();
    CALL update_to_0_1_14();
    CALL update_to_3_0_0();
    CALL update_to_3_0_1();
    CALL update_to_3_0_2();
    CALL update_to_3_0_3();
    CALL update_to_3_0_4();
    CALL update_to_3_0_5();
    # 3.3 series
    CALL update_to_3_0_6();
    CALL update_to_3_0_7();
    CALL update_to_3_0_8();
    CALL update_to_3_0_9();
    CALL update_to_3_0_10();
    CALL update_to_3_0_11();
    CALL update_to_3_0_12();
    # .7
    CALL update_to_3_0_13();
    CALL update_to_3_0_14();
    CALL update_to_3_0_15();
    # 2018.1
    CALL update_to_3_0_16();
    # 2019.4
    CALL update_to_3_0_17();
    # 2020.1
    CALL update_to_3_0_18();
    # 2020.2
    CALL update_to_3_0_19();
    CALL update_to_3_0_20();
    # 2020.3
    CALL update_to_3_0_21();
    # 2020.4
    CALL update_to_3_0_22();
    CALL update_to_3_0_23();
    CALL update_to_3_0_24();
    CALL update_to_3_0_25();
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_0_1_3;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_3()
BEGIN

    # history
    # 0.1.2-->0.1.3
    # development update.  dont need to preserve data
    # add comment field for sequence entries
    IF current_version_less_than( 0, 1, 3 )=1 THEN

        ALTER TABLE sequence_entries ADD comment VARCHAR(255);

        CALL set_version( 0, 1, 3 );
        CALL add_message( 'updated to 0.1.3' );

    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_0_1_4;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_4()
BEGIN

    # history
    # 0.1.3-->0.1.4
    # switch to utf8
    IF current_version_less_than( 0, 1, 4 )=1 THEN

        ALTER TABLE messages CHARACTER SET 'utf8';
        ALTER TABLE version CHARACTER SET 'utf8';

        ALTER TABLE link_sequence_entries CHARACTER SET 'utf8';
        ALTER TABLE link_sequence_owner CHARACTER SET 'utf8';
        ALTER TABLE owners CHARACTER SET 'utf8';
        ALTER TABLE projects CHARACTER SET 'utf8';
        ALTER TABLE sequence_entries CHARACTER SET 'utf8';
        ALTER TABLE sequences CHARACTER SET 'utf8';
        ALTER TABLE user_folders CHARACTER SET 'utf8';

        CALL set_version( 0, 1, 4 );
        CALL add_message( 'updated to 0.1.4' );

    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_0_1_5;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_5()
BEGIN

    # history
    # 0.1.4-->0.1.5
    # change of files database (23-24)
    # sequence_entries now refers to clips
    IF current_version_less_than( 0, 1, 5 )=1 THEN

        ALTER TABLE sequence_entries ADD
          clip_id INT UNSIGNED AFTER sequence_entry_id;

        ALTER TABLE sequence_entries ADD CONSTRAINT
          FOREIGN KEY (clip_id) REFERENCES editshare.clips(clip_id)
            ON DELETE CASCADE;

        ALTER TABLE sequence_entries DROP FOREIGN KEY `sequence_entries_ibfk_1`;
        ALTER TABLE sequence_entries DROP COLUMN file_id;

        CALL set_version( 0, 1, 5 );
        CALL add_message( 'updated to 0.1.5' );

    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_0_1_6;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_6()
BEGIN

    # history
    # 0.1.5-->0.1.6
    # add sequence markers
    IF current_version_less_than( 0, 1, 6 )=1 THEN

        CREATE TABLE sequence_markers (
          entry_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          sequence_entry_id INT UNSIGNED NOT NULL,
          time VARCHAR(31),
          comment VARCHAR(255),
          color INT UNSIGNED,
          PRIMARY KEY (entry_id),
          FOREIGN KEY (sequence_entry_id) REFERENCES sequence_entries(sequence_entry_id) ON DELETE CASCADE
        );

        CALL set_version( 0, 1, 6 );
        CALL add_message( 'updated to 0.1.6' );

    END IF;

END $$
DELIMITER ;




DROP PROCEDURE IF EXISTS update_to_0_1_7;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_7()
BEGIN

    # history
    # 0.1.6-->0.1.7
    # merge geevs tape and playlist sequence parameters
    IF current_version_less_than( 0, 1, 7 )=1 THEN

        ALTER TABLE sequences ADD COLUMN video_frame_rate VARCHAR(10) AFTER thumbnail;
        ALTER TABLE sequences ADD COLUMN type ENUM('nle', 'tape', 'playlist') DEFAULT 'nle' AFTER thumbnail;

        CREATE TABLE sequence_tape (
          sequence_tape_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          sequence_id INT UNSIGNED NOT NULL,
          padding INT UNSIGNED,
          start_timecode VARCHAR(11),
          drop_frame BOOL DEFAULT false,
          PRIMARY KEY (sequence_tape_id),
          FOREIGN KEY sequence_id (sequence_id)
            REFERENCES sequences (sequence_id)
            ON DELETE CASCADE
        );

        ALTER TABLE sequence_entries ADD COLUMN color INT UNSIGNED AFTER comment;

        CREATE TABLE playlist_extended_entries (
          playlist_extended_entry_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          sequence_entry_id INT UNSIGNED NOT NULL,
          creation_date DATETIME,
          trigger_type INT UNSIGNED,
          PRIMARY KEY (playlist_extended_entry_id),
            FOREIGN KEY (sequence_entry_id)
            REFERENCES sequence_entries (sequence_entry_id)
            ON DELETE CASCADE
        );

        CREATE TABLE tape_extended_entries (
          tape_extended_entry_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          sequence_entry_id INT UNSIGNED NOT NULL,
          hold INT UNSIGNED,
          loop_count INT UNSIGNED,
          inpoint VARCHAR(11),
          PRIMARY KEY (tape_extended_entry_id),
            FOREIGN KEY (sequence_entry_id)
            REFERENCES sequence_entries (sequence_entry_id)
            ON DELETE CASCADE
        );

        CALL set_version( 0, 1, 7 );
        CALL add_message( 'updated to 0.1.7' );

    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_0_1_8;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_8()
BEGIN

    # history
    # 0.1.7-->0.1.8
    # merge geevs tape and playlist sequence parameters
    IF current_version_less_than( 0, 1, 8 )=1 THEN

        ALTER TABLE playlist_extended_entries ADD COLUMN type INT UNSIGNED AFTER creation_date;
        CALL set_version( 0, 1, 8 );
        CALL add_message( 'updated to 0.1.8' );

    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_0_1_9;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_9()
BEGIN

    # history
    # 0.1.8-->0.1.9
    # create events, link_events_projects and link_events_captures tables
    IF current_version_less_than( 0, 1, 9 )=1 THEN

        # Changes in this version are not needed
        # CALL create_events();
        # CALL link_events();
        CALL set_version( 0, 1, 9 );
        CALL add_message( 'updated to 0.1.9' );

    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_0_1_10;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_10()
BEGIN

    # history
    # 0.1.9-->0.1.10
    # drop events, link_events_projects tables and link_events_captures tables
    # alter user_folders table
    IF current_version_less_than( 0, 1, 10 )=1 THEN

        # wont exist in released versions but clean up just in case
        DROP TABLE IF EXISTS events;
        DROP TABLE IF EXISTS link_events_projects;
        DROP TABLE IF EXISTS link_events_captures;

        ALTER TABLE user_folders
            ADD COLUMN color INT UNSIGNED DEFAULT 0 AFTER name ,
            ADD COLUMN creation_date DATETIME DEFAULT NULL AFTER color;

        CALL set_version( 0, 1, 10 );
        CALL add_message( 'updated to 0.1.10' );

    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS migrate_link_sequence_owner_entries;
DELIMITER $$
CREATE PROCEDURE migrate_link_sequence_owner_entries()
BEGIN

    DECLARE done BOOL DEFAULT FALSE;
    DECLARE seqId, ownId, projId, foldId INT;
    DECLARE cur1 CURSOR FOR SELECT * FROM link_sequence_owner AS l;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

    OPEN cur1;

    copy_loop: LOOP

      FETCH cur1 INTO seqId, ownId, projId, foldId;

      IF done THEN
        LEAVE copy_loop;
      END IF;


      INSERT INTO link_project_items VALUES( 0, projId, ownId, foldId, NULL, NULL, seqId, NULL );

    END LOOP;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_0_1_11;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_11()
BEGIN

    # history
    # 0.1.10-->0.1.11
    # create link_project_items
    IF current_version_less_than( 0, 1, 11 )=1 THEN

        CREATE TABLE link_project_items (

              project_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,

              project_id   INT UNSIGNED,
              owner_id     INT UNSIGNED,
              folder_id    INT UNSIGNED,

              clip_id      INT UNSIGNED DEFAULT NULL,
              capture_id   INT UNSIGNED DEFAULT NULL,
              sequence_id  INT UNSIGNED DEFAULT NULL,
              logging_id   INT UNSIGNED DEFAULT NULL,

              PRIMARY KEY (project_item_id),

              FOREIGN KEY (project_id)   REFERENCES projects(project_id) ON DELETE CASCADE,
              FOREIGN KEY (owner_id)     REFERENCES owners(owner_id) ON DELETE CASCADE,
              FOREIGN KEY (folder_id)    REFERENCES user_folders(folder_id) ON DELETE CASCADE,

              FOREIGN KEY (clip_id)      REFERENCES editshare.clips(clip_id) ON DELETE CASCADE,
              FOREIGN KEY (capture_id)   REFERENCES editshare.chains(chain_id) ON DELETE CASCADE,
              FOREIGN KEY (sequence_id)  REFERENCES sequences(sequence_id) ON DELETE CASCADE,
              FOREIGN KEY (logging_id)   REFERENCES editshare.logging(entry_id) ON DELETE CASCADE
        );

        CALL migrate_link_sequence_owner_entries();

        DROP TABLE IF EXISTS link_sequence_owner;

        CALL set_version( 0, 1, 11 );
        CALL add_message( 'updated to 0.1.11' );

    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_0_1_12;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_12()
BEGIN

    # history
    # 0.1.11-->0.1.12
    # drop owner from user_folders
    IF current_version_less_than( 0, 1, 12 )=1 THEN

        ALTER TABLE user_folders DROP FOREIGN KEY `user_folders_ibfk_1`;
        ALTER TABLE user_folders DROP owner_id;

        CALL set_version( 0, 1, 12 );
        CALL add_message( 'updated to 0.1.12' );

    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_0_1_13;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_13()
BEGIN

    # history
    # 0.1.12-->0.1.13
    # link sequence entries (clip/in/out) to projects
    IF current_version_less_than( 0, 1, 13 )=1 THEN

        ALTER TABLE link_project_items ADD sequence_entry_id INT UNSIGNED DEFAULT NULL;

        ALTER TABLE link_project_items ADD CONSTRAINT
          FOREIGN KEY (sequence_entry_id) REFERENCES sequence_entries(sequence_entry_id)
            ON DELETE CASCADE;

        CALL set_version( 0, 1, 13 );
        CALL add_message( 'updated to 0.1.13' );

    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_0_1_14;
DELIMITER $$
CREATE PROCEDURE update_to_0_1_14()
BEGIN

    # history
    # 0.1.13-->0.1.14
    # create playlist_go_to_pointers
    IF current_version_less_than( 0, 1, 14 )=1 THEN

        CREATE TABLE `playlist_go_to_pointers` (
            `sequence_entry_id` INTEGER UNSIGNED NOT NULL,
            `entry_id` INTEGER UNSIGNED NOT NULL,
            CONSTRAINT `sequence_entry_id` FOREIGN KEY `sequence_entry_id` (`sequence_entry_id`)
            REFERENCES `sequence_entries` (`sequence_entry_id`)
            ON DELETE CASCADE,
            CONSTRAINT `entry_id` FOREIGN KEY `entry_id` (`entry_id`)
            REFERENCES `sequence_entries` (`sequence_entry_id`)
            ON DELETE CASCADE
            );

        CALL set_version( 0, 1, 14 );
        CALL add_message( 'updated to 0.1.14' );

    END IF;

END $$
DELIMITER ;

#   ###   ###
#     #   # #
#   ###   # #
#     #   # #
#   ### # ###

DROP PROCEDURE IF EXISTS update_to_3_0_0;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_0()
BEGIN

    # history
    # 0.1.14 --> 3.0.0
    # move thumbnail and columns out of the way to '_data' columns
    # and replace with id/name based columns
    IF current_version_less_than( 3, 0, 0 )=1 THEN
      CALL add_message( 'updating to 3.0.0' );

      ALTER TABLE sequences CHANGE thumbnail thumbnail_data MEDIUMBLOB;
      ALTER TABLE sequences ADD thumbnail VARCHAR(255) AFTER thumbnail_data;

      ALTER TABLE sequence_entries CHANGE thumbnail thumbnail_data MEDIUMBLOB;
      ALTER TABLE sequence_entries ADD thumbnail VARCHAR(255) AFTER thumbnail_data;

      CALL set_version( 3, 0, 0 );
      CALL add_message( 'updated to 3.0.0' );
    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_3_0_1;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_1()
BEGIN

    # history
    # 3.0.0 --> 3.0.1
    # project owners, members and permissions
    IF current_version_less_than( 3, 0, 1 )=1 THEN
      CALL add_message( 'updating to 3.0.1' );

      ALTER TABLE projects ADD owner_id INT UNSIGNED DEFAULT NULL;

      ALTER TABLE projects ADD is_readonly INT UNSIGNED DEFAULT 0;

      ALTER TABLE projects ADD is_public INT UNSIGNED DEFAULT 0;

      ALTER TABLE projects ADD CONSTRAINT
        FOREIGN KEY (owner_id) REFERENCES owners(owner_id)
          ON DELETE SET NULL;

      CREATE TABLE link_project_members (

        project_id   INT UNSIGNED NOT NULL,
        owner_id     INT UNSIGNED NOT NULL,

        FOREIGN KEY (project_id)   REFERENCES projects(project_id) ON DELETE CASCADE,
        FOREIGN KEY (owner_id)     REFERENCES owners(owner_id) ON DELETE CASCADE
      );

      # make all existing project public by default
      UPDATE projects SET is_public='1';

      CALL set_version( 3, 0, 1 );
      CALL add_message( 'updated to 3.0.1' );
    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_3_0_2;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_2()
BEGIN

    # history
    # 3.0.1 --> 3.0.2
    # project thumbnail and description
    IF current_version_less_than( 3, 0, 2 )=1 THEN
      CALL add_message( 'updating to 3.0.2' );

      ALTER TABLE projects ADD thumbnail VARCHAR(255);

      ALTER TABLE projects ADD description VARCHAR(2048);

      CALL set_version( 3, 0, 2 );
      CALL add_message( 'updated to 3.0.2' );
    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_3_0_3;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_3()
BEGIN

    # history
    # 3.0.2 --> 3.0.3
    # images and files in projects
    IF current_version_less_than( 3, 0, 3 )=1 THEN
      CALL add_message( 'updating to 3.0.3' );

      ALTER TABLE link_project_items ADD image_id INT UNSIGNED DEFAULT NULL;
      ALTER TABLE link_project_items ADD file_id INT UNSIGNED DEFAULT NULL;

      ALTER TABLE link_project_items ADD CONSTRAINT
        FOREIGN KEY (image_id) REFERENCES editshare.images(image_id)
            ON DELETE CASCADE;

      ALTER TABLE link_project_items ADD CONSTRAINT
        FOREIGN KEY (file_id) REFERENCES editshare.files(file_id)
            ON DELETE CASCADE;

      CALL set_version( 3, 0, 3 );
      CALL add_message( 'updated to 3.0.3' );
    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_3_0_4;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_4()
BEGIN

    # history
    # 3.0.3 --> 3.0.4
    # upates to sequence_entries
    IF current_version_less_than( 3, 0, 4 )=1 THEN
      CALL add_message( 'updating to 3.0.4' );

      # sequence entries
      ALTER TABLE sequence_entries ADD sequence_id INT UNSIGNED AFTER sequence_entry_id;
      ALTER TABLE sequence_entries ADD entry_index INT UNSIGNED AFTER sequence_id;

      ALTER TABLE sequence_entries ADD CONSTRAINT
        FOREIGN KEY (sequence_id) REFERENCES sequences(sequence_id)
            ON DELETE CASCADE;

      # project clips
      CREATE TABLE project_clips (
        project_clip_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
        project_id INT UNSIGNED,
        clip_id INT UNSIGNED,
        timecode_start VARCHAR(31),
        timecode_end VARCHAR(31),
        name VARCHAR( 255 ),
        thumbnail VARCHAR(255),

        PRIMARY KEY (project_clip_id),
        FOREIGN KEY (clip_id) REFERENCES editshare.clips(clip_id) ON DELETE CASCADE,
        FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
      );

      ALTER TABLE link_project_items ADD project_clip_id INT UNSIGNED DEFAULT NULL AFTER sequence_entry_id;

      ALTER TABLE link_project_items ADD CONSTRAINT
        FOREIGN KEY (project_clip_id) REFERENCES project_clips(project_clip_id)
            ON DELETE CASCADE;

      CALL set_version( 3, 0, 4 );
      CALL add_message( 'updated to 3.0.4' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_5;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_5()
BEGIN

    # history
    # 3.0.4 --> 3.0.5
    IF current_version_less_than( 3, 0, 5 )=1 THEN
      CALL add_message( 'updating to 3.0.5' );

      # Add unique ids
      ALTER TABLE sequences ADD COLUMN sequence_uuid VARCHAR(64) UNIQUE;
      ALTER TABLE sequence_entries ADD COLUMN sequence_entry_uuid VARCHAR(64) UNIQUE;
      ALTER TABLE projects ADD COLUMN project_uuid VARCHAR(64) UNIQUE;
      ALTER TABLE user_folders ADD COLUMN folder_uuid VARCHAR(64) UNIQUE;

      # Add indexes
      ALTER TABLE sequences ADD INDEX( sequence_uuid );
      ALTER TABLE sequence_entries ADD INDEX( sequence_entry_uuid );
      ALTER TABLE projects ADD INDEX( project_uuid );
      ALTER TABLE user_folders ADD INDEX( folder_uuid );

      CALL set_version( 3, 0, 5 );
      CALL add_message( 'updated to 3.0.5' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_6;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_6()
BEGIN

    # history
    # 3.0.5 --> 3.0.6
    IF current_version_less_than( 3, 0, 6 )=1 THEN
      CALL add_message( 'updating to 3.0.6' );

      # Add unique ids
      ALTER TABLE project_clips ADD COLUMN project_clip_uuid VARCHAR(64) UNIQUE;
      ALTER TABLE link_project_items ADD COLUMN project_item_uuid VARCHAR(64) UNIQUE;
      ALTER TABLE sequence_markers ADD COLUMN sequence_marker_uuid VARCHAR(64) UNIQUE;

      # Add indexes
      ALTER TABLE project_clips ADD INDEX( project_clip_uuid );
      ALTER TABLE link_project_items ADD INDEX( project_item_uuid );
      ALTER TABLE sequence_markers ADD INDEX( sequence_marker_uuid );

      CALL set_version( 3, 0, 6 );
      CALL add_message( 'updated to 3.0.6' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_7;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_7()
BEGIN

    # history
    # 3.0.6 --> 3.0.7
    IF current_version_less_than( 3, 0, 7 )=1 THEN
      CALL add_message( 'updating to 3.0.7' );

      # Add link to shared resources
      ALTER TABLE link_project_items ADD COLUMN shared_resource_id INT UNSIGNED DEFAULT NULL;

      ALTER TABLE link_project_items ADD CONSTRAINT
        FOREIGN KEY (shared_resource_id) REFERENCES editshare.shared_resources(shared_resource_id)
            ON DELETE CASCADE;

      CALL set_version( 3, 0, 7 );
      CALL add_message( 'updated to 3.0.7' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_8;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_8()
BEGIN

    # history
    # 3.0.7 --> 3.0.8
    IF current_version_less_than( 3, 0, 8 )=1 THEN
        CALL add_message( 'updating to 3.0.8' );

        # Add revision information to sequences
        ALTER TABLE sequences ADD COLUMN last_modified DATETIME;
        ALTER TABLE sequences ADD COLUMN revision INT UNSIGNED NOT NULL DEFAULT 0;

        # add cutlist to enum
        ALTER TABLE sequences CHANGE `type`  `type` ENUM('nle','tape','playlist','cutlist') DEFAULT 'nle';

        # Add link for playlists in projects
        ALTER TABLE link_project_items ADD COLUMN playlist_id INT UNSIGNED DEFAULT NULL;

        ALTER TABLE link_project_items ADD CONSTRAINT
        FOREIGN KEY (playlist_id) REFERENCES flow_playlists.playlists(playlist_id)
            ON DELETE CASCADE;

        CALL set_version( 3, 0, 8 );
        CALL add_message( 'updated to 3.0.8' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_9;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_9()
BEGIN
    # promoting sequence to assets
    IF current_version_less_than( 3, 0, 9 )=1 THEN
      CALL add_message( 'updating to 3.0.9' );

      # files
      ALTER TABLE sequences ADD asset_id INT UNSIGNED AFTER sequence_id,
          ADD CONSTRAINT
              FOREIGN KEY (asset_id) REFERENCES editshare.assets(asset_id)
                  ON DELETE SET NULL;

      # thumbnail moved onto asset.  leave the original ones behind for migration
      ALTER TABLE sequences CHANGE thumbnail old_thumbnail VARCHAR(255);

      # sequence_uuid, last_modified and revision are supplied by asset now
      ALTER TABLE sequences DROP COLUMN sequence_uuid;
      ALTER TABLE sequences DROP COLUMN last_modified;
      ALTER TABLE sequences DROP COLUMN revision;

      CALL set_version( 3, 0, 9 );
      CALL add_message( 'updated to 3.0.9' );
    END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_10;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_10()
BEGIN
    # promoting sequence to assets
    IF current_version_less_than( 3, 0, 10 )=1 THEN
      CALL add_message( 'updating to 3.0.10' );

      # Add sequence aaf id (uuid)
      ALTER TABLE sequences ADD COLUMN aaf_id VARCHAR(64) DEFAULT NULL;

      CALL set_version( 3, 0, 10 );
      CALL add_message( 'updated to 3.0.10' );
    END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_11;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_11()
BEGIN
    # Add new sequence representations
    IF current_version_less_than( 3, 0, 11 )=1 THEN
      CALL add_message( 'updating to 3.0.11' );

      # rename aaf_id to aaf
      ALTER TABLE sequences CHANGE aaf_id aaf VARCHAR(64) DEFAULT NULL;

      # Add new columns to represent the sequence in different ways
      ALTER TABLE sequences ADD COLUMN lwks_edit VARCHAR(64) DEFAULT NULL;
      ALTER TABLE sequences ADD COLUMN proxy VARCHAR(64) DEFAULT NULL;

      CALL set_version( 3, 0, 11 );
      CALL add_message( 'updated to 3.0.11' );
    END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_12;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_12()
BEGIN
    # Add date/time of last update of items (so we know which one is newest)
    IF current_version_less_than( 3, 0, 12 )=1 THEN
      CALL add_message( 'updating to 3.0.12' );

      ALTER TABLE sequences ADD aaf_write_time DATETIME AFTER aaf;
      ALTER TABLE sequences ADD lwks_edit_write_time DATETIME AFTER lwks_edit;
      ALTER TABLE sequences ADD proxy_write_time DATETIME AFTER proxy;

      CALL set_version( 3, 0, 12 );
      CALL add_message( 'updated to 3.0.12' );
    END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_13;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_13()
BEGIN
    # Explicit link of sequence markers to sequences
    # Extra metadata about sequences
    IF current_version_less_than( 3, 0, 13 )=1 THEN
      CALL add_message( 'updating to 3.0.13' );

      ALTER TABLE sequence_markers ADD sequence_id INT UNSIGNED DEFAULT NULL AFTER entry_id,
        ADD CONSTRAINT
            FOREIGN KEY (sequence_id) REFERENCES sequences(sequence_id)
                  ON DELETE CASCADE;

      ALTER TABLE sequence_markers CHANGE sequence_entry_id sequence_entry_id INT UNSIGNED DEFAULT NULL;

      ALTER TABLE sequences ADD timecode_start VARCHAR(31) AFTER proxy_write_time;
      ALTER TABLE sequences ADD timecode_end VARCHAR(31) AFTER timecode_start;

      CALL set_version( 3, 0, 13 );
      CALL add_message( 'updated to 3.0.13' );
    END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_14;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_14()
BEGIN
    # Add owner_id to sequences
    IF current_version_less_than( 3, 0, 14 )=1 THEN
      CALL add_message( 'updating to 3.0.14' );

      ALTER TABLE sequences ADD owner_id INT UNSIGNED DEFAULT NULL AFTER asset_id,
        ADD CONSTRAINT
          FOREIGN KEY (owner_id) REFERENCES owners(owner_id)
            ON DELETE SET NULL;

      CALL set_version( 3, 0, 14 );
      CALL add_message( 'updated to 3.0.14' );
    END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_15;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_15()
BEGIN
    # Make sequence_markers like editshare.logging
    IF current_version_less_than( 3, 0, 15 )=1 THEN
      CALL add_message( 'updating to 3.0.15' );


      # add new column
      ALTER TABLE sequence_markers ADD thumbnail varchar(255) DEFAULT NULL AFTER color;
      # rename 'time' to 'in_time'
      ALTER TABLE sequence_markers CHANGE time in_time VARCHAR(31) DEFAULT NULL AFTER thumbnail;
      # add new column
      ALTER TABLE sequence_markers ADD out_time VARCHAR(31) DEFAULT NULL AFTER in_time;
      # expand 'comment'
      ALTER TABLE sequence_markers CHANGE comment comment VARCHAR(2048) DEFAULT NULL AFTER out_time;
      # add new column
      ALTER TABLE sequence_markers ADD rating TINYINT UNSIGNED DEFAULT NULL AFTER comment;
      # add new column
      ALTER TABLE sequence_markers ADD name VARCHAR(255) DEFAULT NULL AFTER rating;
      # add new column
      ALTER TABLE sequence_markers ADD user VARCHAR(255) DEFAULT NULL AFTER name;
      # add new column
      ALTER TABLE sequence_markers ADD source ENUM ('user', 'qc', 'import', 'ingest' ) DEFAULT 'user' AFTER user;
      # add new column
      ALTER TABLE sequence_markers ADD source_metadata TEXT DEFAULT NULL AFTER source;

      # Add indexes
      ALTER TABLE sequence_markers ADD INDEX( color );

      ALTER TABLE sequence_markers ADD FULLTEXT INDEX idx_in_time (in_time);
      ALTER TABLE sequence_markers ADD FULLTEXT INDEX idx_out_time (out_time);
      ALTER TABLE sequence_markers ADD FULLTEXT INDEX idx_comment (comment);
      ALTER TABLE sequence_markers ADD FULLTEXT INDEX idx_name (name);
      ALTER TABLE sequence_markers ADD FULLTEXT INDEX idx_user (user);

      CALL set_version( 3, 0, 15 );
      CALL add_message( 'updated to 3.0.15' );
    END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_16;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_16()
BEGIN

    # history
    # 3.0.15 --> 3.0.16
    # project editors
    IF current_version_less_than( 3, 0, 16 )=1 THEN
      CALL add_message( 'updating to 3.0.16' );

      CREATE TABLE link_project_editors (

        project_id   INT UNSIGNED NOT NULL,
        owner_id     INT UNSIGNED NOT NULL,

        FOREIGN KEY (project_id)   REFERENCES projects(project_id) ON DELETE CASCADE,
        FOREIGN KEY (owner_id)     REFERENCES owners(owner_id) ON DELETE CASCADE
      );

      CALL set_version( 3, 0, 16 );
      CALL add_message( 'updated to 3.0.16' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_17;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_17()
BEGIN

    # Add column to user folder to store extended properties
    IF current_version_less_than( 3, 0, 17 )=1 THEN
      CALL add_message( 'updating to 3.0.17' );

        ALTER TABLE user_folders ADD COLUMN json_metadata MEDIUMBLOB;

      CALL set_version( 3, 0, 17 );
      CALL add_message( 'updated to 3.0.17' );
    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS update_to_3_0_18;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_18()
BEGIN

    # add new marker source fields
    IF current_version_less_than( 3, 0, 18 )=1 THEN
      CALL add_message( 'updating to 3.0.18' );

        # have to use a 'COPY' here to prevent index issues
        ALTER TABLE sequence_markers MODIFY source
            ENUM ('user', 'qc', 'import', 'ingest', 'audio_metadata',
                  'video_metadata' ) DEFAULT 'user', ALGORITHM=COPY;

      CALL set_version( 3, 0, 18 );
      CALL add_message( 'updated to 3.0.18' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_19;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_19()
BEGIN

    IF current_version_less_than( 3, 0, 19 )=1 THEN
      CALL add_message( 'updating to 3.0.19' );

        # Offset information when in a multicam bin
        ALTER TABLE project_clips ADD COLUMN multicam_offset_data VARCHAR(255);

        # When present the bin is a multicam bin
        ALTER TABLE user_folders ADD COLUMN multicam_sync_method VARCHAR(255);

      CALL set_version( 3, 0, 19 );
      CALL add_message( 'updated to 3.0.19' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_20;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_20()
BEGIN

    IF current_version_less_than( 3, 0, 20 )=1 THEN
      CALL add_message( 'updating to 3.0.20' );

      # have to use a 'COPY' here to prevent index issues
      ALTER TABLE sequence_markers MODIFY source
          ENUM ('user', 'qc', 'import', 'ingest', 'audio_metadata',
                'video_metadata', 'review_approve') DEFAULT 'user', ALGORITHM=COPY;

      ALTER TABLE sequence_markers ADD COLUMN approved INT UNSIGNED DEFAULT NULL;


      CALL set_version( 3, 0, 20 );
      CALL add_message( 'updated to 3.0.20' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_21;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_21()
BEGIN

    IF current_version_less_than( 3, 0, 21 )=1 THEN
      CALL add_message( 'updating to 3.0.21' );

      ALTER TABLE projects ADD creation_date datetime NULL AFTER description;
      ALTER TABLE projects ADD last_modified_date datetime NULL AFTER creation_date;

      UPDATE projects
          INNER JOIN editshare.asset_events as e
          ON projects.project_id = e.asset_id and e.type = 'project_added'
      SET
          creation_date = time;

      UPDATE projects
          INNER JOIN (SELECT asset_id, MAX(time) as last_modified_event_time
                      FROM editshare.asset_events WHERE type like 'project_%' GROUP BY asset_id) AS e
          ON projects.project_id = e.asset_id
      SET
          last_modified_date = last_modified_event_time;

      CALL set_version( 3, 0, 21 );
      CALL add_message( 'updated to 3.0.21' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_22;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_22()
BEGIN

    IF current_version_less_than( 3, 0, 22 )=1 THEN
      CALL add_message( 'updating to 3.0.22' );

      ALTER TABLE projects ADD deleted_date datetime NULL AFTER last_modified_date;

      CALL set_version( 3, 0, 22 );
      CALL add_message( 'updated to 3.0.22' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_23;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_23()
BEGIN
    # Add created date
    IF current_version_less_than( 3, 0, 23 )=1 THEN
      CALL add_message( 'updating to 3.0.23' );

      ALTER TABLE sequence_markers ADD created_date DATETIME DEFAULT NULL AFTER out_time;

      CALL set_version( 3, 0, 23 );
      CALL add_message( 'updated to 3.0.23' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_24;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_24()
BEGIN

    IF current_version_less_than( 3, 0, 24 )=1 THEN
      CALL add_message( 'updating to 3.0.24' );

      CREATE TABLE sequence_markers_comments (
        comment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
        entry_id INT UNSIGNED DEFAULT NULL,

        created DATETIME,
        edited DATETIME,
        user VARCHAR(255),
        comment VARCHAR(2048),
        hasBeenEdited BOOL DEFAULT '0',
        replying_to INT UNSIGNED DEFAULT NULL,
        resolved BOOL DEFAULT '0',

        PRIMARY KEY (comment_id),
        FOREIGN KEY (entry_id) REFERENCES sequence_markers(entry_id) ON DELETE CASCADE
      );

      CALL set_version( 3, 0, 24 );
      CALL add_message( 'updated to 3.0.24' );
    END IF;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS update_to_3_0_25;
DELIMITER $$
CREATE PROCEDURE update_to_3_0_25()
BEGIN

    IF current_version_less_than( 3, 0, 25 )=1 THEN
      CALL add_message( 'updating to 3.0.25' );

      # Add XML storage of sequence data
      ALTER TABLE sequences ADD COLUMN xml VARCHAR(64) DEFAULT NULL AFTER aaf_write_time;
      ALTER TABLE sequences ADD COLUMN xml_write_time DATETIME AFTER xml;
      

      CALL set_version( 3, 0, 25 );
      CALL add_message( 'updated to 3.0.25' );
    END IF;

END $$
DELIMITER ;

#
# builds the entire database from scratch
#
DROP PROCEDURE IF EXISTS build_database;
DELIMITER $$
CREATE PROCEDURE build_database()
BEGIN

## Permissions
# The following tables contain information about ownership, sharing and permissions

# users/owners
# we maintain an independent list of users/names to enforce separation from lifetime
# of flow admin database and flow admin users
CREATE TABLE owners (
  owner_id INT UNSIGNED NOT NULL AUTO_INCREMENT,

  # owner
  name VARCHAR( 255 ) NOT NULL UNIQUE,

  PRIMARY KEY (owner_id)
);

## Data
# The following tables contain the basic information about sequences

# a named sequence
# is just an ordered collection of files
CREATE TABLE sequences (
  sequence_id INT UNSIGNED NOT NULL AUTO_INCREMENT,

  # associated asset
  asset_id INT UNSIGNED,

  # owner id in owners table
  owner_id INT UNSIGNED DEFAULT NULL,

  # user visible name
  name VARCHAR( 255 ),

  # sequence type
  type ENUM('nle','tape','playlist','cutlist') DEFAULT 'nle',

  # video frame rate
  video_frame_rate VARCHAR(10),

  # aaf representation
  aaf VARCHAR(64) DEFAULT NULL,
  aaf_write_time DATETIME,

  # xml representation
  xml VARCHAR(64) DEFAULT NULL,
  xml_write_time DATETIME,

  # Lightworks edit representation
  lwks_edit VARCHAR(64) DEFAULT NULL,
  lwks_edit_write_time DATETIME,

  # proxy representation
  proxy VARCHAR(64) DEFAULT NULL,
  proxy_write_time DATETIME,

  # start and end timecode of the sequence (inclusive)
  # optional
  timecode_start VARCHAR(31) DEFAULT NULL,
  timecode_end VARCHAR(31) DEFAULT NULL,

  PRIMARY KEY (sequence_id),
  FOREIGN KEY (owner_id)  REFERENCES owners(owner_id) ON DELETE SET NULL,
  FOREIGN KEY (asset_id) REFERENCES editshare.assets(asset_id) ON DELETE CASCADE
);

CREATE TABLE sequence_tape (
  sequence_tape_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sequence_id INT UNSIGNED NOT NULL,
  padding INT UNSIGNED,
  start_timecode VARCHAR(11),
  drop_frame BOOL DEFAULT false,
  PRIMARY KEY (sequence_tape_id),
    FOREIGN KEY sequence_id (sequence_id)
    REFERENCES sequences (sequence_id)
    ON DELETE CASCADE
);

# an entry in a sequence
CREATE TABLE sequence_entries (
  sequence_entry_id INT UNSIGNED NOT NULL AUTO_INCREMENT,

  # sequence it is part of
  sequence_id INT UNSIGNED,

  # order within the sequence
  entry_index INT UNSIGNED,

  # identifier of clip.
  clip_id INT UNSIGNED,

  # section of the clip to use within the sequence (inclusive)
  timecode_start VARCHAR(31),
  timecode_end VARCHAR(31),

  # user visible name
  name VARCHAR( 255 ),

  # poster frame for the entry
  thumbnail VARCHAR(255),

  # user comment
  comment VARCHAR(255),

  # color in ui
  color INT UNSIGNED,

  # Unique id
  sequence_entry_uuid VARCHAR(64),
  UNIQUE INDEX (sequence_entry_uuid),

  PRIMARY KEY (sequence_entry_id),
  FOREIGN KEY (clip_id) REFERENCES editshare.clips(clip_id) ON DELETE CASCADE,
  FOREIGN KEY (sequence_id) REFERENCES sequences(sequence_id) ON DELETE CASCADE
);

# associates entries with a sequence
# obsoleted in Flow 3 - sequence_id and index goes into sequence_entry table
CREATE TABLE link_sequence_entries (
  sequence_id INT UNSIGNED,

  sequence_entry_id  INT UNSIGNED,

  # order within the sequence
  entry_index INT UNSIGNED,

  FOREIGN KEY (sequence_id) REFERENCES sequences(sequence_id) ON DELETE CASCADE,
  FOREIGN KEY (sequence_entry_id) REFERENCES sequence_entries(sequence_entry_id) ON DELETE CASCADE
);

CREATE TABLE playlist_extended_entries (
  playlist_extended_entry_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sequence_entry_id INT UNSIGNED NOT NULL,
  creation_date DATETIME,
  type INT UNSIGNED,
  trigger_type INT UNSIGNED,

  PRIMARY KEY (playlist_extended_entry_id),
    FOREIGN KEY (sequence_entry_id) REFERENCES sequence_entries(sequence_entry_id)
    ON DELETE CASCADE
);

CREATE TABLE tape_extended_entries (
  tape_extended_entry_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sequence_entry_id INT UNSIGNED NOT NULL,
  hold INT UNSIGNED,
  loop_count INT UNSIGNED,
  inpoint VARCHAR(11),

  PRIMARY KEY (tape_extended_entry_id),
    FOREIGN KEY (sequence_entry_id)
    REFERENCES sequence_entries(sequence_entry_id)
    ON DELETE CASCADE
);

## Markers
### Can be linked to a specific sequence entry (and therefore move with the sequence entries)
### or can be linked to an absolute timecode in the sequence (and therefore stay at a fixed offset)
### Should be pretty much the same as editshare.logging - we want the same api
##
CREATE TABLE sequence_markers (
  entry_id INT UNSIGNED NOT NULL AUTO_INCREMENT,

  # linked sequence
  sequence_id INT UNSIGNED DEFAULT NULL,

  # linked sequence entry (if any)
  sequence_entry_id INT UNSIGNED DEFAULT NULL,

  # as rgb
  color INT UNSIGNED,

  thumbnail VARCHAR(255),

  # time is an absolute time in the sequence entry clip (id sequence_entry_id IS NOT NULL) OR in the sequence itself
  in_time VARCHAR(31),
  out_time VARCHAR(31),
  created_date DATETIME DEFAULT NULL,
  comment VARCHAR(2048),
  rating TINYINT UNSIGNED,
  name VARCHAR(255),
  user VARCHAR(255),

  # source - duplicated in editshare.logging
  source ENUM ('user', 'qc', 'import', 'ingest', 'audio_metadata', 'video_metadata', 'review_approve' ) DEFAULT 'user',

  # additional metadata - JSON blob
  source_metadata TEXT DEFAULT NULL,
  approved INT UNSIGNED DEFAULT NULL,

  sequence_marker_uuid VARCHAR(64),
  UNIQUE INDEX (sequence_marker_uuid),

  INDEX (color),
  FULLTEXT idx_in_time (in_time),
  FULLTEXT idx_out_time (out_time),
  FULLTEXT idx_comment (comment),
  FULLTEXT idx_name (name),
  FULLTEXT idx_user (user),

  PRIMARY KEY (entry_id),
  FOREIGN KEY (sequence_id) REFERENCES sequences(sequence_id) ON DELETE CASCADE,
  FOREIGN KEY (sequence_entry_id) REFERENCES sequence_entries(sequence_entry_id) ON DELETE CASCADE
);

# Comment on a sequence_markers entry.
#
CREATE TABLE sequence_markers_comments (
  comment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  entry_id INT UNSIGNED DEFAULT NULL,

  created DATETIME,
  edited DATETIME,
  user VARCHAR(255),
  comment VARCHAR(2048),
  hasBeenEdited BOOL DEFAULT '0',
  replying_to INT UNSIGNED DEFAULT NULL,
  resolved BOOL DEFAULT '0',

  PRIMARY KEY (comment_id),
  FOREIGN KEY (entry_id) REFERENCES sequence_markers(entry_id) ON DELETE CASCADE
);

CREATE TABLE projects (
  project_id INT UNSIGNED NOT NULL AUTO_INCREMENT,

  # project
  name VARCHAR( 255 ) NOT NULL UNIQUE,

  # owner
  owner_id INT UNSIGNED,

  is_readonly INT UNSIGNED DEFAULT 0,

  is_public INT UNSIGNED DEFAULT 0,

  thumbnail VARCHAR(255),

  description VARCHAR(2048),

  creation_date DATETIME,

  last_modified_date DATETIME,

  deleted_date DATETIME,

  # Unique id
  project_uuid VARCHAR(64),
  UNIQUE INDEX (project_uuid),

  FOREIGN KEY (owner_id)  REFERENCES owners(owner_id) ON DELETE SET NULL,

  PRIMARY KEY (project_id)
);

# associate users with permissions to see projects
CREATE TABLE link_project_members (

  project_id   INT UNSIGNED NOT NULL,
  owner_id     INT UNSIGNED NOT NULL,

  FOREIGN KEY (project_id)   REFERENCES projects(project_id) ON DELETE CASCADE,
  FOREIGN KEY (owner_id)     REFERENCES owners(owner_id) ON DELETE CASCADE
);

# associate users with permissions to edit projects
CREATE TABLE link_project_editors (

  project_id   INT UNSIGNED NOT NULL,
  owner_id     INT UNSIGNED NOT NULL,

  FOREIGN KEY (project_id)   REFERENCES projects(project_id) ON DELETE CASCADE,
  FOREIGN KEY (owner_id)     REFERENCES owners(owner_id) ON DELETE CASCADE
);

# folder structure for bins
CREATE TABLE user_folders (
    folder_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    project_id INT UNSIGNED NOT NULL,

    # folder name
    name VARCHAR( 255 ),

    color INT UNSIGNED DEFAULT 0,

    creation_date DATETIME DEFAULT NULL,

    # folder parent, can be NULL for root
    parent_id INT UNSIGNED,

    # Unique id
    folder_uuid VARCHAR(64),
    UNIQUE INDEX (folder_uuid),

    # Extra metadata stored in a JSON blob
    json_metadata MEDIUMBLOB,

    # When present the bin is a multicam bin
    multicam_sync_method VARCHAR(255),

    PRIMARY KEY (folder_id),

    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,

    # deleting a parent folder should delete the children too
    FOREIGN KEY (parent_id) REFERENCES user_folders(folder_id) ON DELETE CASCADE
);

# \TODO groups, permissions etc etc


CREATE TABLE project_clips (
  project_clip_id INT UNSIGNED NOT NULL AUTO_INCREMENT,

  # project it is part of - also inferred from link table but useful here too for searching
  project_id INT UNSIGNED,

  # identifier of clip.
  clip_id INT UNSIGNED,

  # section of the clip
  timecode_start VARCHAR(31),
  timecode_end VARCHAR(31),

  # user visible name
  name VARCHAR( 255 ),

  # poster frame for the entry
  thumbnail VARCHAR(255),

  # Unique id
  project_clip_uuid VARCHAR(64),
  UNIQUE INDEX (project_clip_uuid),

  # Offset information when in a multicam bin
  multicam_offset_data VARCHAR(255),

  PRIMARY KEY (project_clip_id),
  FOREIGN KEY (clip_id) REFERENCES editshare.clips(clip_id) ON DELETE CASCADE,
  FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);

CREATE TABLE link_project_items (

    project_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,

    project_id   INT UNSIGNED,
    owner_id     INT UNSIGNED,
    folder_id    INT UNSIGNED,

    clip_id      INT UNSIGNED DEFAULT NULL,
    capture_id   INT UNSIGNED DEFAULT NULL,
    sequence_id  INT UNSIGNED DEFAULT NULL,
    logging_id   INT UNSIGNED DEFAULT NULL,
    sequence_entry_id INT UNSIGNED DEFAULT NULL,
    project_clip_id INT UNSIGNED DEFAULT NULL,
    image_id     INT UNSIGNED DEFAULT NULL,
    file_id      INT UNSIGNED DEFAULT NULL,
    shared_resource_id INT UNSIGNED DEFAULT NULL,
    playlist_id  INT UNSIGNED DEFAULT NULL,

    project_item_uuid VARCHAR(64),
    UNIQUE INDEX (project_item_uuid),

    PRIMARY KEY (project_item_id),

    FOREIGN KEY (project_id)   REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (owner_id)     REFERENCES owners(owner_id) ON DELETE CASCADE,
    FOREIGN KEY (folder_id)    REFERENCES user_folders(folder_id) ON DELETE CASCADE,

    FOREIGN KEY (clip_id)      REFERENCES editshare.clips(clip_id) ON DELETE CASCADE,
    FOREIGN KEY (capture_id)   REFERENCES editshare.chains(chain_id) ON DELETE CASCADE,
    FOREIGN KEY (sequence_id)  REFERENCES sequences(sequence_id) ON DELETE CASCADE,
    FOREIGN KEY (logging_id)   REFERENCES editshare.logging(entry_id) ON DELETE CASCADE,
    FOREIGN KEY (image_id)     REFERENCES editshare.images(image_id) ON DELETE CASCADE,
    FOREIGN KEY (file_id)      REFERENCES editshare.files(file_id) ON DELETE CASCADE,
    FOREIGN KEY (sequence_entry_id)  REFERENCES sequence_entries(sequence_entry_id) ON DELETE CASCADE,
    FOREIGN KEY (project_clip_id)  REFERENCES project_clips(project_clip_id) ON DELETE CASCADE,
    FOREIGN KEY (shared_resource_id)  REFERENCES editshare.shared_resources(shared_resource_id) ON DELETE CASCADE,
    FOREIGN KEY (playlist_id)  REFERENCES flow_playlists.playlists(playlist_id) ON DELETE CASCADE
);

CREATE TABLE binance_trans (

  trans_id INTEGER UNSIGNED NOT NULL,

  entry_id INTEGER UNSIGNED NOT NULL,

  CONSTRAINT sequence_entry_id FOREIGN KEY sequence_entry_id(sequence_entry_id)
    REFERENCES sequence_entries(sequence_entry_id)
    ON DELETE CASCADE,
  CONSTRAINT entry_id FOREIGN KEY entry_id(entry_id)
    REFERENCES sequence_entries(sequence_entry_id)
    ON DELETE CASCADE
);

END $$
DELIMITER ;
#
# end of build_database
#



CALL create_or_update_database();



DROP FUNCTION IF EXISTS table_exists;
DROP PROCEDURE IF EXISTS add_message;
DROP FUNCTION IF EXISTS major;
DROP FUNCTION IF EXISTS minor;
DROP FUNCTION IF EXISTS revision;
DROP FUNCTION IF EXISTS current_version_less_than;
DROP PROCEDURE IF EXISTS set_version;


DROP PROCEDURE IF EXISTS migrate_link_sequence_owner_entries;

DROP PROCEDURE IF EXISTS create_or_update_database;
DROP PROCEDURE IF EXISTS build_database;
DROP PROCEDURE IF EXISTS update_database;
DROP PROCEDURE IF EXISTS update_to_0_1_3;
DROP PROCEDURE IF EXISTS update_to_0_1_4;
DROP PROCEDURE IF EXISTS update_to_0_1_5;
DROP PROCEDURE IF EXISTS update_to_0_1_6;
DROP PROCEDURE IF EXISTS update_to_0_1_7;
DROP PROCEDURE IF EXISTS update_to_0_1_8;
DROP PROCEDURE IF EXISTS update_to_0_1_9;
DROP PROCEDURE IF EXISTS update_to_0_1_10;
DROP PROCEDURE IF EXISTS update_to_0_1_11;
DROP PROCEDURE IF EXISTS update_to_0_1_12;
DROP PROCEDURE IF EXISTS update_to_0_1_13;
DROP PROCEDURE IF EXISTS update_to_0_1_14;
DROP PROCEDURE IF EXISTS update_to_3_0_0;
DROP PROCEDURE IF EXISTS update_to_3_0_1;
DROP PROCEDURE IF EXISTS update_to_3_0_2;
DROP PROCEDURE IF EXISTS update_to_3_0_3;
DROP PROCEDURE IF EXISTS update_to_3_0_4;
DROP PROCEDURE IF EXISTS update_to_3_0_5;
DROP PROCEDURE IF EXISTS update_to_3_0_6;
DROP PROCEDURE IF EXISTS update_to_3_0_7;
DROP PROCEDURE IF EXISTS update_to_3_0_8;
DROP PROCEDURE IF EXISTS update_to_3_0_9;
DROP PROCEDURE IF EXISTS update_to_3_0_10;
DROP PROCEDURE IF EXISTS update_to_3_0_11;
DROP PROCEDURE IF EXISTS update_to_3_0_12;
DROP PROCEDURE IF EXISTS update_to_3_0_13;
DROP PROCEDURE IF EXISTS update_to_3_0_14;
DROP PROCEDURE IF EXISTS update_to_3_0_15;
DROP PROCEDURE IF EXISTS update_to_3_0_16;
DROP PROCEDURE IF EXISTS update_to_3_0_17;
DROP PROCEDURE IF EXISTS update_to_3_0_18;
DROP PROCEDURE IF EXISTS update_to_3_0_19;
DROP PROCEDURE IF EXISTS update_to_3_0_20;
DROP PROCEDURE IF EXISTS update_to_3_0_21;
DROP PROCEDURE IF EXISTS update_to_3_0_22;
DROP PROCEDURE IF EXISTS update_to_3_0_23;
DROP PROCEDURE IF EXISTS update_to_3_0_24;
DROP PROCEDURE IF EXISTS update_to_3_0_25;

#
# updated the revision? please update versions in:
#   major(), minor(), revision() above

