
-- c_numbering
DELETE FROM c_numbering;
INSERT INTO c_numbering (numbering_type,parent_cd,seq,max_seq,cd_len) VALUES ('UR','',1,999,3);

-- c_type
DELETE FROM c_type;
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('SS01NW','SS','NW','New',1);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('SS02AC','SS','AC','Active',2);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('SS03NA','SS','NA','Not active',3);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('SS04CL','SS','CL','Closed',4);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('SU01MG','SU','MG','Manager',1);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('SU02RV','SU','RV','Reviewer',2);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('SU03WK','SU','WK','Worker',3);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('SU04WT','SU','WT','Watcher',4);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TR01RR','TR','RR','Related',1);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TR02PR','TR','PR','Parent',2);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TR03CH','TR','CH','Child',3);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TR04LR','TR','LR','Locks',4);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TS01NW','TS','NW','New',1);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TS02PC','TS','PC','In Progress',2);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TS03FB','TS','FB','Feedback',3);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TS04PD','TS','PD','Pending',4);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TS05RV','TS','RV','Review',5);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TS06CL','TS','CL','Closed',6);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TT01TS','TT','TS','Task',1);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TT02BG','TT','BG','Bug',2);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TT03PJ','TT','PJ','Project',3);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TU01RV','TU','RV','Reviewer',3);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TU02WK','TU','WK','Worker',1);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TU03WT','TU','WT','Watcher',2);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TP01LS','TP','LS','Lowest', 1);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TP02LW','TP','LW','Lower', 2);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TP03NM','TP','NM','Medium', 3);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TP04HG','TP','HG','Higher', 4);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TP05HS','TP','HS','Highest', 5);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('TP06UR','TP','UR','Urgent!', 6);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('WT01PL','WT','PL','Plan', 1);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('WT02AC','WT','AC','Actual', 2);
INSERT INTO c_type (type_cd,type_category,type_part,name,sort_order) VALUES ('WT03PJ','WT','PJ','Project', 3);

-- m_user
DELETE FROM m_user;
INSERT INTO m_user (user_cd,name) VALUES ('001','admin');

-- c_code_def
DELETE FROM c_code_def;
INSERT INTO c_code_def (code_type,cd_len,max_seq) VALUES ('SL','2','99');
INSERT INTO c_code_def (code_type,cd_len,max_seq) VALUES ('TG','3','999');
INSERT INTO c_code_def (code_type,cd_len,max_seq) VALUES ('UR','3','999');
INSERT INTO c_code_def (code_type,cd_len,max_seq) VALUES ('TK','4','9999');

