
drop function if exists sp_numbering(varchar(2), varchar(20));

create function sp_numbering(
p_numbering_type varchar(2), 
p_parent_cd varchar(20))
returns varchar(2) as $$

declare
	row_cnt int;
	r_parent_cd text;
	r_seq bigint;
	r_max_seq bigint;
	r_cd_len int;
	result_cd text;
begin
	select into row_cnt count(*) from c_numbering
	where numbering_type = p_numbering_type
	and parent_cd = p_parent_cd;

	if row_cnt = 0 then
		INSERT INTO c_numbering(numbering_type, parent_cd, seq, max_seq, cd_len)
		(select code_type, p_parent_cd, 0, max_seq, cd_len from c_code_def where code_type = p_numbering_type);
	end if;


	select 
	into
	r_parent_cd,
	r_seq,
	r_max_seq,
	r_cd_len

	parent_cd,
	seq,
	max_seq,
	cd_len
	from c_numbering
	where numbering_type = p_numbering_type
	and parent_cd = p_parent_cd;

	if r_seq < r_max_seq then
		update
		c_numbering
		set seq=seq+1
		where numbering_type = p_numbering_type
		and parent_cd = p_parent_cd;
	    
		result_cd := r_parent_cd || case when r_parent_cd <> '' then '-' else '' end || lpad(trim(to_char(r_seq+1, '9999999')), r_cd_len, '0');
	else
		result_cd := '';
	end if;

	return result_cd;
end;

$$ language plpgsql;

