--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6 (Ubuntu 10.6-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.6 (Ubuntu 10.6-0ubuntu0.18.04.1)

-- Started on 2019-06-27 03:48:23 EDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 13039)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3826 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 311 (class 1255 OID 58187)
-- Name: check_concurrency(); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.check_concurrency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		IF (TG_OP='UPDATE') THEN
		   IF (NEW."stamp" <> OLD."stamp")THEN
			--THOW CONCURRENCY EXCEPTION
			  RAISE EXCEPTION '%',fns_errormessage(1);
		   ELSE
			New."stamp":=now();
			RETURN New;
		   END IF;
		END IF;
	END;
$$;


ALTER FUNCTION public.check_concurrency() OWNER TO kpuser;

--
-- TOC entry 196 (class 1259 OID 58188)
-- Name: vws_combo; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_combo AS
 SELECT NULL::bigint AS rid,
    NULL::character varying AS nam;


ALTER TABLE public.vws_combo OWNER TO kpuser;

--
-- TOC entry 312 (class 1255 OID 58192)
-- Name: cr_district_combo(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cr_district_combo(p_regionid bigint, p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_regionid int8)
    FOR SELECT rid,nam FROM vw_district WHERE
	  COALESCE("rei"::VARCHAR,'')= COALESCE(v_regionid::VARCHAR,COALESCE("rei"::VARCHAR,'') )
      ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur(p_regionid); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.cr_district_combo(p_regionid bigint, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 313 (class 1255 OID 58193)
-- Name: cr_maritalstatus_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cr_maritalstatus_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_maritalstatus WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.cr_maritalstatus_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 314 (class 1255 OID 58194)
-- Name: crs_creobtained(bigint, bigint, bigint, bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.crs_creobtained(p_customerid bigint, p_quarter bigint, p_accyear bigint, p_transtype bigint, p_userid bigint) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE	
    v_dmt double precision;
    v_wmt double precision;
    v_int double precision;
    v_rate double precision;
    
BEGIN
	SELECT recvalue INTO v_rate
	FROM tbs_systemdefault 
	WHERE recid=17;
	
	SELECT dmt INTO v_dmt
	FROM crw_paymentsum_test 
	WHERE cid=p_customerid AND qtr=p_quarter AND acy = p_accyear AND tri=p_transtype;

	SELECT wmt INTO v_wmt
	FROM crw_paymentsum_test 
	WHERE cid=p_customerid AND qtr=p_quarter AND acy = p_accyear AND tri=p_transtype;

	v_int:=v_dmt - v_wmt;

	RETURN v_int*v_rate;
END;
$$;


ALTER FUNCTION public.crs_creobtained(p_customerid bigint, p_quarter bigint, p_accyear bigint, p_transtype bigint, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 58195)
-- Name: crs_interestsum(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.crs_interestsum(p_customerid bigint) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE	
    v_wgp double precision;
    
BEGIN

	SELECT sum(wgp) INTO v_wgp
	FROM crw_interestsum
	WHERE cid=p_customerid AND acy=fns_curfinyear();


	RETURN v_wgp;
END;
$$;


ALTER FUNCTION public.crs_interestsum(p_customerid bigint) OWNER TO postgres;

--
-- TOC entry 316 (class 1255 OID 58196)
-- Name: fn_accountno_gen(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_accountno_gen(p_sequence bigint) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rtn varchar;
	v_chn integer;
	v_base varchar;
	v_code varchar;
	v_seq varchar;
			
BEGIN
	v_code := 'PIW';
	IF NOT (p_sequence >= 1 AND p_sequence < 10000000) THEN
	    RAISE EXCEPTION 'Invalid Sequence %',p_sequence; 
	END IF;

	
	v_seq := lpad(p_sequence::varchar,5,'0');
	

	v_base := v_seq;

	v_chn := ((98-((v_base::bigint * 100) % 97)) % 97);

	v_rtn := v_code || p_sequence || lpad(v_chn::varchar,2,'0');

	RETURN v_rtn;
END;
$$;


ALTER FUNCTION public.fn_accountno_gen(p_sequence bigint) OWNER TO postgres;

--
-- TOC entry 407 (class 1255 OID 67295)
-- Name: fn_count_shop_products(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_count_shop_products(p_recid bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_count integer;
BEGIN
	SELECT count(shi) INTO v_count FROM vw_product WHERE shi=p_recid;

	
	RETURN v_count;
END;
$$;


ALTER FUNCTION public.fn_count_shop_products(p_recid bigint) OWNER TO postgres;

--
-- TOC entry 317 (class 1255 OID 58197)
-- Name: fn_customerno_gen(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_customerno_gen(p_sequence bigint) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rtn varchar;
	v_chn integer;
	v_base varchar;
	v_code varchar;
	v_seq varchar;
			
BEGIN
	v_code := 'PIW';
	IF NOT (p_sequence >= 1 AND p_sequence < 10000000) THEN
	    RAISE EXCEPTION 'Invalid Sequence %',p_sequence; 
	END IF;

	
	v_seq := lpad(p_sequence::varchar,5,'0');
	

	v_base := v_seq;

	v_chn := ((98-((v_base::bigint * 100) % 97)) % 97);

	v_rtn := v_code || p_sequence || lpad(v_chn::varchar,2,'0');

	RETURN v_rtn;
END;
$$;


ALTER FUNCTION public.fn_customerno_gen(p_sequence bigint) OWNER TO postgres;

--
-- TOC entry 330 (class 1255 OID 58198)
-- Name: fn_membershipno_gen(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_membershipno_gen(p_sequence bigint) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rtn varchar;
	v_chn integer;
	v_base varchar;
	v_code varchar;
	v_seq varchar;
			
BEGIN
	v_code := 'FM';
	IF NOT (p_sequence >= 1 AND p_sequence < 100000) THEN
	    RAISE EXCEPTION 'Invalid Sequence %',p_sequence; 
	END IF;

	
	v_seq := lpad(p_sequence::varchar,3,'0');
	

	v_base := v_seq;

	v_chn := ((98-((v_base::bigint * 100) % 97)) % 97);

	v_rtn := v_code || v_base || lpad(v_chn::varchar,2,'0');

	RETURN v_rtn;
END;
$$;


ALTER FUNCTION public.fn_membershipno_gen(p_sequence bigint) OWNER TO postgres;

--
-- TOC entry 331 (class 1255 OID 58199)
-- Name: fn_moneycodeno_gen(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_moneycodeno_gen(p_sequence bigint) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rtn varchar;
	v_chn integer;
	v_base varchar;
	v_code varchar;
	v_seq varchar;
			
BEGIN
	v_code := 'PV';
	IF NOT (p_sequence >= 1 AND p_sequence < 10000000) THEN
	    RAISE EXCEPTION 'Invalid Sequence %',p_sequence; 
	END IF;

	
	v_seq := lpad(p_sequence::varchar,5,'0');
	

	v_base := v_seq;

	v_chn := ((98-((v_base::bigint * 100) % 97)) % 97);

	v_rtn := v_code || v_base || lpad(v_chn::varchar,2,'0');

	RETURN v_rtn;
END;
$$;


ALTER FUNCTION public.fn_moneycodeno_gen(p_sequence bigint) OWNER TO postgres;

--
-- TOC entry 332 (class 1255 OID 58200)
-- Name: fn_salescodeno_gen(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_salescodeno_gen(p_sequence bigint) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rtn varchar;
	v_chn integer;
	v_base varchar;
	v_code varchar;
	v_seq varchar;
			
BEGIN
	v_code := 'STS';
	IF NOT (p_sequence >= 1 AND p_sequence < 10000000) THEN
	    RAISE EXCEPTION 'Invalid Sequence %',p_sequence; 
	END IF;

	
	v_seq := lpad(p_sequence::varchar,5,'0');
	

	v_base := v_seq;

	v_chn := ((98-((v_base::bigint * 100) % 97)) % 97);

	v_rtn := v_code || v_base || lpad(v_chn::varchar,2,'0');

	RETURN v_rtn;
END;
$$;


ALTER FUNCTION public.fn_salescodeno_gen(p_sequence bigint) OWNER TO postgres;

--
-- TOC entry 333 (class 1255 OID 58201)
-- Name: fn_savingscodeno_gen(bigint, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_savingscodeno_gen(p_sequence bigint, p_amount double precision) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rtn varchar;
	v_chn integer;
	v_base varchar;
	v_code varchar;
	v_seq varchar;
			
BEGIN
	IF NOT (p_sequence >= 1 AND p_sequence < 10000000) THEN
	    RAISE EXCEPTION 'Invalid Sequence %',p_sequence; 
	END IF;

	IF p_amount < 0 THEN
		v_code := 'WD';
	ELSE
		v_code := 'SA';
	END IF;
	
	v_seq := lpad(p_sequence::varchar,5,'0');
	

	v_base := v_seq;

	v_chn := ((98-((v_base::bigint * 100) % 97)) % 97);

	v_rtn := v_code || v_base || lpad(v_chn::varchar,2,'0');

	RETURN v_rtn;
END;
$$;


ALTER FUNCTION public.fn_savingscodeno_gen(p_sequence bigint, p_amount double precision) OWNER TO postgres;

--
-- TOC entry 334 (class 1255 OID 58202)
-- Name: fn_transno_gen(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_transno_gen(p_transactiontypeid bigint, p_sequence bigint) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rtn varchar;  
	v_chn integer;
	v_base varchar;
	v_code varchar;
	v_seq varchar;
			
BEGIN
	SELECT shortcode INTO v_code FROM cr_transactiontype WHERE recid=p_transactiontypeid;
	IF NOT (p_sequence >= 1 AND p_sequence < 1000000) THEN
	    RAISE EXCEPTION 'Invalid Sequence %',p_sequence; 
	END IF;

	
	v_seq := lpad(p_sequence::varchar,5,'0');
	

	v_base := v_seq;

	v_chn := ((98-((v_base::bigint * 100) % 97)) % 97);

	v_rtn := v_code || v_base || lpad(v_chn::varchar,2,'0');

	RETURN v_rtn;
END;
$$;


ALTER FUNCTION public.fn_transno_gen(p_transactiontypeid bigint, p_sequence bigint) OWNER TO postgres;

--
-- TOC entry 335 (class 1255 OID 58203)
-- Name: fns_audittrail_add(bigint, character varying, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fns_audittrail_add(p_userid bigint, p_action character varying, p_record text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE	
BEGIN
	INSERT INTO tbs_audittrail(userid,
			       aaction,
			       arecord,
			       stamp) 
	     VALUES 	    (p_userid,
			     TRIM(p_action),
			     TRIM(p_record),
			     now());
	RETURN;
END;
$$;


ALTER FUNCTION public.fns_audittrail_add(p_userid bigint, p_action character varying, p_record text) OWNER TO postgres;

--
-- TOC entry 336 (class 1255 OID 58204)
-- Name: fns_curfinyear(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fns_curfinyear() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE	
    v_year integer;
    v_curr integer;
BEGIN
    v_curr := date_part('year',localtimestamp)::integer;
    
    SELECT recvalue::integer
      INTO v_year
      FROM tbs_systemdefault 
     WHERE reckey = 'FINANCIAL_YEAR';

    IF (COALESCE(v_year,0) < (v_curr-1) OR COALESCE(v_year,0) > (v_curr+1)) THEN
        return v_curr;
    ELSE
     return v_year;
    END IF;
     
END;
$$;


ALTER FUNCTION public.fns_curfinyear() OWNER TO postgres;

--
-- TOC entry 337 (class 1255 OID 58205)
-- Name: fns_defaultsessiontimeout(); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.fns_defaultsessiontimeout() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_sessiontimeout int4;
BEGIN
	SELECT recvalue::int4
	  INTO v_sessiontimeout
	  FROM tbs_systemdefault
	 WHERE rectype ='G' AND reckey='DEFAULT_SESSION_TIMEOUT';

	v_sessiontimeout:=COALESCE(v_sessiontimeout,0);

	RETURN v_sessiontimeout;
END;
$$;


ALTER FUNCTION public.fns_defaultsessiontimeout() OWNER TO kpuser;

--
-- TOC entry 338 (class 1255 OID 58206)
-- Name: fns_errormessage(integer); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.fns_errormessage(p_errorid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_message varchar;
BEGIN
	SELECT COALESCE(message::VARCHAR,'Invalid Error Message')
	  INTO v_message
	  FROM tbs_error
	 WHERE errorid = p_errorid;

	IF (NOT FOUND) THEN
	   v_message ='No message found for Error# '||p_errorid::VARCHAR;
	END IF;
	
	RETURN v_message;
END;
$$;


ALTER FUNCTION public.fns_errormessage(p_errorid integer) OWNER TO kpuser;

--
-- TOC entry 339 (class 1255 OID 58207)
-- Name: fns_fullname(character varying, character varying); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.fns_fullname(p_firstname character varying, p_surname character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_fullname varchar;
BEGIN
	-- regexp_replace((((c.firstname::text || ' '::text) || COALESCE(c.othernames::text, ''::text)) || ' '::text) || c.surname::text, '\\s{2,}'::text, ' '::text)::character varying AS nam, 
 
	SELECT regexp_replace((((upper(p_surname)::text || ', '::text) || 
		 COALESCE(initcap(p_othernames)::text, ''::text)) || ' '::text) || 
		 initcap(p_firstname)::text,E'\\s{2,}'::text, ' '::text)::character varying 


	--SELECT regexp_replace((((c.firstname::text || ' '::text) || COALESCE(c.othernames::text, ''::text)) || ' '::text) || c.surname::text, E'\\s{2,}'::text, ' '::text)::character varying AS nam

	INTO v_fullname;

	RETURN v_fullname;
END;
$$;


ALTER FUNCTION public.fns_fullname(p_firstname character varying, p_surname character varying) OWNER TO kpuser;

--
-- TOC entry 340 (class 1255 OID 58208)
-- Name: fns_inboxcount(bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.fns_inboxcount(p_userid bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_count int4;
BEGIN
	
	SELECT COUNT(*)
	  INTO v_count
	  FROM tbs_inbox
	 WHERE "userid" = COALESCE(p_userid,0);
	RETURN v_count;
END;
$$;


ALTER FUNCTION public.fns_inboxcount(p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 197 (class 1259 OID 58209)
-- Name: vws_add; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_add AS
 SELECT NULL::bigint AS rid,
    NULL::timestamp without time zone AS stp;


ALTER TABLE public.vws_add OWNER TO kpuser;

--
-- TOC entry 341 (class 1255 OID 58213)
-- Name: sp_auxgroup_add(bigint, bigint, character varying, bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_auxgroup_add(p_auxgroupid bigint, p_memeberid bigint, p_datejoined character varying, p_officeheld bigint, p_status integer, p_userid bigint) RETURNS SETOF public.vws_add
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_add%ROWTYPE;
	v_audit text;
BEGIN
	/**Insert Data Into Table**/
	INSERT INTO tb_memberauxgrp (memberid,
			     auxgrpid,
			     officeid,
			     datejoined,
			     status,
			     stamp) 
	     VALUES 	    (p_memeberid,
			     p_auxgroupid,
			     p_officeheld,
			     TRIM(p_datejoined)::date,
			     p_status,
			     now());

	/**Obtain Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vw_memberauxgrp
	 WHERE rid IN (SELECT MAX(rid) FROM vw_memberauxgrp);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed
-- 	WHERE ed.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Education Add',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_auxgroup_add(p_auxgroupid bigint, p_memeberid bigint, p_datejoined character varying, p_officeheld bigint, p_status integer, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 342 (class 1255 OID 58214)
-- Name: sp_auxgroup_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_auxgroup_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_auxgroup WHERE ast = 1
	ORDER BY "rid" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_auxgroup_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 343 (class 1255 OID 58215)
-- Name: sp_auxgroup_delete(bigint, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_auxgroup_delete(p_recid bigint, p_userid bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_audit text;
BEGIN
	/**Prepare Data for Audit */
-- 	 SELECT 'RecId = '||COALESCE(ce.rid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ce.cid::VARCHAR)||
-- 		' :: SubjectId = '||COALESCE(ce.sji::VARCHAR)||
-- 		' :: GradeId = '||COALESCE(ce.gdi::VARCHAR)||
-- 		' :: CertDate = '||COALESCE(ce.cdt::VARCHAR)||
-- 		' :: IndexNo = '||COALESCE(ce.ixn::VARCHAR)||
-- 		' :: Status = '||COALESCE(ce.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ce.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ce.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_certificate ce
-- 	WHERE ce.rid=p_recid;

	/**Delete Record **/
	DELETE FROM tb_memberauxgrp WHERE recid=p_recid;
	

	/**Record Audit**/
-- 	IF FOUND THEN
-- 		PERFORM fns_audittrail_add(p_userid,'Certificate Delete',v_audit);
-- 	END IF;
-- 
	RETURN;
END;
$$;


ALTER FUNCTION public.sp_auxgroup_delete(p_recid bigint, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 198 (class 1259 OID 58216)
-- Name: vws_edit; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_edit AS
 SELECT NULL::bigint AS rid,
    NULL::timestamp without time zone AS stp;


ALTER TABLE public.vws_edit OWNER TO kpuser;

--
-- TOC entry 344 (class 1255 OID 58220)
-- Name: sp_auxgroup_edit(bigint, bigint, bigint, character varying, integer, timestamp without time zone, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_auxgroup_edit(p_recid bigint, p_auxgrpid bigint, p_officeid bigint, p_datejoined character varying, p_status integer, p_stamp timestamp without time zone, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_audit text;
BEGIN
	v_audit:='';

	/**Prepare Data for Audit **/
-- 	SELECT (CASE WHEN LOWER(TRIM(COALESCE(ce.cid::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_candidateid::VARCHAR,''))) 
-- 	          THEN ' :: CandidateId (O) = '||TRIM(COALESCE(ce.cid::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_candidateid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ce.sji::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_subjectid::VARCHAR,''))) 
-- 	          THEN ' :: SubjectId (O) = '||TRIM(COALESCE(ce.sji::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_subjectid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ce.gdi::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_gradeid::VARCHAR,''))) 
-- 	          THEN ' :: GradeId (O) = '||TRIM(COALESCE(ce.gdi::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_gradeid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ce.cdt::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_certdate::VARCHAR,''))) 
-- 	          THEN ' :: CertDate (O) = '||TRIM(COALESCE(ce.cdt::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_certdate::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ce.ixn::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_indexno::VARCHAR,''))) 
-- 	          THEN ' :: IndexNo (O) = '||TRIM(COALESCE(ce.ixn::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_indexno::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ce.sts::VARCHAR,'')) != TRIM(COALESCE(p_status::VARCHAR,''))
-- 	          THEN ' :: Status (O) = '||TRIM(COALESCE(ce.sts::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_status::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ce.stp::VARCHAR,''))!=TRIM( COALESCE(p_stamp::VARCHAR,''))
-- 	          THEN ' :: Stamp (O) = '||TRIM(COALESCE(ce.stp::VARCHAR,''))||', (N) = '||TRIM( COALESCE(p_stamp::VARCHAR,''))
--                   ELSE ''END)
-- 	INTO v_audit
-- 	FROM vw_certificate ce
-- 	WHERE ce.rid=p_recid;

	/** Update **/
	UPDATE tb_memberauxgrp
           SET 
	       auxgrpid=p_auxgrpid,
	       officeid=p_officeid,
	       datejoined=TRIM(p_datejoined)::date,
	       status=p_status,
	       stamp= p_stamp
	 WHERE recid=p_recid;

	/** Get Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vw_memberauxgrp
	 WHERE rid = p_recid;

	/** If there is the need for an audit trail, record it **/
-- 	IF v_audit!='' THEN
-- 		v_audit:='RecId = '||p_recid||v_audit;
-- 		PERFORM fns_audittrail_add(p_userid,'Certificate Edit',v_audit);
-- 	END IF;
	
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_auxgroup_edit(p_recid bigint, p_auxgrpid bigint, p_officeid bigint, p_datejoined character varying, p_status integer, p_stamp timestamp without time zone, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 345 (class 1255 OID 58221)
-- Name: sp_auxgroup_edit(bigint, bigint, bigint, bigint, character varying, integer, timestamp without time zone, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_auxgroup_edit(p_recid bigint, p_memberid bigint, p_auxgrpid bigint, p_officeid bigint, p_datejoined character varying, p_status integer, p_stamp timestamp without time zone, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_audit text;
BEGIN
	v_audit:='';

	/**Prepare Data for Audit **/
-- 	SELECT (CASE WHEN LOWER(TRIM(COALESCE(ce.cid::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_candidateid::VARCHAR,''))) 
-- 	          THEN ' :: CandidateId (O) = '||TRIM(COALESCE(ce.cid::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_candidateid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ce.sji::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_subjectid::VARCHAR,''))) 
-- 	          THEN ' :: SubjectId (O) = '||TRIM(COALESCE(ce.sji::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_subjectid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ce.gdi::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_gradeid::VARCHAR,''))) 
-- 	          THEN ' :: GradeId (O) = '||TRIM(COALESCE(ce.gdi::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_gradeid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ce.cdt::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_certdate::VARCHAR,''))) 
-- 	          THEN ' :: CertDate (O) = '||TRIM(COALESCE(ce.cdt::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_certdate::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ce.ixn::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_indexno::VARCHAR,''))) 
-- 	          THEN ' :: IndexNo (O) = '||TRIM(COALESCE(ce.ixn::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_indexno::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ce.sts::VARCHAR,'')) != TRIM(COALESCE(p_status::VARCHAR,''))
-- 	          THEN ' :: Status (O) = '||TRIM(COALESCE(ce.sts::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_status::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ce.stp::VARCHAR,''))!=TRIM( COALESCE(p_stamp::VARCHAR,''))
-- 	          THEN ' :: Stamp (O) = '||TRIM(COALESCE(ce.stp::VARCHAR,''))||', (N) = '||TRIM( COALESCE(p_stamp::VARCHAR,''))
--                   ELSE ''END)
-- 	INTO v_audit
-- 	FROM vw_certificate ce
-- 	WHERE ce.rid=p_recid;

	/** Update **/
	UPDATE tb_memberauxgrp
           SET memberid=p_memberid,
	       auxgrpid=p_auxgrpid,
	       officeid=p_officeid,
	       datejoined=TRIM(p_datejoined)::date,
	       status=p_status,
	       stamp= p_stamp
	 WHERE recid=p_recid;

	/** Get Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vw_memberauxgrp
	 WHERE rid = p_recid;

	/** If there is the need for an audit trail, record it **/
-- 	IF v_audit!='' THEN
-- 		v_audit:='RecId = '||p_recid||v_audit;
-- 		PERFORM fns_audittrail_add(p_userid,'Certificate Edit',v_audit);
-- 	END IF;
	
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_auxgroup_edit(p_recid bigint, p_memberid bigint, p_auxgrpid bigint, p_officeid bigint, p_datejoined character varying, p_status integer, p_stamp timestamp without time zone, p_userid bigint) OWNER TO kpuser;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 211 (class 1259 OID 58313)
-- Name: tb_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_category (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    shortcode character varying(200),
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    img character varying,
    sectionid bigint
);


ALTER TABLE public.tb_category OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 58417)
-- Name: tb_section; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_section (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    shortcode character varying(200),
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tb_section OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 58421)
-- Name: vw_category; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_category AS
 SELECT r.recid AS rid,
    r.recname AS nam,
    r.shortcode AS shc,
    r.stamp AS stp,
    r.img,
    r.sectionid AS sid,
    s.recname AS snm
   FROM public.tb_category r,
    public.tb_section s
  WHERE (r.sectionid = s.recid);


ALTER TABLE public.vw_category OWNER TO postgres;

--
-- TOC entry 421 (class 1255 OID 70112)
-- Name: sp_categories_find(bigint, character varying, character varying, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_categories_find(p_recid bigint, p_name character varying, p_code character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_category
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8,
		   v_name "varchar",
		   v_code "varchar",
		   v_status int4,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_category WHERE
        COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
    AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(v_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
    AND COALESCE("shc"::VARCHAR,'') LIKE '%'|| COALESCE(v_code::VARCHAR,COALESCE("shc"::VARCHAR,''))||'%'
--     AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND "rid" > 0 --avoiding invalid recid
    ORDER BY "nam"
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_category%ROWTYPE;
BEGIN 

-- 	SELECT shopid INTO v_user_shop FROM tbs_user WHERE recid = p_userid; 
-- 	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
-- 	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_category WHERE
           COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
        AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
        AND COALESCE("shc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("shc"::VARCHAR,''))||'%'
--         AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
        AND "rid" > 0;  --avoiding invalid recid


	RETURN NEXT v_rec; 

	OPEN v_cur(p_recid,p_name,p_code,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_categories_find(p_recid bigint, p_name character varying, p_code character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 423 (class 1255 OID 70110)
-- Name: sp_category_add(character varying, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_category_add(p_recname character varying, p_userid bigint) RETURNS SETOF public.vw_category
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_category%ROWTYPE;
	v_audit text;
BEGIN

	/**Insert Data Into Table**/
	INSERT INTO tb_category(recname,sectionid) 
	     VALUES 	    (TRIM(p_recname),2);
			    

	/**Obtain Return Data**/
	SELECT * 
	  INTO v_rec
	  FROM vw_category
	 WHERE rid IN (SELECT MAX(rid) FROM vw_category);

	/**Prepare Data for Audit */
	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
		' :: CategoryName = '||COALESCE(ed.nam::VARCHAR)||
		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
	INTO v_audit
	FROM vw_category ed
	WHERE ed.rid=v_rec.rid;
	
	/**Record Audit**/
	PERFORM fns_audittrail_add(p_userid,'Add Category',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_category_add(p_recname character varying, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 346 (class 1255 OID 58222)
-- Name: sp_country_combo(bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_country_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_country WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_country_combo(p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 199 (class 1259 OID 58223)
-- Name: tb_member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_member (
    recid bigint NOT NULL,
    memberno character varying(200) NOT NULL,
    surname character varying(200),
    firstname character varying(200),
    dateofbirth character varying(200),
    mobileno character varying(200),
    phoneno character varying(200),
    nextofkin character varying(200),
    nkphoneno character varying(200),
    address text,
    datecreated character varying(200),
    userid bigint NOT NULL,
    pimg character varying(200) DEFAULT 'sample.png'::character varying,
    status integer DEFAULT 1,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    shopid bigint DEFAULT 1
);


ALTER TABLE public.tb_member OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 58233)
-- Name: tb_paymenttype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_paymenttype (
    recid bigint NOT NULL,
    recname character varying(100) NOT NULL,
    shortcode character varying(10) NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_paymenttype_name CHECK (((recname)::text <> ''::text)),
    CONSTRAINT chek_paymenttype_shortcode CHECK (((shortcode)::text <> ''::text))
);


ALTER TABLE public.tb_paymenttype OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 58239)
-- Name: tb_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_product (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    productcode character varying(200),
    price double precision NOT NULL,
    quantity double precision NOT NULL,
    categoryid bigint NOT NULL,
    userid bigint NOT NULL,
    pimg character varying(200) DEFAULT 'sample.png'::character varying,
    expirydate character varying,
    productstatusid bigint,
    status integer DEFAULT 1,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    datcreated character varying(100),
    extra integer DEFAULT 0,
    amountadded integer,
    buyingprice double precision,
    barcode character varying(200),
    productunit character varying(100),
    shopid bigint,
    ratepersinglebox double precision,
    quantityperbox integer,
    wholesaleratepersinglebox double precision,
    unit bigint DEFAULT 0 NOT NULL,
    nqy integer DEFAULT 1 NOT NULL,
    bulkqty integer DEFAULT 0
);


ALTER TABLE public.tb_product OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 58250)
-- Name: tb_sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_sales (
    recid bigint NOT NULL,
    productid bigint,
    quantity integer,
    amount double precision NOT NULL,
    salescodeid bigint,
    status integer DEFAULT 1,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    datcreated character varying(100)
);


ALTER TABLE public.tb_sales OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 58256)
-- Name: tb_salescode; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_salescode (
    recid bigint NOT NULL,
    salescode character varying,
    userid bigint,
    status integer DEFAULT 1,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    datcreated character varying(100),
    customername character varying(200),
    phone character varying(30),
    paymenttypeid bigint,
    amountpaid double precision
);


ALTER TABLE public.tb_salescode OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 58265)
-- Name: tb_savings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_savings (
    recid bigint NOT NULL,
    memberid bigint,
    amount double precision,
    savingscode character varying,
    status integer DEFAULT 1,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    datecreated character varying(100),
    userid bigint
);


ALTER TABLE public.tb_savings OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 58273)
-- Name: tbs_user; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_user (
    recid bigint NOT NULL,
    entityid bigint,
    surname character varying(20) NOT NULL,
    othernames character varying(20) NOT NULL,
    username character varying(20) NOT NULL,
    userpass character varying(50) NOT NULL,
    roleid bigint,
    sessionid character varying(50),
    loginstatus integer DEFAULT 1 NOT NULL,
    datecreated timestamp without time zone NOT NULL,
    lastpasswordresetdate timestamp without time zone NOT NULL,
    lastlogindate timestamp without time zone NOT NULL,
    contactno1 character varying(15),
    contactno2 character varying(15),
    email character varying(100) NOT NULL,
    comments text,
    falselogin integer DEFAULT 0 NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now(),
    photourl character varying(30),
    gender integer,
    shopid integer,
    sectionid bigint,
    CONSTRAINT chek_user_email CHECK ((upper((email)::text) <> ''::text)),
    CONSTRAINT chek_user_username CHECK ((upper((username)::text) <> ''::text))
);


ALTER TABLE public.tbs_user OWNER TO kpuser;

--
-- TOC entry 206 (class 1259 OID 58284)
-- Name: vw_credit_member; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_credit_member AS
 SELECT sc.recid AS rid,
    sc.salescode AS scn,
    sc.userid AS usi,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    sc.status AS sts,
    sc.datecreated AS dcd,
    sc.stamp AS stp,
    sc.datcreated AS dat,
    sc.paymenttypeid AS pti,
    pt.recname AS ptn,
    sc.amountpaid AS amt,
    mm.memberno AS mno,
    (upper(((mm.surname)::text || ', '::text)) || (mm.firstname)::text) AS nam,
    mm.mobileno AS tel,
    mm.phoneno AS mob,
    sa.productid AS pid,
    sa.quantity AS qty,
    sa.amount AS smt,
    pd.recname AS pnm
   FROM public.tbs_user us,
    public.tb_salescode sc,
    public.tb_paymenttype pt,
    public.tb_member mm,
    public.tb_sales sa,
    public.tb_product pd
  WHERE ((us.recid = sc.userid) AND (pd.recid = sa.productid) AND (sa.salescodeid = sc.recid) AND (sc.paymenttypeid = pt.recid) AND ((mm.memberno)::text = (sc.phone)::text));


ALTER TABLE public.vw_credit_member OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 58289)
-- Name: vw_credit_member_summ; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_credit_member_summ AS
 SELECT cm.mno,
    cm.nam,
    cm.pti,
    cm.ptn,
    sum(cm.amt) AS amt,
    sum((cm.smt * (cm.qty)::double precision)) AS smt,
    (sum(cm.amt) - sum((cm.smt * (cm.qty)::double precision))) AS bal,
    (count(cm.amt) - 1) AS cnt
   FROM public.vw_credit_member cm
  GROUP BY cm.mno, cm.nam, cm.pti, cm.ptn;


ALTER TABLE public.vw_credit_member_summ OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 58293)
-- Name: vw_savings; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_savings AS
 SELECT sa.recid AS rid,
    sa.memberid AS mid,
    mm.memberno AS mno,
    mm.surname AS snm,
    mm.firstname AS fnm,
    mm.mobileno AS mob,
    mm.phoneno AS tel,
    sa.amount AS amt,
    sa.savingscode AS scd,
    sa.datecreated AS dcd,
    sa.userid AS usi,
    us.surname AS usn,
    us.othernames AS uso,
    us.username AS unm,
    sa.stamp AS stp,
    sa.status AS sts,
    (upper(((mm.surname)::text || ', '::text)) || (mm.firstname)::text) AS nam,
    sa.savingscode AS pcd
   FROM public.tb_member mm,
    public.tbs_user us,
    public.tb_savings sa
  WHERE ((mm.recid = sa.memberid) AND (us.recid = sa.userid));


ALTER TABLE public.vw_savings OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 58298)
-- Name: vw_savings_member_sum; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_savings_member_sum AS
 SELECT sa.mno,
    sa.nam,
    sum(sa.amt) AS amt,
    (count(sa.amt) - 1) AS cnt
   FROM public.vw_savings sa
  GROUP BY sa.mno, sa.nam;


ALTER TABLE public.vw_savings_member_sum OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 58302)
-- Name: vw_savings_credit_sum; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_savings_credit_sum AS
 SELECT sv.mno,
    sv.nam,
    sv.amt AS smt,
    cm.amt AS cmt,
    cm.smt AS dmt,
    ((sv.amt - cm.smt) + cm.amt) AS bal
   FROM public.vw_savings_member_sum sv,
    public.vw_credit_member_summ cm
  WHERE (((cm.mno)::text = (sv.mno)::text) AND (cm.pti = 2));


ALTER TABLE public.vw_savings_credit_sum OWNER TO postgres;

--
-- TOC entry 347 (class 1255 OID 58306)
-- Name: sp_credit_find(character varying, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_credit_find(p_code character varying, p_userid bigint) RETURNS SETOF public.vw_savings_credit_sum
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(
		   v_code "varchar")
    FOR SELECT * FROM vw_savings_credit_sum WHERE
	 COALESCE("mno"::VARCHAR,'') LIKE '%'|| COALESCE(v_code::VARCHAR,COALESCE("mno"::VARCHAR,''))||'%'
    ORDER BY "mno";
    v_rec  vw_savings_credit_sum%ROWTYPE;
    pv_startdate character varying;
    pv_enddate character varying;
    v_user_shop bigint;
BEGIN 

-- 	SELECT shopid INTO v_user_shop FROM tbs_user WHERE recid = p_userid; 
-- 	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
-- 	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;
	--COUNT VALID RECORD
	-- SELECT COUNT(*)
-- 	  INTO v_rec.cnt
-- 	 FROM vw_savings_credit_sum WHERE
-- 	  COALESCE("mno"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("mno"::VARCHAR,''))||'%';



	RETURN NEXT v_rec; 

	OPEN v_cur(p_code); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_credit_find(p_code character varying, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 348 (class 1255 OID 58307)
-- Name: sp_education_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_education_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_education
	WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_education_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 349 (class 1255 OID 58308)
-- Name: sp_emprank_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_emprank_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_emprank
	WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_emprank_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 350 (class 1255 OID 58309)
-- Name: sp_empstatus_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_empstatus_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_empstatus
	WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_empstatus_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 351 (class 1255 OID 58310)
-- Name: sp_events_add(character varying, text, bigint, double precision, character varying, character varying, integer, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_events_add(p_eventname character varying, p_description text, p_eventtypeid bigint, p_target double precision, p_startdate character varying, p_enddate character varying, p_status integer, p_userid bigint) RETURNS SETOF public.vws_add
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_add%ROWTYPE;
	v_audit text;
BEGIN
	/**Insert Data Into Table**/
	INSERT INTO tb_event (recname,
			     description,
			     eventtypeid,
			     target,
			     startdate,
			     enddate,
			     status,
			     stamp) 
	     VALUES 	    (Trim(p_eventname),
			     Trim(p_description),
			     p_eventtypeid,
			     p_target,
			     Trim(p_startdate),
			     Trim(p_enddate),
			     p_status,
			     now());

	/**Obtain Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vw_event
	 WHERE rid IN (SELECT MAX(rid) FROM vw_event);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ce.rid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ce.cid::VARCHAR)||
-- 		' :: SubjectId = '||COALESCE(ce.sji::VARCHAR)||
-- 		' :: GradeId = '||COALESCE(ce.gdi::VARCHAR)||
-- 		' :: CertDate = '||COALESCE(ce.cdt::VARCHAR)||
-- 		' :: IndexNo = '||COALESCE(ce.ixn::VARCHAR)||
-- 		' :: Status = '||COALESCE(ce.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ce.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ce.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_certificate ce
-- 	WHERE ce.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Certificate Add',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_events_add(p_eventname character varying, p_description text, p_eventtypeid bigint, p_target double precision, p_startdate character varying, p_enddate character varying, p_status integer, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 352 (class 1255 OID 58311)
-- Name: sp_events_add(character varying, text, bigint, double precision, character varying, character varying, integer, timestamp without time zone, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_events_add(p_eventname character varying, p_description text, p_eventtypeid bigint, p_target double precision, p_startdate character varying, p_enddate character varying, p_status integer, p_stamp timestamp without time zone, p_userid bigint) RETURNS SETOF public.vws_add
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_add%ROWTYPE;
	v_audit text;
BEGIN
	/**Insert Data Into Table**/
	INSERT INTO tb_event (recname,
			     description,
			     eventtypeid,
			     target,
			     startdate,
			     enddate,
			     status,
			     stamp) 
	     VALUES 	    (Trim(p_eventname),
			     Trim(p_description),
			     p_eventtypeid,
			     p_target,
			     Trim(p_startdate),
			     Trim(p_enddate),
			     p_status,
			     now());

	/**Obtain Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vw_event
	 WHERE rid IN (SELECT MAX(rid) FROM vw_event);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ce.rid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ce.cid::VARCHAR)||
-- 		' :: SubjectId = '||COALESCE(ce.sji::VARCHAR)||
-- 		' :: GradeId = '||COALESCE(ce.gdi::VARCHAR)||
-- 		' :: CertDate = '||COALESCE(ce.cdt::VARCHAR)||
-- 		' :: IndexNo = '||COALESCE(ce.ixn::VARCHAR)||
-- 		' :: Status = '||COALESCE(ce.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ce.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ce.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_certificate ce
-- 	WHERE ce.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Certificate Add',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_events_add(p_eventname character varying, p_description text, p_eventtypeid bigint, p_target double precision, p_startdate character varying, p_enddate character varying, p_status integer, p_stamp timestamp without time zone, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 353 (class 1255 OID 58312)
-- Name: sp_eventtype_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_eventtype_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_eventtype
	WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_eventtype_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 58336)
-- Name: tb_currency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_currency (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    shortcode character varying(10) NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_currency_name CHECK (((recname)::text <> ''::text)),
    CONSTRAINT chek_currency_shortcode CHECK (((shortcode)::text <> ''::text))
);


ALTER TABLE public.tb_currency OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 58342)
-- Name: tb_enquiry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_enquiry (
    recid bigint NOT NULL,
    recname character varying(300),
    requestedby character varying(300),
    enquiryno character varying(200) NOT NULL,
    quotationno character varying(200) NOT NULL,
    description text,
    enquirydate character varying(100),
    quotationdate character varying(100),
    quotationtypeid bigint,
    currencyid bigint,
    status integer NOT NULL,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    userid bigint
);


ALTER TABLE public.tb_enquiry OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 58350)
-- Name: tb_quotationtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_quotationtype (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    shortcode character varying(5) NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_quotationtype_name CHECK (((recname)::text <> ''::text)),
    CONSTRAINT chek_quotationtype_shortcode CHECK (((shortcode)::text <> ''::text))
);


ALTER TABLE public.tb_quotationtype OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 58356)
-- Name: vw_enquiries; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_enquiries AS
 SELECT en.recid AS rid,
    en.recname AS nam,
    en.requestedby AS rqn,
    en.enquiryno AS eno,
    en.quotationno AS qno,
    en.description AS dsc,
    en.enquirydate AS edt,
    en.quotationdate AS qdt,
    en.quotationtypeid AS qti,
    qt.recname AS qtn,
    qt.shortcode AS qsc,
    en.currencyid AS cid,
    cu.recname AS cnm,
    cu.shortcode AS csc,
    en.status AS sts,
    en.datecreated AS dcd,
    en.stamp AS stp,
    en.userid AS usi,
    us.surname AS snm,
    us.othernames AS fnm
   FROM public.tb_enquiry en,
    public.tbs_user us,
    public.tb_currency cu,
    public.tb_quotationtype qt
  WHERE ((us.recid = en.userid) AND (en.currencyid = cu.recid) AND (qt.recid = en.quotationtypeid));


ALTER TABLE public.vw_enquiries OWNER TO postgres;

--
-- TOC entry 354 (class 1255 OID 58361)
-- Name: sp_getenquiries_find(bigint, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_getenquiries_find(p_recid bigint, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_enquiries
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8,
		   v_status int4, 
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_enquiries WHERE
	  COALESCE("rid"::VARCHAR,'')= COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,'') )
      AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
     -- ORDER BY "nam" ASC
    LIMIT COALESCE(v_pagelimit,9223372036854775807)  OFFSET COALESCE(v_pageoffset,0);

    v_rec  vw_enquiries%ROWTYPE;
BEGIN 
	--COUNT OF VALID RECORDS
	SELECT COUNT(*)
	  INTO v_rec.rid
	FROM vw_enquiries WHERE
	  COALESCE("rid"::VARCHAR,'')= COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,'') )
        AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''));

	RETURN NEXT v_rec;

	OPEN v_cur(p_recid,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_getenquiries_find(p_recid bigint, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 355 (class 1255 OID 58362)
-- Name: sp_harvesttype_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_harvesttype_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_harvesttype WHERE ast = 1
	ORDER BY "rid" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_harvesttype_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 356 (class 1255 OID 58363)
-- Name: sp_idtype_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_idtype_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_idtype
	WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_idtype_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 58364)
-- Name: tb_issues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_issues (
    recid bigint NOT NULL,
    productid bigint,
    issues text,
    status integer DEFAULT 1,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    datcreated character varying(100),
    userid bigint
);


ALTER TABLE public.tb_issues OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 58373)
-- Name: vw_issues; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_issues AS
 SELECT sc.recid AS rid,
    sc.productid AS pid,
    pd.recname AS nam,
    sc.issues AS iss,
    sc.userid AS usi,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    sc.status AS sts,
    sc.datecreated AS dcd,
    sc.stamp AS stp,
    sc.datcreated AS dat
   FROM public.tbs_user us,
    public.tb_issues sc,
    public.tb_product pd
  WHERE ((us.recid = sc.userid) AND (pd.recid = sc.productid));


ALTER TABLE public.vw_issues OWNER TO postgres;

--
-- TOC entry 357 (class 1255 OID 58377)
-- Name: sp_issues_find(bigint, character varying, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_issues_find(p_recid bigint, p_name character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_issues
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8,
		   v_name "varchar",
		   v_status int4,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_issues WHERE
        COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
    AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(v_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
--     AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(v_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
--     AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(v_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--     AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(v_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND "rid" > 0 --avoiding invalid recid
    ORDER BY "rid"
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_issues%ROWTYPE;
    pv_startdate character varying;
    pv_enddate character varying;
BEGIN 

-- 	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
-- 	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_issues WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
--          AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
         AND "rid" > 0;  --avoiding invalid recid


--          SELECT sum(tot)
-- 	  INTO v_rec.tot
-- 	 FROM vw_issues WHERE
--             COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
--          AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
--          AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
--          AND "rid" > 0;

	RETURN NEXT v_rec; 

	OPEN v_cur(p_recid,p_name,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_issues_find(p_recid bigint, p_name character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 58378)
-- Name: vw_saless; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_saless AS
 SELECT sa.recid AS rid,
    sa.productid AS pid,
    pd.recname AS nam,
    pd.productcode AS pdc,
    pd.price AS prc,
    sa.amount AS amt,
    sa.quantity AS qty,
    pd.categoryid AS cid,
    ct.recname AS ctn,
    sa.salescodeid AS sci,
    sc.salescode AS scd,
    sc.userid AS usi,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    sa.datcreated AS dat,
    ((sa.quantity)::double precision * sa.amount) AS tot,
    sc.customername AS cnm,
    sc.phone AS tel
   FROM public.tbs_user us,
    public.tb_category ct,
    public.tb_sales sa,
    public.tb_salescode sc,
    public.tb_product pd
  WHERE ((us.recid = sc.userid) AND (ct.recid = pd.categoryid) AND (sc.recid = sa.salescodeid) AND (pd.recid = sa.productid));


ALTER TABLE public.vw_saless OWNER TO postgres;

--
-- TOC entry 358 (class 1255 OID 58383)
-- Name: sp_latestsales_find(character varying, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_latestsales_find(p_code character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_saless
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_code "varchar",
		   v_status int4,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_saless WHERE
	COALESCE("scd"::VARCHAR,'') = COALESCE(v_code::VARCHAR,COALESCE("scd"::VARCHAR,''))
    AND "rid" > 0 --avoiding invalid recid
    ORDER BY "rid"
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_saless%ROWTYPE;
    pv_startdate character varying;
    pv_enddate character varying;
BEGIN 

-- 	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
-- 	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_saless WHERE
            COALESCE("scd"::VARCHAR,'') = COALESCE(p_code::VARCHAR,COALESCE("scd"::VARCHAR,''))
	 AND "rid" > 0;  --avoiding invalid recid


         SELECT sum(tot)
	  INTO v_rec.tot
	 FROM vw_saless WHERE
            COALESCE("scd"::VARCHAR,'') = COALESCE(p_code::VARCHAR,COALESCE("scd"::VARCHAR,''))
	 AND "rid" > 0;

	RETURN NEXT v_rec; 

	OPEN v_cur(p_code,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_latestsales_find(p_code character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 58384)
-- Name: vw_member_totals; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_member_totals AS
 SELECT sa.memberid AS mid,
    sum(sa.amount) AS tot
   FROM public.tb_savings sa,
    public.tb_member mm
  WHERE (mm.recid = sa.memberid)
  GROUP BY sa.memberid;


ALTER TABLE public.vw_member_totals OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 58388)
-- Name: vw_member; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_member AS
 SELECT mm.recid AS rid,
    mm.memberno AS mno,
    mm.surname AS snm,
    mm.firstname AS fnm,
    mm.dateofbirth AS dob,
    mm.mobileno AS mob,
    mm.phoneno AS tel,
    mm.nextofkin AS nxk,
    mm.nkphoneno AS nkt,
    mm.address AS had,
    mm.datecreated AS dcd,
    mm.userid AS usi,
    mm.pimg AS pmg,
    mm.status AS sts,
    mm.stamp AS stp,
    mm.shopid AS shi,
    us.surname AS usn,
    us.othernames AS uso,
    us.username AS unm,
    (upper(((mm.surname)::text || ', '::text)) || (mm.firstname)::text) AS nam,
    mt.tot
   FROM public.tb_member mm,
    public.tbs_user us,
    public.vw_member_totals mt
  WHERE ((us.recid = mm.userid) AND (mt.mid = mm.recid));


ALTER TABLE public.vw_member OWNER TO postgres;

--
-- TOC entry 359 (class 1255 OID 58393)
-- Name: sp_member_add(character varying, character varying, character varying, character varying, character varying, text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_member_add(p_surname character varying, p_firstname character varying, p_mobileno character varying, p_nextofkin character varying, p_nkphoneno character varying, p_address text, p_userid bigint) RETURNS SETOF public.vw_member
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_member%ROWTYPE;
	v_recc vw_salescode%ROWTYPE;
	v_audit text;
	v_datcreated character varying;
	v_memberno character varying;
	v_sequence bigint;
	rd RECORD;
BEGIN
	select now()::date::character varying into v_datcreated;
	select max(recid) + 1 into v_sequence from tb_member;
	v_memberno:=fn_membershipno_gen(v_sequence);
	/**Insert Data Into Table**/
	INSERT INTO tb_member(recid,
			      memberno,
			      surname,
			      firstname,
			      mobileno,
			      nextofkin,
			      nkphoneno,
			      address,
			      datecreated,
			      userid) 
	     VALUES 	    (v_sequence,
			     TRIM(v_memberno),
			     TRIM(p_surname),
			     TRIM(p_firstname),
			     TRIM(p_mobileno),
			     TRIM(p_nextofkin),
			     TRIM(p_nkphoneno),
			     TRIM(p_address),
			     TRIM(v_datcreated),
			     p_userid);
			     
	PERFORM sp_savings_add(v_sequence,0,p_userid);

	/**Obtain Return Data**/
	SELECT * 
	  INTO v_rec
	  FROM vw_member
	 WHERE rid IN (SELECT MAX(rid) FROM vw_member);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_member_add(p_surname character varying, p_firstname character varying, p_mobileno character varying, p_nextofkin character varying, p_nkphoneno character varying, p_address text, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 360 (class 1255 OID 58394)
-- Name: sp_member_edit2(bigint, bigint, text, bigint, text, integer, character varying, character varying, character varying, integer, integer, timestamp without time zone, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_member_edit2(p_recid bigint, p_empstatusid bigint, p_placeofwork text, p_positionid bigint, p_workaddress text, p_maritalstatusid integer, p_nameofspouse character varying, p_spousedob character varying, p_spousephone character varying, p_numberofdependants integer, p_status integer, p_stamp timestamp without time zone, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_audit text;
BEGIN
	v_audit:='';


	/**Prepare Data for Audit **/
-- 	SELECT (CASE WHEN LOWER(TRIM(COALESCE(ca.adt::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_appdate::VARCHAR,''))) 
-- 	          THEN ' :: AppDate (O) = '||TRIM(COALESCE(ca.adt::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_appdate::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.ami::VARCHAR,'')) != TRIM(COALESCE(p_appmodeid::VARCHAR,''))
-- 	          THEN ' :: AppModeId (O) = '||TRIM(COALESCE(ca.ami::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_appmodeid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.apc::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_appcode::VARCHAR,''))) 
-- 	          THEN ' :: AppCode (O) = '||TRIM(COALESCE(ca.apc::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_appcode::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.fci::VARCHAR,'')) != TRIM(COALESCE(p_firstchoiceid::VARCHAR,''))
-- 	          THEN ' :: FirstChoiceId (O) = '||TRIM(COALESCE(ca.fci::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_firstchoiceid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.sci::VARCHAR,'')) != TRIM(COALESCE(p_secondchoiceid::VARCHAR,''))
-- 	          THEN ' :: SecondChoiceId (O) = '||TRIM(COALESCE(ca.sci::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_secondchoiceid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.snm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_surname::VARCHAR,''))) 
-- 	          THEN ' :: Surname (O) = '||TRIM(COALESCE(ca.snm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_surname::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.fnm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_firstname::VARCHAR,''))) 
-- 	          THEN ' :: Firstname (O) = '||TRIM(COALESCE(ca.fnm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_firstname::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.onm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_othernames::VARCHAR,''))) 
-- 	          THEN ' :: Oternames (O) = '||TRIM(COALESCE(ca.onm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_othernames::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.sex::VARCHAR,'')) != TRIM(COALESCE(p_gender::VARCHAR,''))
-- 	          THEN ' :: Gender (O) = '||TRIM(COALESCE(ca.sex::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_gender::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.dob::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_dateofbirth::VARCHAR,''))) 
-- 	          THEN ' :: DateofBirth (O) = '||TRIM(COALESCE(ca.dob::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_dateofbirth::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.twn::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_hometown::VARCHAR,''))) 
-- 	          THEN ' :: HomeTown (O) = '||TRIM(COALESCE(ca.twn::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_hometown::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.pad::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_postaladdress::VARCHAR,''))) 
-- 	          THEN ' :: PostalAddress (O) = '||TRIM(COALESCE(ca.pad::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_postaladdress::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.had::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_homeaddress::VARCHAR,''))) 
-- 	          THEN ' :: HomeAddress (O) = '||TRIM(COALESCE(ca.had::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_homeaddress::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.tel::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_contactno::VARCHAR,''))) 
-- 	          THEN ' :: ContactNo (O) = '||TRIM(COALESCE(ca.tel::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_contactno::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.coi::VARCHAR,'')) != TRIM(COALESCE(p_countryid::VARCHAR,''))
-- 	          THEN ' :: CountryId (O) = '||TRIM(COALESCE(ca.coi::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_countryid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.eml::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_email::VARCHAR,''))) 
-- 	          THEN ' :: Email (O) = '||TRIM(COALESCE(ca.eml::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_email::VARCHAR,''))
--                   ELSE ''END)||
-- 	--       (CASE WHEN LOWER(TRIM(COALESCE(ca.pho::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_photourl::VARCHAR,''))) 
-- 	--          THEN ' :: PhotoUrl (O) = '||TRIM(COALESCE(ca.pho::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_photourl::VARCHAR,''))
--         --          ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.com::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_comments::VARCHAR,''))) 
-- 	          THEN ' :: Comments (O) = '||TRIM(COALESCE(ca.com::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_comments::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.sts::VARCHAR,'')) != TRIM(COALESCE(p_status::VARCHAR,''))
-- 	          THEN ' :: Status (O) = '||TRIM(COALESCE(ca.sts::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_status::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.stp::VARCHAR,''))!=TRIM( COALESCE(p_stamp::VARCHAR,''))
-- 	          THEN ' :: Stamp (O) = '||TRIM(COALESCE(ca.stp::VARCHAR,''))||', (N) = '||TRIM( COALESCE(p_stamp::VARCHAR,''))
--                   ELSE ''END)
-- 	INTO v_audit
-- 	FROM vw_candidate ca
-- 	WHERE ca.rid=p_recid;

	/** Update **/
	UPDATE tb_member
           SET empstatusid=p_empstatusid,
	       placeofwork=TRIM(p_placeofwork),
	       positionid=p_positionid,
	       workaddress=trim(p_workaddress),
	       maritalstatusid=p_maritalstatusid,
	       nameofspouse=TRIM(p_nameofspouse),
	       spousedob=Trim(p_spousedob),
	       spousephone=Trim(p_spousephone),
	       numberofdependants=p_numberofdependants
-- 	       status=p_status,
-- 	       stamp=p_stamp
	 WHERE recid=p_recid;

	/** Get Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vw_member
	 WHERE rid = p_recid;

	/** If there is the need for an audit trail, record it **/
-- 	IF v_audit!='' THEN
-- 		v_audit:='RecId = '||p_recid||v_audit;
-- 		PERFORM fns_audittrail_add(p_userid,'Candidate Edit',v_audit);
-- 	END IF;
	
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_member_edit2(p_recid bigint, p_empstatusid bigint, p_placeofwork text, p_positionid bigint, p_workaddress text, p_maritalstatusid integer, p_nameofspouse character varying, p_spousedob character varying, p_spousephone character varying, p_numberofdependants integer, p_status integer, p_stamp timestamp without time zone, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 361 (class 1255 OID 58395)
-- Name: sp_member_edit3(bigint, character varying, character varying, bigint, character varying, text, character varying, character varying, integer, character varying, integer, character varying, integer, integer, integer, character varying, character varying, integer, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_member_edit3(p_recid bigint, p_snmnextofkin character varying, p_fnmnextofkin character varying, p_relationshipid bigint, p_nxtofkinphone character varying, p_nxtofkinadd text, p_nxtofkinemail character varying, p_dadname character varying, p_daliveordead integer, p_mumname character varying, p_maliveordead integer, p_hometown character varying, p_regionid integer, p_districtid integer, p_tribeid integer, p_contactperson character varying, p_personphone1 character varying, p_status integer, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_audit text;
BEGIN
	v_audit:='';


	/**Prepare Data for Audit **/
-- 	SELECT (CASE WHEN LOWER(TRIM(COALESCE(ca.adt::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_appdate::VARCHAR,''))) 
-- 	          THEN ' :: AppDate (O) = '||TRIM(COALESCE(ca.adt::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_appdate::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.ami::VARCHAR,'')) != TRIM(COALESCE(p_appmodeid::VARCHAR,''))
-- 	          THEN ' :: AppModeId (O) = '||TRIM(COALESCE(ca.ami::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_appmodeid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.apc::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_appcode::VARCHAR,''))) 
-- 	          THEN ' :: AppCode (O) = '||TRIM(COALESCE(ca.apc::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_appcode::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.fci::VARCHAR,'')) != TRIM(COALESCE(p_firstchoiceid::VARCHAR,''))
-- 	          THEN ' :: FirstChoiceId (O) = '||TRIM(COALESCE(ca.fci::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_firstchoiceid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.sci::VARCHAR,'')) != TRIM(COALESCE(p_secondchoiceid::VARCHAR,''))
-- 	          THEN ' :: SecondChoiceId (O) = '||TRIM(COALESCE(ca.sci::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_secondchoiceid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.snm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_surname::VARCHAR,''))) 
-- 	          THEN ' :: Surname (O) = '||TRIM(COALESCE(ca.snm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_surname::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.fnm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_firstname::VARCHAR,''))) 
-- 	          THEN ' :: Firstname (O) = '||TRIM(COALESCE(ca.fnm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_firstname::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.onm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_othernames::VARCHAR,''))) 
-- 	          THEN ' :: Oternames (O) = '||TRIM(COALESCE(ca.onm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_othernames::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.sex::VARCHAR,'')) != TRIM(COALESCE(p_gender::VARCHAR,''))
-- 	          THEN ' :: Gender (O) = '||TRIM(COALESCE(ca.sex::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_gender::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.dob::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_dateofbirth::VARCHAR,''))) 
-- 	          THEN ' :: DateofBirth (O) = '||TRIM(COALESCE(ca.dob::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_dateofbirth::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.twn::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_hometown::VARCHAR,''))) 
-- 	          THEN ' :: HomeTown (O) = '||TRIM(COALESCE(ca.twn::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_hometown::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.pad::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_postaladdress::VARCHAR,''))) 
-- 	          THEN ' :: PostalAddress (O) = '||TRIM(COALESCE(ca.pad::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_postaladdress::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.had::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_homeaddress::VARCHAR,''))) 
-- 	          THEN ' :: HomeAddress (O) = '||TRIM(COALESCE(ca.had::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_homeaddress::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.tel::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_contactno::VARCHAR,''))) 
-- 	          THEN ' :: ContactNo (O) = '||TRIM(COALESCE(ca.tel::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_contactno::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.coi::VARCHAR,'')) != TRIM(COALESCE(p_countryid::VARCHAR,''))
-- 	          THEN ' :: CountryId (O) = '||TRIM(COALESCE(ca.coi::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_countryid::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.eml::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_email::VARCHAR,''))) 
-- 	          THEN ' :: Email (O) = '||TRIM(COALESCE(ca.eml::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_email::VARCHAR,''))
--                   ELSE ''END)||
-- 	--       (CASE WHEN LOWER(TRIM(COALESCE(ca.pho::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_photourl::VARCHAR,''))) 
-- 	--          THEN ' :: PhotoUrl (O) = '||TRIM(COALESCE(ca.pho::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_photourl::VARCHAR,''))
--         --          ELSE ''END)||
-- 	       (CASE WHEN LOWER(TRIM(COALESCE(ca.com::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_comments::VARCHAR,''))) 
-- 	          THEN ' :: Comments (O) = '||TRIM(COALESCE(ca.com::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_comments::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.sts::VARCHAR,'')) != TRIM(COALESCE(p_status::VARCHAR,''))
-- 	          THEN ' :: Status (O) = '||TRIM(COALESCE(ca.sts::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_status::VARCHAR,''))
--                   ELSE ''END)||
-- 	       (CASE WHEN TRIM(COALESCE(ca.stp::VARCHAR,''))!=TRIM( COALESCE(p_stamp::VARCHAR,''))
-- 	          THEN ' :: Stamp (O) = '||TRIM(COALESCE(ca.stp::VARCHAR,''))||', (N) = '||TRIM( COALESCE(p_stamp::VARCHAR,''))
--                   ELSE ''END)
-- 	INTO v_audit
-- 	FROM vw_candidate ca
-- 	WHERE ca.rid=p_recid;

	/** Update **/
	UPDATE tb_member
           SET snmnextofkin=trim(p_snmnextofkin),
	       fnmnextofkin=TRIM(p_fnmnextofkin),
	       relationshipid=p_relationshipid,
	       nxtofkinphone=trim(p_nxtofkinphone),
	       nxtofkinadd=TRIM(p_nxtofkinadd),
	       nxtofkinemail=Trim(p_nxtofkinemail),
	       dadname=Trim(p_dadname),
	       daliveordead=p_daliveordead,
	       mumname=Trim(p_mumname),
	       maliveordead=p_maliveordead,
	       hometown=Trim(p_hometown),
	       regionid=p_regionid,
	       districtid=p_districtid,
	       tribeid=p_tribeid,
	       contactperson=Trim(p_contactperson),
	       personphone1=Trim(p_personphone1)
-- 	       status=p_status,
-- 	       stamp=p_stamp
	 WHERE recid=p_recid;

	/** Get Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vw_member
	 WHERE rid = p_recid;

	/** If there is the need for an audit trail, record it **/
-- 	IF v_audit!='' THEN
-- 		v_audit:='RecId = '||p_recid||v_audit;
-- 		PERFORM fns_audittrail_add(p_userid,'Candidate Edit',v_audit);
-- 	END IF;
	
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_member_edit3(p_recid bigint, p_snmnextofkin character varying, p_fnmnextofkin character varying, p_relationshipid bigint, p_nxtofkinphone character varying, p_nxtofkinadd text, p_nxtofkinemail character varying, p_dadname character varying, p_daliveordead integer, p_mumname character varying, p_maliveordead integer, p_hometown character varying, p_regionid integer, p_districtid integer, p_tribeid integer, p_contactperson character varying, p_personphone1 character varying, p_status integer, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 362 (class 1255 OID 58398)
-- Name: sp_member_find(bigint, character varying, character varying, character varying, character varying, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_member_find(p_recid bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_member
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8,
		   v_name "varchar",
		   v_code "varchar",
		   v_startdate "varchar",
		   v_enddate "varchar",
		   v_shop int8,
		   v_status int4,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_member WHERE
        COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(v_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("mno"::VARCHAR,'') LIKE '%'|| COALESCE(v_code::VARCHAR,COALESCE("mno"::VARCHAR,''))||'%'
         AND "rid" > 0 --avoiding invalid recid
    ORDER BY "nam"
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_member%ROWTYPE;
    pv_startdate character varying;
    pv_enddate character varying;
    v_user_shop bigint;
BEGIN 

-- 	SELECT shopid INTO v_user_shop FROM tbs_user WHERE recid = p_userid; 
-- 	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
-- 	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_member WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("mno"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("mno"::VARCHAR,''))||'%'
         AND "rid" > 0;  --avoiding invalid recid


--          SELECT sum(tot)
-- 	  INTO v_rec.tot
-- 	 FROM vw_member WHERE
--             COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
--          AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
--          AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
--          AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_user_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
--          AND "qty" > 0;

	RETURN NEXT v_rec; 

	OPEN v_cur(p_recid,p_name,p_code,pv_startdate,pv_enddate,v_user_shop,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_member_find(p_recid bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 363 (class 1255 OID 58399)
-- Name: sp_member_photo(bigint, character varying, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_member_photo(p_recid bigint, p_photourl character varying, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_audit text;
BEGIN
	v_audit:='';


	/**Prepare Data for Audit **/
-- 	SELECT (CASE WHEN LOWER(TRIM(COALESCE(vw_candidate.pho::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_photourl::VARCHAR,''))) 
-- 	          THEN ' :: PhotoUrl (O) = '||TRIM(COALESCE(vw_candidate.pho::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_photourl::VARCHAR,''))
--                   ELSE ''END)
-- 	INTO v_audit
-- 	FROM vw_candidate
-- 	WHERE vw_candidate.rid=p_recid;

	/** Update **/
	UPDATE tb_member
           SET photourl=TRIM(p_photourl)
	      -- stamp= p_stamp
	 WHERE recid=p_recid;

	/** Get Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vw_member
	 WHERE rid = p_recid;

	/** If there is the need for an audit trail, record it **/
-- 	IF v_audit!='' THEN
-- 		v_audit:='RecId = '||p_recid||v_audit;
-- 		PERFORM fns_audittrail_add(p_userid,'Candidate Photo Edit',v_audit);
-- 	END IF;
	
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_member_photo(p_recid bigint, p_photourl character varying, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 364 (class 1255 OID 58400)
-- Name: sp_member_photo(character varying, character varying, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_member_photo(p_memberno character varying, p_photourl character varying, p_userid bigint) RETURNS SETOF public.vws_add
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_add%ROWTYPE;
	v_sts 	integer;
	v_audit text;
	v_regstatus integer;
	v_groupid bigint;
	v_photourl varchar;
	v_datecreated timestamp;
	v_status integer;
	v_recid bigint;
	v_intemail	varchar;
BEGIN
	-- Initialize
-- 	v_regstatus := 0;

	v_photourl := TRIM(COALESCE(p_photourl,'sample.png'));
-- 	v_datecreated := CURRENT_TIMESTAMP::TIMESTAMP;
-- 	v_status := 1;
-- 	v_intemail := 'student.template@kpoly.edu.gh';

	--
-- 	SELECT recid INTO v_groupid FROM tb_group 
-- 	 WHERE progyear = 1 AND semester = 1 AND sessionid = 1;
	 
-- 	IF NOT FOUND THEN
-- 	    RAISE EXCEPTION 'Group not found';
-- 	END IF;
	
	-- Verify if completed Payment  
	--v_sts := fn_fees_check();
	--IF v_sts <> 1 THEN
	--    RAISE EXCEPTION 'Incomplete Payments';
	--END IF;
	
	/**Insert Data Into Table**/
	UPDATE tb_member set photourl = v_photourl 
        WHERE membershipno = p_memberno
       RETURNING recid,stamp INTO v_rec;

	/**Obtain Return Data**/
	--SELECT recid,stamp 
	--  INTO v_rec
	--  FROM tb_student
	-- WHERE studentno = p_studentno;

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(st.recid::VARCHAR)||
-- 		' :: StudentNo = '||COALESCE(st.studentno::VARCHAR)||
-- 		' :: MobileNo = '||COALESCE(st.mobileno::VARCHAR)||
-- 		' :: IntEmail = '||COALESCE(st.intemail::VARCHAR)||
-- 		' :: ExtEmail = '||COALESCE(st.extemail::VARCHAR)||
-- 		' :: IDTypeId = '||COALESCE(st.idtypeid::VARCHAR)||
-- 		' :: IDCardNo = '||COALESCE(st.idcardno::VARCHAR)||
-- 		' :: PhotoUrl = '||COALESCE(st.photourl::VARCHAR)||
-- 		' :: ParentName = '||COALESCE(st.parentname::VARCHAR)||
-- 		' :: ParentAddress = '||COALESCE(st.parentaddress::VARCHAR)||
-- 		' :: ParentPhone = '||COALESCE(st.parentphoneno::VARCHAR)||
-- 		' :: RegStatus = '||COALESCE(st.curregstatus::VARCHAR)||
-- 		' :: Status = '||COALESCE(st.status::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(st.stamp::VARCHAR)
-- 	INTO v_audit
-- 	FROM tb_student st
-- 	WHERE st.studentno=p_studentno;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Student Matriculation New',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;

	--RETURN QUERY SELECT * FROM vw_studentz WHERE rid = v_recid;
END;
$$;


ALTER FUNCTION public.sp_member_photo(p_memberno character varying, p_photourl character varying, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 365 (class 1255 OID 58401)
-- Name: sp_memberauxgrp_add(bigint, bigint, bigint, character varying, integer, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_memberauxgrp_add(p_memberid bigint, p_auxgrpid bigint, p_officeid bigint, p_datejoined character varying, p_status integer, p_userid bigint) RETURNS SETOF public.vws_add
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_add%ROWTYPE;
	v_audit text;
BEGIN
	/**Insert Data Into Table**/
	INSERT INTO tb_memberauxgrp (memberid,
			     auxgrpid,
			     officeid,
			     datejoined,
			     status,
			     stamp) 
	     VALUES 	    (p_memberid,
			     p_auxgrpid,
			     p_officeid,
			     TRIM(p_datejoined)::date,
			     p_status,
			     now());

	/**Obtain Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vw_memberauxgrp
	 WHERE rid IN (SELECT MAX(rid) FROM vw_memberauxgrp);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ce.rid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ce.cid::VARCHAR)||
-- 		' :: SubjectId = '||COALESCE(ce.sji::VARCHAR)||
-- 		' :: GradeId = '||COALESCE(ce.gdi::VARCHAR)||
-- 		' :: CertDate = '||COALESCE(ce.cdt::VARCHAR)||
-- 		' :: IndexNo = '||COALESCE(ce.ixn::VARCHAR)||
-- 		' :: Status = '||COALESCE(ce.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ce.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ce.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_certificate ce
-- 	WHERE ce.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Certificate Add',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_memberauxgrp_add(p_memberid bigint, p_auxgrpid bigint, p_officeid bigint, p_datejoined character varying, p_status integer, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 223 (class 1259 OID 58402)
-- Name: tb_moneypaid; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_moneypaid (
    recid bigint NOT NULL,
    rcvname character varying,
    amount double precision,
    paidcode character varying,
    status integer DEFAULT 1,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    datcreated character varying(100),
    userid bigint
);


ALTER TABLE public.tb_moneypaid OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 58411)
-- Name: vw_moneypaid; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_moneypaid AS
 SELECT mp.recid AS rid,
    mp.rcvname AS nam,
    mp.amount AS amt,
    mp.paidcode AS pcd,
    mp.status AS sts,
    mp.datecreated AS dcd,
    mp.stamp AS stp,
    mp.datcreated AS dat,
    mp.userid AS uid,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm
   FROM public.tbs_user us,
    public.tb_moneypaid mp
  WHERE (us.recid = mp.userid);


ALTER TABLE public.vw_moneypaid OWNER TO postgres;

--
-- TOC entry 366 (class 1255 OID 58415)
-- Name: sp_money_add(character varying, double precision, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_money_add(p_rcvname character varying, p_amount double precision, p_userid bigint) RETURNS SETOF public.vw_moneypaid
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_moneypaid%ROWTYPE;
	v_recc vw_salescode%ROWTYPE;
	v_audit text;
	v_datcreated character varying;
	v_paidcode character varying;
	v_sequence bigint;
	rd RECORD;
BEGIN
	select now()::date::character varying into v_datcreated;
	select max(recid) + 1 into v_sequence from tb_moneypaid;
	v_paidcode:=fn_moneycodeno_gen(v_sequence);
	/**Insert Data Into Table**/
	INSERT INTO tb_moneypaid(rcvname,
				 amount,
				 paidcode,
				 datcreated,
				 userid) 
	     VALUES 	    (TRIM(p_rcvname),
			     p_amount,
			     TRIM(v_paidcode),
			     TRIM(v_datcreated),
			     p_userid);
			     
	

	/**Obtain Return Data**/
	SELECT * 
	  INTO v_rec
	  FROM vw_moneypaid
	 WHERE rid IN (SELECT MAX(rid) FROM vw_moneypaid);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_money_add(p_rcvname character varying, p_amount double precision, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 367 (class 1255 OID 58416)
-- Name: sp_officeheld_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_officeheld_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_officeheld WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_officeheld_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 368 (class 1255 OID 58425)
-- Name: sp_pcat_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_pcat_combo(p_userid bigint) RETURNS SETOF public.vw_category
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_sectionid int8)
    FOR SELECT * FROM vw_category WHERE sid = v_sectionid	
	ORDER BY "rid" ASC;

    v_rec  vw_category%ROWTYPE;
    v_sid bigint;
BEGIN 
	SELECT sectionid INTO v_sid FROM tbs_user WHERE recid=p_userid;
	OPEN v_cur(v_sid); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_pcat_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 58320)
-- Name: tb_productstatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_productstatus (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    shortcode character varying(200),
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tb_productstatus OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 58324)
-- Name: tb_shop; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_shop (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    shortcode character varying(200),
    status integer DEFAULT 1,
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tb_shop OWNER TO postgres;

--
-- TOC entry 307 (class 1259 OID 59084)
-- Name: tb_unit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_unit (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    shortcode character varying(200),
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tb_unit OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 66927)
-- Name: vw_product; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_product AS
 SELECT pd.recid AS rid,
    pd.recname AS nam,
    pd.productcode AS pdc,
    pd.price AS prc,
    pd.quantity AS qty,
    pd.categoryid AS cid,
    ct.recname AS ctn,
    pd.userid AS usi,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    pd.pimg AS pmg,
    pd.expirydate AS edt,
    pd.productstatusid AS pts,
    ps.recname AS psn,
    pd.status AS sts,
    pd.datecreated AS dcd,
    pd.stamp AS stp,
    pd.datcreated AS dat,
    (pd.quantity * pd.price) AS tot,
    pd.extra AS ext,
    pd.shopid AS shi,
    sh.recname AS shn,
    pd.ratepersinglebox AS rsb,
    pd.wholesaleratepersinglebox AS wrsb,
    pd.quantityperbox AS qpb,
    pd.unit AS uni,
    un.shortcode AS ush,
    un.recname AS unt,
    pd.nqy,
    pd.bulkqty AS blk,
    pd.buyingprice AS bpr,
    pd.price AS sprc
   FROM public.tbs_user us,
    public.tb_category ct,
    public.tb_productstatus ps,
    public.tb_product pd,
    public.tb_shop sh,
    public.tb_unit un
  WHERE ((us.recid = pd.userid) AND (ct.recid = pd.categoryid) AND (ps.recid = pd.productstatusid) AND (pd.shopid = sh.recid) AND (pd.status = 1) AND (un.recid = pd.unit));


ALTER TABLE public.vw_product OWNER TO postgres;

--
-- TOC entry 418 (class 1255 OID 66936)
-- Name: sp_product_add(character varying, double precision, double precision, double precision, double precision, integer, integer, bigint, bigint, character varying, text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_product_add(p_recname character varying, p_buyingprice double precision, p_retailprice1 double precision, p_retailprice2 double precision, p_wholesaleprice double precision, p_quantity integer, p_qtygroups integer, p_category bigint, p_productunit bigint, p_expiry character varying, p_description text, p_userid bigint) RETURNS SETOF public.vw_product
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_product%ROWTYPE;
	v_audit text;
	v_productid bigint;
	v_quantity integer;
	v_bulkqty integer;
	v_ratepersinglebox double precision;
	v_userid bigint;
	v_expirydate character varying;
	v_datcreated character varying;
	v_date character varying;
BEGIN
	select now()::date::character varying into v_datcreated;
	SELECT substring(p_expiry,0,11) INTO v_date;

	SELECT round(p_retailprice1::numeric/p_quantity::numeric,2)::double precision INTO v_ratepersinglebox;
	v_bulkqty := p_quantity * p_qtygroups;
	/**Insert Data Into Table**/
	INSERT INTO tb_product(recname,
-- 			     productcode,
			     price,
			     quantity,
			     categoryid,
			     userid,
-- 			     barcode,
			     expirydate,
			     productstatusid,
			     status,
			     datecreated,
			     stamp,
			     datcreated,
			     unit,
			     buyingprice,
			     shopid,
			     quantityperbox,
			     wholesaleratepersinglebox,
			     ratepersinglebox,
			     bulkqty) 
	     VALUES 	    (TRIM(p_recname),
-- 			     TRIM(p_productcode),
			     p_retailprice1,
			     p_quantity,
			     p_category,
			     p_userid,
-- 			     TRIM(p_barcode),
			     TRIM(v_date),
			     1,
			     1,
			     now(),
			     now(),
			     TRIM(v_datcreated),
			     p_productunit,
			     p_buyingprice,
			     20,
			     p_qtygroups,
			     p_wholesaleprice,
			     p_retailprice2,
			     v_bulkqty);
			     
	-- SELECT rid,qty,prc,usi,edt
-- 	  INTO v_productid,v_quantity,v_price,v_userid,v_expirydate
-- 	  FROM vw_product
-- 	 WHERE rid IN (SELECT MAX(rid) FROM vw_product);
-- 
-- 	INSERT INTO tb_productlog(productid,
-- 				quantity,
-- 				price,
-- 				userid,
-- 				expirydate,
-- 				status,
-- 				datecreated,
-- 				stamp,
-- 				datcreated,
-- 				amountadded) 
-- 	     VALUES 	    (v_productid,
-- 			     v_quantity,
-- 			     v_price,
-- 			     v_userid,
-- 			     v_expirydate,
-- 			     1,
-- 			     now(),
-- 			     now(),
-- 			     TRIM(v_datcreated),
-- 			     p_quantity);

	/**Obtain Return Data**/
	SELECT * 
	  INTO v_rec
	  FROM vw_product
	 WHERE rid IN (SELECT MAX(rid) FROM vw_product);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed
-- 	WHERE ed.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Education Add',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_product_add(p_recname character varying, p_buyingprice double precision, p_retailprice1 double precision, p_retailprice2 double precision, p_wholesaleprice double precision, p_quantity integer, p_qtygroups integer, p_category bigint, p_productunit bigint, p_expiry character varying, p_description text, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 417 (class 1255 OID 66935)
-- Name: sp_product_edit(bigint, character varying, double precision, double precision, double precision, integer, integer, bigint, bigint, text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_product_edit(p_recid bigint, p_recname character varying, p_buyingprice double precision, p_retailprice double precision, p_wholesaleprice double precision, p_quantity integer, p_qtygroups integer, p_categoryid bigint, p_productunitid bigint, p_description text, p_userid bigint) RETURNS SETOF public.vw_product
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_cur   CURSOR(v_recid int8)
	FOR SELECT * FROM vw_product WHERE rid=v_recid;
	v_rec vw_product%ROWTYPE;
	v_audit text;
	v_productid bigint;
	v_quantity integer;
	v_price double precision;
	v_userid bigint;
	v_qty integer;
	v_qtb integer;
	v_bulk integer;
	v_expirydate character varying;
	v_datcreated character varying;
BEGIN
	select now()::date::character varying into v_datcreated;
	select quantity,quantityperbox,bulkqty into v_qty,v_qtb,v_bulk from tb_product where recid=p_recid;
	
	/**Update Data Into Table**/
	UPDATE tb_product 
	SET
	recname = TRIM(p_recname),
	buyingprice=p_buyingprice,
	price=p_retailprice,
	wholesaleratepersinglebox=p_wholesaleprice,
	quantity=p_quantity + v_qty,
	quantityperbox=p_qtygroups,
	categoryid = p_categoryid,
	unit = p_productunitid,
	bulkqty = (p_quantity*p_qtygroups)+v_bulk,
	userid=p_userid,
	stamp=NOW() 
	WHERE recid=p_recid;
			     
	SELECT rid,qty,prc,usi,edt
	  INTO v_productid,v_quantity,v_price,v_userid,v_expirydate
	  FROM vw_product
	 WHERE rid = p_recid;

	-- INSERT INTO tb_productlog(productid,
-- 				quantity,
-- 				price,
-- 				userid,
-- 				expirydate,
-- 				status,
-- 				datecreated,
-- 				stamp,
-- 				datcreated,
-- 				amountadded) 
-- 	     VALUES 	    (v_productid,
-- 			     v_quantity,
-- 			     v_price,
-- 			     v_userid,
-- 			     v_expirydate,
-- 			     1,
-- 			     now(),
-- 			     now(),
-- 			     TRIM(v_datcreated),
-- 			     p_quantity);

	/**Obtain Return Data**/
	OPEN v_cur(p_recid); 

	/**Return Data**/
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_product_edit(p_recid bigint, p_recname character varying, p_buyingprice double precision, p_retailprice double precision, p_wholesaleprice double precision, p_quantity integer, p_qtygroups integer, p_categoryid bigint, p_productunitid bigint, p_description text, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 416 (class 1255 OID 66934)
-- Name: sp_product_edit(bigint, character varying, double precision, double precision, double precision, double precision, integer, integer, bigint, bigint, text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_product_edit(p_recid bigint, p_recname character varying, p_buyingprice double precision, p_retailprice1 double precision, p_retailprice2 double precision, p_wholesaleprice double precision, p_quantity integer, p_qtygroups integer, p_categoryid bigint, p_productunitid bigint, p_description text, p_userid bigint) RETURNS SETOF public.vw_product
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_cur   CURSOR(v_recid int8)
	FOR SELECT * FROM vw_product WHERE rid=v_recid;
	v_rec vw_product%ROWTYPE;
	v_audit text;
	v_productid bigint;
	v_quantity integer;
	v_price double precision;
	v_userid bigint;
	v_qty integer;
	v_qtb integer;
	v_bulk integer;
	v_expirydate character varying;
	v_datcreated character varying;
BEGIN
	select now()::date::character varying into v_datcreated;
	select quantity,quantityperbox,bulkqty into v_qty,v_qtb,v_bulk from tb_product where recid=p_recid;
	
	/**Update Data Into Table**/
	UPDATE tb_product 
	SET
	recname = TRIM(p_recname),
	buyingprice=p_buyingprice,
	price=p_retailprice1,
	ratepersinglebox=p_retailprice2,
	wholesaleratepersinglebox=p_wholesaleprice,
	quantity=p_quantity + v_qty,
	quantityperbox=p_qtygroups,
	categoryid = p_categoryid,
	unit = p_productunitid,
	bulkqty = (p_quantity*p_qtygroups)+v_bulk,
	userid=p_userid,
	stamp=NOW() 
	WHERE recid=p_recid;
			     
	SELECT rid,qty,prc,usi,edt
	  INTO v_productid,v_quantity,v_price,v_userid,v_expirydate
	  FROM vw_product
	 WHERE rid = p_recid;

	-- INSERT INTO tb_productlog(productid,
-- 				quantity,
-- 				price,
-- 				userid,
-- 				expirydate,
-- 				status,
-- 				datecreated,
-- 				stamp,
-- 				datcreated,
-- 				amountadded) 
-- 	     VALUES 	    (v_productid,
-- 			     v_quantity,
-- 			     v_price,
-- 			     v_userid,
-- 			     v_expirydate,
-- 			     1,
-- 			     now(),
-- 			     now(),
-- 			     TRIM(v_datcreated),
-- 			     p_quantity);

	/**Obtain Return Data**/
	OPEN v_cur(p_recid); 

	/**Return Data**/
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_product_edit(p_recid bigint, p_recname character varying, p_buyingprice double precision, p_retailprice1 double precision, p_retailprice2 double precision, p_wholesaleprice double precision, p_quantity integer, p_qtygroups integer, p_categoryid bigint, p_productunitid bigint, p_description text, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 58432)
-- Name: tb_productlog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_productlog (
    recid bigint NOT NULL,
    productid bigint,
    quantity integer,
    price double precision,
    userid bigint,
    expirydate character varying,
    status integer DEFAULT 0,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    datcreated character varying(100),
    extra integer,
    amountadded integer,
    shopid bigint,
    cuserid bigint DEFAULT '-1'::integer
);


ALTER TABLE public.tb_productlog OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 58442)
-- Name: vw_productlogg; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_productlogg AS
 SELECT pl.recid AS rid,
    pd.recid AS pid,
    pd.recname AS nam,
    pd.productcode AS pdc,
    pl.price AS prc,
    pl.quantity AS qty,
    pd.categoryid AS cid,
    ct.recname AS ctn,
    pd.userid AS usi,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    pl.expirydate AS edt,
    pl.status AS sts,
    pl.datecreated AS dcd,
    pl.stamp AS stp,
    pl.datcreated AS dat,
    pl.shopid AS shi,
    sh.recname AS shn,
    pd.pimg AS pmg
   FROM public.tbs_user us,
    public.tb_category ct,
    public.tb_product pd,
    public.tb_productlog pl,
    public.tb_shop sh
  WHERE ((us.recid = pl.userid) AND (pd.recid = pl.productid) AND (ct.recid = pd.categoryid) AND (sh.recid = pl.shopid));


ALTER TABLE public.vw_productlogg OWNER TO postgres;

--
-- TOC entry 415 (class 1255 OID 58447)
-- Name: sp_product_log_find(bigint, bigint, bigint, character varying, character varying, character varying, character varying, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_product_log_find(p_recid bigint, p_productid bigint, p_quantity bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_productlogg
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8,
		   v_name "varchar",
		   v_code "varchar",
		   v_startdate "varchar",
		   v_enddate "varchar",
		   v_shop int8,
		   v_status int4,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_productlogg WHERE
        COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
    AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(v_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
    AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(v_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
    AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(v_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(v_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND "qty" > 0 and sts=1 and "shi"=v_shop --avoiding invalid recid
    ORDER BY "ctn","nam"
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_productlogg%ROWTYPE;
    pv_startdate character varying;
    pv_enddate character varying;
    v_user_shop bigint;
BEGIN 

	SELECT shopid INTO v_user_shop FROM tbs_user WHERE recid = p_userid; 
	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_productlogg WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
         AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
--          AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_user_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
         AND "qty" > 0 and "sts"=1 and "shi"=v_user_shop;  --avoiding invalid recid


--          SELECT sum(tot)
-- 	  INTO v_rec.tot
-- 	 FROM vw_productlogg WHERE
--             COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
--          AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
--          AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
--          AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_user_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
--          AND "qty" > 0;

	RETURN NEXT v_rec; 

	OPEN v_cur(p_recid,p_name,p_code,pv_startdate,pv_enddate,v_user_shop,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_product_log_find(p_recid bigint, p_productid bigint, p_quantity bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 414 (class 1255 OID 58448)
-- Name: sp_product_log_update_find(bigint, bigint, bigint, character varying, character varying, character varying, character varying, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_product_log_update_find(p_recid bigint, p_productid bigint, p_quantity bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_productlogg
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8,
		   v_name "varchar",
		   v_code "varchar",
		   v_startdate "varchar",
		   v_enddate "varchar",
		   v_shop int8,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_productlogg WHERE
--         COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
     COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(v_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
    AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(v_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
    AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(v_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(v_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
--     AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND "qty" > 0 and sts=1 and "shi"=v_shop --avoiding invalid recid
    ORDER BY "ctn","nam"
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_productlogg%ROWTYPE;
    pv_startdate character varying;
    pv_enddate character varying;
    v_user_shop bigint;
BEGIN 

	SELECT shopid INTO v_user_shop FROM tbs_user WHERE recid = p_userid; 
	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;

	UPDATE tb_productlog SET status=0,cuserid=p_userid WHERE recid=p_recid;
	UPDATE tb_product SET quantity=quantity+p_quantity WHERE recid=p_productid;
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_productlogg WHERE
--             COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
          COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
         AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
--          AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_user_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
         AND "qty" > 0 and "sts"=1 and "shi"=v_user_shop;  --avoiding invalid recid


--          SELECT sum(tot)
-- 	  INTO v_rec.tot
-- 	 FROM vw_productlogg WHERE
--             COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
--          AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
--          AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
--          AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_user_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
--          AND "qty" > 0;

	RETURN NEXT v_rec; 

	OPEN v_cur(p_recid,p_name,p_code,pv_startdate,pv_enddate,v_user_shop,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_product_log_update_find(p_recid bigint, p_productid bigint, p_quantity bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 411 (class 1255 OID 60535)
-- Name: sp_productcategories_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_productcategories_combo(p_userid bigint) RETURNS SETOF public.vw_category
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_userid int8)
    FOR SELECT * FROM vw_category ORDER BY "rid" ASC;
    v_rec  vw_category%ROWTYPE;
BEGIN 

-- 	SELECT shopid INTO v_user_shop FROM tbs_user WHERE recid = p_userid; 
-- 	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
-- 	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;
	--COUNT VALID RECORD
-- 	SELECT COUNT(*)
-- 	  INTO v_rec.rid
-- 	 FROM vw_category WHERE
--            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
--         AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
--         AND COALESCE("shc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("shc"::VARCHAR,''))||'%'
-- --         AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
--         AND "rid" > 0;  --avoiding invalid recid


-- 	RETURN NEXT v_rec; 

	OPEN v_cur(p_userid); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_productcategories_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 413 (class 1255 OID 66932)
-- Name: sp_products_find(bigint, character varying, character varying, character varying, character varying, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_products_find(p_recid bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_product
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8,
		   v_name "varchar",
		   v_code "varchar",
		   v_startdate "varchar",
		   v_enddate "varchar",
		   v_shop int8,
		   v_status int4,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_product WHERE
        COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
    AND COALESCE("nam"::VARCHAR,'') iLIKE '%'|| COALESCE(v_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
    AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(v_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
    AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(v_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(v_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND "qty" > 0 --avoiding invalid recid
    ORDER BY "rid" DESC
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_product%ROWTYPE;
    pv_startdate character varying;
    pv_enddate character varying;
    v_user_shop bigint;
BEGIN 

	SELECT shopid INTO v_user_shop FROM tbs_user WHERE recid = p_userid; 
	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_product WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') iLIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
         AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
         AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_user_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
         AND "qty" > 0;  --avoiding invalid recid


         SELECT sum(tot)
	  INTO v_rec.tot
	 FROM vw_product WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') iLIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
         AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
         AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_user_shop::VARCHAR ,COALESCE("shi"::VARCHAR,''))
         AND "qty" > 0;

	RETURN NEXT v_rec; 

	OPEN v_cur(p_recid,p_name,p_code,pv_startdate,pv_enddate,v_user_shop,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_products_find(p_recid bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 422 (class 1255 OID 67297)
-- Name: sp_products_find(bigint, character varying, character varying, character varying, character varying, bigint, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_products_find(p_recid bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_shopid bigint, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_product
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8,
		   v_name "varchar",
		   v_code "varchar",
		   v_startdate "varchar",
		   v_enddate "varchar",
		   v_shopid int8,
		   v_status int4,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_product WHERE
        COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
    AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(v_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
    AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(v_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
    AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(v_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(v_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_shopid::VARCHAR ,COALESCE("shi"::VARCHAR,''))
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND "rid" > 0 --avoiding invalid recid
    ORDER BY "ctn","nam"
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_product%ROWTYPE;
    pv_startdate character varying;
    pv_enddate character varying;
    v_user_shop bigint;
    v_shi bigint;
    v_roi bigint;
BEGIN 

	SELECT shopid INTO v_user_shop FROM tbs_user WHERE recid = p_userid; 
	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;


	SELECT roi INTO v_roi FROM vws_user WHERE rid=p_userid;
	IF(v_roi <> 2) THEN
		SELECT shopid INTO v_shi FROM tbs_user WHERE recid=p_userid; 
	ELSE
		v_shi = p_shopid;
	END IF;
	
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_product WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
         AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
         AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_shi::VARCHAR ,COALESCE("shi"::VARCHAR,''))
         AND "rid" > 0;  --avoiding invalid recid


         SELECT sum(tot)
	  INTO v_rec.tot
	 FROM vw_product WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
         AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
         AND COALESCE("shi"::VARCHAR,'') = COALESCE(v_shi::VARCHAR ,COALESCE("shi"::VARCHAR,''))
         AND "rid" > 0;

	RETURN NEXT v_rec; 

	OPEN v_cur(p_recid,p_name,p_code,pv_startdate,pv_enddate,v_shi,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_products_find(p_recid bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_shopid bigint, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 369 (class 1255 OID 58449)
-- Name: sp_profession_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_profession_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_profession WHERE ast = 1
	ORDER BY "rid" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_profession_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 370 (class 1255 OID 58450)
-- Name: sp_profession_combo(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_profession_combo(p_professionid bigint, p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_professionid int8)
    FOR SELECT rid,nam FROM vw_profession
	WHERE COALESCE("pfi"::VARCHAR,'')= COALESCE(v_professionid::VARCHAR,COALESCE("pfi"::VARCHAR,'') )
	  AND ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur(p_regionid); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_profession_combo(p_professionid bigint, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 371 (class 1255 OID 58451)
-- Name: sp_region_combo(bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sp_region_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_region WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_region_combo(p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 372 (class 1255 OID 58452)
-- Name: sp_relationship_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_relationship_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_relationship
	WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_relationship_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 373 (class 1255 OID 58453)
-- Name: sp_restype_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_restype_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vw_residenttype
	WHERE ast = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_restype_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 374 (class 1255 OID 58454)
-- Name: sp_sales_add(text, character varying, character varying, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_sales_add(p_products text, p_customername character varying, p_phone character varying, p_userid bigint) RETURNS SETOF public.vw_saless
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_saless%ROWTYPE;
	v_recc vw_salescode%ROWTYPE;
	v_audit text;
	v_datcreated character varying;
	v_salescode character varying;
	v_sequence bigint;
	rd RECORD;
BEGIN
	select now()::date::character varying into v_datcreated;
	select max(recid) + 1 into v_sequence from tb_salescode;
	v_salescode:=fn_salescodeno_gen(v_sequence);
	/**Insert Data Into Table**/
	INSERT INTO tb_salescode(salescode,
				 userid,
				 status,
				 datcreated,
				 customername,
				 phone) 
	     VALUES 	    (TRIM(v_salescode),
			     p_userid,
			     1,
			     TRIM(v_datcreated),
			     TRIM(p_customername),
			     TRIM(p_phone));
			     
	

	/**Obtain Return Data**/
	SELECT * 
	  INTO v_recc
	  FROM vw_salescode
	 WHERE rid IN (SELECT MAX(rid) FROM vw_salescode);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed
-- 	WHERE ed.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Education Add',v_audit);
	FOR rd IN  select * from 
	    (select  t1.arr[1]::bigint as pid, v_recc.rid as sid, t1.arr[2]::integer as qty, t1.arr[3]::double precision as prc, t1.arr[4]::integer as sts 
	       from 
		(select string_to_array(data,'|') as arr  
		   from regexp_split_to_table(p_products,'::') as data
		) t1

	    ) as t2 LOOP

	    PERFORM sp_sales_add_bulk(rd.pid,rd.qty,rd.prc,rd.sid,rd.sts,p_userid);

	END LOOP;

	SELECT * 
	  INTO v_rec
	  FROM vw_saless
	 WHERE sci=rd.sid;
	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_sales_add(p_products text, p_customername character varying, p_phone character varying, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 375 (class 1255 OID 58455)
-- Name: sp_sales_add(text, character varying, double precision, bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_sales_add(p_products text, p_phone character varying, p_amount double precision, p_paymenttypeid bigint, p_userid bigint) RETURNS SETOF public.vw_saless
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_saless%ROWTYPE;
	v_recc vw_salescode%ROWTYPE;
	v_audit text;
	v_datcreated character varying;
	v_salescode character varying;
	v_sequence bigint;
	rd RECORD;
	v_memberno character varying;
BEGIN

	SELECT memberno INTO v_memberno FROM tb_member WHERE memberno LIKE '%'||p_phone||'%';
	IF NOT FOUND THEN
		RAISE EXCEPTION '::DBERR-0232::No Record Found for this Code: %::',p_phone;
	END IF;
	
	select now()::date::character varying into v_datcreated;
	select max(recid) + 1 into v_sequence from tb_salescode;
	v_salescode:=fn_salescodeno_gen(v_sequence);
	/**Insert Data Into Table**/
	INSERT INTO tb_salescode(salescode,
				 userid,
				 status,
				 datcreated,
				 phone,
				 paymenttypeid,
				 amountpaid) 
	     VALUES 	    (TRIM(v_salescode),
			     p_userid,
			     1,
			     TRIM(v_datcreated),
			     TRIM(v_memberno),
			     p_paymenttypeid,
			     p_amount);
			     
	

	/**Obtain Return Data**/
	SELECT * 
	  INTO v_recc
	  FROM vw_salescode
	 WHERE rid IN (SELECT MAX(rid) FROM vw_salescode);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed
-- 	WHERE ed.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Education Add',v_audit);
	FOR rd IN  select * from 
	    (select  t1.arr[1]::bigint as pid, v_recc.rid as sid, t1.arr[2]::integer as qty, t1.arr[3]::double precision as prc, t1.arr[4]::integer as sts 
	       from 
		(select string_to_array(data,'|') as arr  
		   from regexp_split_to_table(p_products,'::') as data
		) t1

	    ) as t2 LOOP

	    PERFORM sp_sales_add_bulk(rd.pid,rd.qty,rd.prc,rd.sid,rd.sts,p_userid);

	END LOOP;

	SELECT * 
	  INTO v_rec
	  FROM vw_saless
	 WHERE sci=rd.sid;
	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_sales_add(p_products text, p_phone character varying, p_amount double precision, p_paymenttypeid bigint, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 376 (class 1255 OID 58456)
-- Name: sp_sales_add_bulk(bigint, integer, double precision, bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_sales_add_bulk(p_productid bigint, p_quantity integer, p_price double precision, p_salescodeid bigint, p_status integer, p_userid bigint) RETURNS SETOF public.vw_saless
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_saless%ROWTYPE;
	v_recc vw_salescode%ROWTYPE;
	v_audit text;
	v_datcreated character varying;
	v_salescode character varying;
	v_sequence bigint;
	v_quantity integer;
	rd RECORD;
BEGIN
	select now()::date::character varying into v_datcreated;
-- 	select max(recid) + 1 into v_sequence from tb_salescode;
-- 	v_salescode:=fn_salescodeno_gen(v_sequence);
	/**Insert Data Into Table**/
	INSERT INTO tb_sales(productid,
			     quantity,
			     amount,
			     salescodeid,
			     datcreated) 
	     VALUES 	    (p_productid,
			     p_quantity,
			     p_price,
			     p_salescodeid,
			     TRIM(v_datcreated));
			     
	SELECT quantity INTO v_quantity FROM tb_product WHERE recid=p_productid;
	
	UPDATE tb_product SET quantity=(v_quantity-p_quantity),stamp=NOW() WHERE recid=p_productid;
	/**Obtain Return Data**/
	SELECT * 
	  INTO v_rec
	  FROM vw_saless
	 WHERE sci=p_salescodeid;

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed
-- 	WHERE ed.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Education Add',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_sales_add_bulk(p_productid bigint, p_quantity integer, p_price double precision, p_salescodeid bigint, p_status integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 419 (class 1255 OID 66919)
-- Name: sp_sales_add_bulk_web(bigint, integer, character varying, bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_sales_add_bulk_web(p_productid bigint, p_quantity integer, p_price_tag character varying, p_salescodeid bigint, p_status integer, p_userid bigint) RETURNS SETOF public.vw_saless
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_saless%ROWTYPE;
	v_recc vw_salescode%ROWTYPE;
	v_audit text;
	v_datcreated character varying;
	v_salescode character varying;
	v_sequence bigint;
	v_quantity double precision;
	v_bulkquantity integer;
	v_qtyperbox integer;
	v_price double precision;
	v_prcqty double precision;
	rd RECORD;
BEGIN
	select now()::date::character varying into v_datcreated;
-- 	select max(recid) + 1 into v_sequence from tb_salescode;
-- 	v_salescode:=fn_salescodeno_gen(v_sequence);
--      SELECT * FROM sp_sales_add_web('mxn',1,17,'567|1|prc|1::566|1|rsb|1::565|1|wrsb|1',3)

	IF p_price_tag = 'prc' THEN
		SELECT price INTO v_price FROM tb_product WHERE recid=p_productid;
		-- use prc
	ELSIF p_price_tag = 'rsb' THEN
		-- use rsb
		SELECT ratepersinglebox INTO v_price FROM tb_product WHERE recid=p_productid;
		
	ELSIF p_price_tag = 'wrsb' THEN
		-- use wrsb
		SELECT wholesaleratepersinglebox INTO v_price FROM tb_product WHERE recid=p_productid;
	END IF;
	
	/**Insert Data Into Table**/
	INSERT INTO tb_sales(productid,
			     quantity,
			     amount,
			     salescodeid,
			     datcreated) 
	     VALUES 	    (p_productid,
			     p_quantity,
			     v_price,
			     p_salescodeid,
			     
			     TRIM(v_datcreated));

	SELECT quantity,quantityperbox,bulkqty INTO v_quantity,v_qtyperbox,v_bulkquantity FROM tb_product WHERE recid=p_productid;		     

        IF p_price_tag = 'prc' THEN
		SELECT ROUND(((v_bulkquantity::decimal - p_quantity::decimal)/v_qtyperbox::decimal)::numeric,2) INTO v_prcqty;

		UPDATE tb_product SET 
		quantity= v_prcqty,
		bulkqty=(v_bulkquantity - p_quantity),
		stamp=NOW()
		WHERE recid=p_productid;
	
	ELSIF p_price_tag = 'rsb' OR p_price_tag = 'wrsb' THEN
		
		UPDATE tb_product SET 
		quantity=(v_quantity - p_quantity),
		bulkqty=(v_bulkquantity - p_quantity * v_qtyperbox),
		stamp=NOW()
		WHERE recid=p_productid;
		
	END IF;
			     
	
-- 	UPDATE tb_product SET quantity=(v_quantity-p_quantity),stamp=NOW() WHERE recid=p_productid;
	/**Obtain Return Data**/
	SELECT * 
	  INTO v_rec
	  FROM vw_saless
	 WHERE sci=p_salescodeid;

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed
-- 	WHERE ed.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Education Add',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_sales_add_bulk_web(p_productid bigint, p_quantity integer, p_price_tag character varying, p_salescodeid bigint, p_status integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 412 (class 1255 OID 66918)
-- Name: sp_sales_add_web(character varying, bigint, double precision, text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_sales_add_web(p_phone character varying, p_paymenttypeid bigint, p_amount double precision, p_products text, p_userid bigint) RETURNS SETOF public.vw_saless
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_saless%ROWTYPE;
	v_recc vw_salescode%ROWTYPE;
	v_audit text;
	v_datcreated character varying;
	v_salescode character varying;
	v_sequence bigint;
	rd RECORD;
	v_memberno character varying;
BEGIN

	SELECT memberno INTO v_memberno FROM tb_member WHERE memberno LIKE '%'||p_phone||'%';
	IF NOT FOUND THEN
		RAISE EXCEPTION '::DBERR-0232::No Record Found for this Code: %::',p_phone;
	END IF;
	
	select now()::date::character varying into v_datcreated;
	select max(recid) + 1 into v_sequence from tb_salescode;
	v_salescode:=fn_salescodeno_gen(v_sequence);
	/**Insert Data Into Table**/
	INSERT INTO tb_salescode(salescode,
				 userid,
				 status,
				 datcreated,
				 phone,
				 paymenttypeid,
				 amountpaid) 
	     VALUES 	    (TRIM(v_salescode),
			     p_userid,
			     1,
			     TRIM(v_datcreated),
			     TRIM(v_memberno),
			     p_paymenttypeid,
			     p_amount);
			     
	

	/**Obtain Return Data**/
	SELECT * 
	  INTO v_recc
	  FROM vw_salescode
	 WHERE rid IN (SELECT MAX(rid) FROM vw_salescode);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed
-- 	WHERE ed.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Education Add',v_audit);
	FOR rd IN  select * from 
	    (select  t1.arr[1]::bigint as pid, v_recc.rid as sid, t1.arr[2]::integer as qty, t1.arr[3]::VARCHAR as prc, t1.arr[4]::integer as sts 
	       from 
		(select string_to_array(data,'|') as arr  
		   from regexp_split_to_table(p_products,'::') as data
		) t1

	    ) as t2 LOOP

	    PERFORM sp_sales_add_bulk_web(rd.pid,rd.qty,rd.prc,rd.sid,rd.sts,p_userid);

	END LOOP;

	SELECT * 
	  INTO v_rec
	  FROM vw_saless
	 WHERE sci=rd.sid;
	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_sales_add_web(p_phone character varying, p_paymenttypeid bigint, p_amount double precision, p_products text, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 377 (class 1255 OID 58457)
-- Name: sp_sales_find(bigint, character varying, character varying, character varying, character varying, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_sales_find(p_recid bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_saless
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8,
		   v_name "varchar",
		   v_code "varchar",
		   v_startdate "varchar",
		   v_enddate "varchar",
		   v_status int4,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_saless WHERE
        COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
    AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(v_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
    AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(v_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
    AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(v_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
    AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(v_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--     AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND "rid" > 0 --avoiding invalid recid
    ORDER BY "dat"
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_saless%ROWTYPE;
    pv_startdate character varying;
    pv_enddate character varying;
BEGIN 

	SELECT * from SUBSTRING(p_startdate,1,10) INTO pv_startdate;
	SELECT * from SUBSTRING(p_enddate,1,10) INTO pv_enddate;
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_saless WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
         AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
         AND "rid" > 0;  --avoiding invalid recid


         SELECT sum(tot)
	  INTO v_rec.tot
	 FROM vw_saless WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
         AND COALESCE("nam"::VARCHAR,'') LIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
         AND COALESCE("pdc"::VARCHAR,'') LIKE '%'|| COALESCE(p_code::VARCHAR,COALESCE("pdc"::VARCHAR,''))||'%'
         AND COALESCE("dat"::VARCHAR,'2000-01-01')>= COALESCE(pv_startdate::VARCHAR,COALESCE("dat"::VARCHAR,''))
         AND COALESCE("dat"::VARCHAR,'2000-01-01')<= COALESCE(pv_enddate::VARCHAR,COALESCE("dat"::VARCHAR,''))
--          AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
         AND "rid" > 0;

	RETURN NEXT v_rec; 

	OPEN v_cur(p_recid,p_name,p_code,pv_startdate,pv_enddate,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_sales_find(p_recid bigint, p_name character varying, p_code character varying, p_startdate character varying, p_enddate character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 378 (class 1255 OID 58459)
-- Name: sp_savings_add(bigint, double precision, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_savings_add(p_memberid bigint, p_amount double precision, p_userid bigint) RETURNS SETOF public.vw_savings
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_savings%ROWTYPE;
	v_audit text;
	v_datcreated character varying;
	v_savingscode character varying;
	v_sequence bigint;
	rd RECORD;
BEGIN
	select now()::date::character varying into v_datcreated;
	select max(recid) + 1 into v_sequence from tb_savings;
	v_savingscode:=fn_savingscodeno_gen(v_sequence,p_amount);
	/**Insert Data Into Table**/
	INSERT INTO tb_savings(memberid,
				 amount,
				 savingscode,
				 datecreated,
				 userid) 
	     VALUES 	    (p_memberid,
			     p_amount,
			     TRIM(v_savingscode),
			     TRIM(v_datcreated),
			     p_userid);
			     
	

	/**Obtain Return Data**/
	SELECT * 
	  INTO v_rec
	  FROM vw_savings
	 WHERE rid IN (SELECT MAX(rid) FROM vw_savings);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_savings_add(p_memberid bigint, p_amount double precision, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 310 (class 1259 OID 67290)
-- Name: vw_shop; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_shop AS
 SELECT r.recid AS rid,
    r.recname AS nam,
    r.shortcode AS shc,
    r.status AS sts,
    r.status AS ast,
    r.stamp AS stp,
    public.fn_count_shop_products(r.recid) AS rct
   FROM public.tb_shop r;


ALTER TABLE public.vw_shop OWNER TO postgres;

--
-- TOC entry 420 (class 1255 OID 67294)
-- Name: sp_shops_find(bigint, character varying, character varying, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_shops_find(p_recid bigint, p_name character varying, p_shortcode character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vw_shop
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8, 
		   v_name "varchar",
		   v_shortcode "varchar",
		   v_status int4,
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vw_shop WHERE
        COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
    AND COALESCE("nam"::VARCHAR,'') ILIKE '%'|| COALESCE(v_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
    AND COALESCE("shc"::VARCHAR,'') ILIKE '%'|| COALESCE(v_shortcode::VARCHAR,COALESCE("shc"::VARCHAR,''))||'%' 
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND "rid" > 0 --avoiding invalid recid
    ORDER BY "nam" ASC
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vw_shop %ROWTYPE;
BEGIN 
	
	--COUNT VALID RECORD
	SELECT COUNT(*)
	  INTO v_rec.rid
	 FROM vw_shop  WHERE
            COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))  
    AND COALESCE("nam"::VARCHAR,'') ILIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("nam"::VARCHAR,''))||'%'
    AND COALESCE("shc"::VARCHAR,'') ILIKE '%'|| COALESCE(p_shortcode::VARCHAR,COALESCE("shc"::VARCHAR,''))||'%' 
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND "rid" > 0;

	RETURN NEXT v_rec; 

	OPEN v_cur(p_recid,p_name,p_shortcode,p_status,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_shops_find(p_recid bigint, p_name character varying, p_shortcode character varying, p_status integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 379 (class 1255 OID 58460)
-- Name: sp_sync_data(text, character varying, character varying, double precision, bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_sync_data(p_products text, p_code character varying, p_salescode character varying, p_amount double precision, p_paymenttypeid bigint, p_userid bigint) RETURNS SETOF public.vw_saless
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vw_saless%ROWTYPE;
	v_recc vw_salescode%ROWTYPE;
	v_audit text;
	v_datcreated character varying;
	v_salescode character varying;
	v_sequence bigint;
	rd RECORD;
	v_memberno character varying;
BEGIN

	SELECT memberno INTO v_memberno FROM tb_member WHERE memberno LIKE '%'||p_code||'%';
	IF NOT FOUND THEN
		RAISE EXCEPTION '::DBERR-0232::No Record Found for this Code: %::',p_code;
	END IF;
	
	select now()::date::character varying into v_datcreated;
-- 	select max(recid) + 1 into v_sequence from tb_salescode;
-- 	v_salescode:=fn_salescodeno_gen(v_sequence);
	/**Insert Data Into Table**/
	INSERT INTO tb_salescode(salescode,
				 userid,
				 status,
				 datcreated,
				 phone,
				 paymenttypeid,
				 amountpaid) 
	     VALUES 	    (TRIM(p_salescode),
			     p_userid,
			     1,
			     TRIM(v_datcreated),
			     TRIM(v_memberno),
			     p_paymenttypeid,
			     p_amount);
			     
	

	/**Obtain Return Data**/
	SELECT * 
	  INTO v_recc
	  FROM vw_salescode
	 WHERE rid IN (SELECT MAX(rid) FROM vw_salescode);

	/**Prepare Data for Audit */
-- 	SELECT 'RecId = '||COALESCE(ed.rid::VARCHAR)||
-- 		' :: InstitutionId = '||COALESCE(ed.iid::VARCHAR)||
-- 		' :: CandidateId = '||COALESCE(ed.cid::VARCHAR)||
-- 		' :: StartDate = '||COALESCE(ed.sdt::VARCHAR)||
-- 		' :: EndDate = '||COALESCE(ed.edt::VARCHAR)||
-- 		' :: OfficeHeld = '||COALESCE(ed.ohd::VARCHAR)||
-- 		' :: Status = '||COALESCE(ed.sts::VARCHAR)||
-- 		' :: ApStatus = '||COALESCE(ed.ast::VARCHAR)||
-- 		' :: Stamp = '||COALESCE(ed.stp::VARCHAR)
-- 	INTO v_audit
-- 	FROM vw_education ed
-- 	WHERE ed.rid=v_rec.rid;
	
	/**Record Audit**/
-- 	PERFORM fns_audittrail_add(p_userid,'Education Add',v_audit);
	FOR rd IN  select * from 
	    (select  t1.arr[1]::bigint as pid, v_recc.rid as sid, t1.arr[2]::integer as qty, t1.arr[3]::double precision as prc, t1.arr[4]::integer as sts 
	       from 
		(select string_to_array(data,'|') as arr  
		   from regexp_split_to_table(p_products,'::') as data
		) t1

	    ) as t2 LOOP

	    PERFORM sp_sales_add_bulk(rd.pid,rd.qty,rd.prc,rd.sid,rd.sts,p_userid);

	END LOOP;

	SELECT * 
	  INTO v_rec
	  FROM vw_saless
	 WHERE sci=rd.sid;
	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sp_sync_data(p_products text, p_code character varying, p_salescode character varying, p_amount double precision, p_paymenttypeid bigint, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 61228)
-- Name: vw_unit; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_unit AS
 SELECT r.recid AS rid,
    r.recname AS nam,
    r.shortcode AS shc,
    r.stamp AS stp
   FROM public.tb_unit r;


ALTER TABLE public.vw_unit OWNER TO postgres;

--
-- TOC entry 410 (class 1255 OID 61233)
-- Name: sp_unit_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_unit_combo(p_userid bigint) RETURNS SETOF public.vw_unit
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_sectionid int8)
    FOR SELECT * FROM vw_unit	
	ORDER BY "rid" ASC;

    v_rec  vw_unit%ROWTYPE;
    v_sid bigint;
BEGIN 
	SELECT sectionid INTO v_sid FROM tbs_user WHERE recid=p_userid;
	OPEN v_cur(v_sid); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sp_unit_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 58461)
-- Name: tbs_audittrail; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_audittrail (
    recid bigint NOT NULL,
    userid bigint NOT NULL,
    aaction character varying(200),
    arecord text,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_audittrail_action CHECK (((aaction)::text <> ''::text)),
    CONSTRAINT chek_audittrail_record CHECK ((arecord <> ''::text))
);


ALTER TABLE public.tbs_audittrail OWNER TO kpuser;

--
-- TOC entry 230 (class 1259 OID 58470)
-- Name: tbs_entity; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_entity (
    recid bigint NOT NULL,
    recname character varying(150) NOT NULL,
    entitytypeid bigint NOT NULL,
    address text NOT NULL,
    loc text,
    contactno1 character varying(15),
    contactno2 character varying(15),
    fax character varying(15),
    email character varying(100),
    website character varying(200),
    comments text,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    imageloginattempt integer DEFAULT 2,
    plainloginattempt integer DEFAULT 3 NOT NULL,
    CONSTRAINT chek_entity_address CHECK ((address <> ''::text)),
    CONSTRAINT chek_entity_name CHECK (((recname)::text <> ''::text))
);


ALTER TABLE public.tbs_entity OWNER TO kpuser;

--
-- TOC entry 231 (class 1259 OID 58481)
-- Name: tbs_entitytype; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_entitytype (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    privilegelist character varying[],
    CONSTRAINT chek_entitytype_name CHECK (((recname)::text <> ''::text))
);


ALTER TABLE public.tbs_entitytype OWNER TO kpuser;

--
-- TOC entry 232 (class 1259 OID 58489)
-- Name: tbs_role; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_role (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    description text,
    entitytypeid bigint NOT NULL,
    accesskey integer DEFAULT 0 NOT NULL,
    sessiontimeout integer DEFAULT 0 NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tbs_role OWNER TO kpuser;

--
-- TOC entry 233 (class 1259 OID 58498)
-- Name: vws_entity; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_entity AS
 SELECT en.recid AS rid,
    en.recname AS nam,
    en.entitytypeid AS eti,
    et.recname AS ety,
    en.address AS adr,
    en.loc,
    en.contactno1 AS ct1,
    en.contactno2 AS ct2,
    en.fax,
    en.email AS eml,
    en.website AS web,
    en.comments AS com,
    en.imageloginattempt AS ila,
    en.plainloginattempt AS pla,
    en.status AS sts,
    (en.status * et.status) AS ast,
    en.stamp AS stp
   FROM public.tbs_entity en,
    public.tbs_entitytype et
  WHERE (en.entitytypeid = et.recid);


ALTER TABLE public.vws_entity OWNER TO kpuser;

--
-- TOC entry 234 (class 1259 OID 58502)
-- Name: vws_role; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_role AS
 SELECT ro.recid AS rid,
    ro.recname AS nam,
    ro.description AS dsc,
    ro.sessiontimeout AS sto,
    ro.accesskey AS aky,
    (power((2)::double precision, (ro.accesskey)::double precision))::bigint AS acl,
    ro.entitytypeid AS eti,
    et.recname AS ety,
    ro.status AS sts,
    (ro.status * et.status) AS ast,
    ro.stamp AS stp
   FROM public.tbs_entitytype et,
    public.tbs_role ro
  WHERE (et.recid = ro.entitytypeid);


ALTER TABLE public.vws_role OWNER TO kpuser;

--
-- TOC entry 235 (class 1259 OID 58506)
-- Name: vws_user; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_user AS
 SELECT us.recid AS rid,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    us.roleid AS roi,
    ro.nam AS rnm,
    us.entityid AS eni,
    en.nam AS enm,
    en.eti,
    en.ety,
    en.pla,
    en.ila,
    us.falselogin AS flg,
    us.contactno1 AS ct1,
    us.contactno2 AS ct2,
    us.email AS eml,
    us.sessionid AS sid,
    ro.sto,
    us.loginstatus AS lst,
    us.datecreated AS dct,
    us.lastlogindate AS lld,
    us.lastpasswordresetdate AS lpd,
    us.comments AS com,
    public.fns_inboxcount(us.recid) AS mct,
    us.status AS sts,
    ((us.status * en.ast) * ro.ast) AS ast,
    us.stamp AS stp,
    (((us.othernames)::text || ' '::text) || (us.surname)::text) AS nam,
    us.photourl AS pho,
    us.gender AS gen
   FROM public.tbs_user us,
    public.vws_entity en,
    public.vws_role ro
  WHERE ((us.roleid = ro.rid) AND (us.entityid = en.rid));


ALTER TABLE public.vws_user OWNER TO kpuser;

--
-- TOC entry 236 (class 1259 OID 58511)
-- Name: vws_audittrail; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_audittrail AS
 SELECT au.recid AS rid,
    au.aaction AS act,
    au.userid AS uid,
    (((us.onm)::text || ' '::text) || (us.snm)::text) AS fnm,
    us.roi,
    us.rnm,
    us.eni,
    us.enm,
    au.arecord AS rcd,
    au.stamp AS stp
   FROM public.tbs_audittrail au,
    public.vws_user us
  WHERE (au.userid = us.rid);


ALTER TABLE public.vws_audittrail OWNER TO kpuser;

--
-- TOC entry 380 (class 1255 OID 58515)
-- Name: sps_audittrail_find(bigint, bigint, bigint, character varying, character varying, timestamp without time zone, timestamp without time zone, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_audittrail_find(p_auditeeid bigint, p_entityid bigint, p_roleid bigint, p_action character varying, p_record character varying, p_startdate timestamp without time zone, p_enddate timestamp without time zone, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vws_audittrail
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_record VARCHAR;

    v_cur   CURSOR(v_auditeeid int8,
		   v_entityid int8,
		   v_roleid int8,
		   v_action varchar, 
		   v_record varchar,
		   v_startdate timestamp,
		   v_enddate timestamp,
		   v_pageoffset int4, 
		   v_pagelimit int4)

    FOR SELECT * FROM vws_audittrail WHERE
          COALESCE("uid"::VARCHAR,'')= COALESCE(v_auditeeid::VARCHAR,COALESCE("uid"::VARCHAR,'') )	  
      AND COALESCE("eni"::VARCHAR,'')= COALESCE(v_entityid::VARCHAR,COALESCE("eni"::VARCHAR,'') )	  
      AND COALESCE("roi"::VARCHAR,'')= COALESCE(v_roleid::VARCHAR,COALESCE("roi"::VARCHAR,'') )	  
      AND COALESCE("act"::VARCHAR,'') ILIKE '%'|| COALESCE(v_action::VARCHAR ,COALESCE("act"::VARCHAR,''))||'%'
      AND (CASE WHEN COALESCE(v_record,CHR(1))=CHR(1) OR v_record='' 
	      THEN 1=1 
	      ELSE to_tsvector(COALESCE("rcd",'')) @@ to_tsquery(v_record) END
          )
      AND 
	 (
	  COALESCE("stp"::TIMESTAMP,'2000-01-01') BETWEEN 
          COALESCE(v_startdate::TIMESTAMP,'2000-01-01'::TIMESTAMP) 
	  AND 
          COALESCE(v_enddate::TIMESTAMP,'TODAY'::timestamp+'86399 SEC'::INTERVAL)
	)
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vws_audittrail%ROWTYPE;
BEGIN 
	--clean up p_detail that contains regular expression operators.
        v_record:=regexp_replace(TRIM(p_record),'!~%()"?<>:','','g');
	--substitute the occurance of space with & to AND strings
	v_record:=regexp_replace(TRIM(v_record),'[[:space:]]+',' & ','g');

	--COUNT OF VALID RECORDS
	SELECT COUNT(*)
	  INTO v_rec.rid
	  FROM vws_audittrail WHERE
          COALESCE("uid"::VARCHAR,'')= COALESCE(p_auditeeid::VARCHAR,COALESCE("uid"::VARCHAR,'') )	  
        AND COALESCE("eni"::VARCHAR,'')= COALESCE(p_entityid::VARCHAR,COALESCE("eni"::VARCHAR,'') )	  
        AND COALESCE("roi"::VARCHAR,'')= COALESCE(p_roleid::VARCHAR,COALESCE("roi"::VARCHAR,'') )	  
        AND COALESCE("act"::VARCHAR,'') ILIKE '%'|| COALESCE(p_action::VARCHAR ,COALESCE("act"::VARCHAR,''))||'%'
        AND (CASE WHEN COALESCE(v_record,CHR(1))=CHR(1) OR v_record='' 
	      THEN 1=1 
	      ELSE to_tsvector(COALESCE("rcd",'')) @@ to_tsquery(v_record) END
          )
        AND (
	    COALESCE("stp"::TIMESTAMP,'2000-01-01') BETWEEN 
            COALESCE(p_startdate::TIMESTAMP,'2000-01-01'::TIMESTAMP) 
	    AND 
            COALESCE(p_enddate::TIMESTAMP,'TODAY'::timestamp+'86399 SEC'::INTERVAL)
	    );

	RETURN NEXT v_rec;

	OPEN v_cur(p_auditeeid,p_entityid,p_roleid,p_action,v_record,p_startdate,p_enddate,p_pageoffset,p_pagelimit); 
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_audittrail_find(p_auditeeid bigint, p_entityid bigint, p_roleid bigint, p_action character varying, p_record character varying, p_startdate timestamp without time zone, p_enddate timestamp without time zone, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 381 (class 1255 OID 58516)
-- Name: sps_entity_combo(bigint, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_entity_combo(p_typeid bigint, p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_typeid int8)
    FOR SELECT rid,nam FROM vws_entity 
	WHERE ast = 1
	AND   COALESCE("eti"::VARCHAR,'')= COALESCE(v_typeid::VARCHAR,COALESCE("eti"::VARCHAR,'') )
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur(p_typeid); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_entity_combo(p_typeid bigint, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 382 (class 1255 OID 58517)
-- Name: sps_entitytype_combo(bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_entitytype_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vws_entitytype 
        WHERE ast = 1 AND rid = 1
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
BEGIN 
	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_entitytype_combo(p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 237 (class 1259 OID 58518)
-- Name: tbs_privilege; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_privilege (
    recid bigint NOT NULL,
    recname character varying(50) NOT NULL,
    shortcode character varying(50) NOT NULL,
    menuname character varying(30) NOT NULL,
    submenuname character varying(30) NOT NULL,
    lang character varying(30) NOT NULL,
    menuorder integer NOT NULL,
    accesslevel bigint NOT NULL,
    actionfile character varying(30) NOT NULL,
    menugroup character varying(50) NOT NULL,
    buttontext character varying(50) DEFAULT 'btn'::character varying,
    buttonfunc character varying(50) DEFAULT 'addfn'::character varying,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    context bigint DEFAULT 0,
    CONSTRAINT chek_privilege_actionfile CHECK (((actionfile)::text <> ''::text)),
    CONSTRAINT chek_privilege_buttonfunc CHECK (((buttonfunc)::text <> ''::text)),
    CONSTRAINT chek_privilege_buttontext CHECK (((buttontext)::text <> ''::text)),
    CONSTRAINT chek_privilege_lang CHECK (((lang)::text <> ''::text)),
    CONSTRAINT chek_privilege_menugroup CHECK (((menugroup)::text <> ''::text)),
    CONSTRAINT chek_privilege_menuname CHECK (((menuname)::text <> ''::text)),
    CONSTRAINT chek_privilege_recname CHECK (((recname)::text <> ''::text)),
    CONSTRAINT chek_privilege_shortcode CHECK (((shortcode)::text <> ''::text)),
    CONSTRAINT chek_privilege_submenuname CHECK (((submenuname)::text <> ''::text))
);


ALTER TABLE public.tbs_privilege OWNER TO kpuser;

--
-- TOC entry 238 (class 1259 OID 58534)
-- Name: vws_privilege; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_privilege AS
 SELECT pr.recid AS rid,
    pr.recname AS nam,
    pr.shortcode AS shc,
    pr.menuname AS mnm,
    pr.submenuname AS smn,
    pr.menugroup AS mng,
    pr.lang AS lnm,
    pr.menuorder AS ord,
    pr.accesslevel AS acl,
    pr.buttontext AS btx,
    pr.buttonfunc AS bfn,
    pr.actionfile AS acf,
    pr.status AS sts,
    pr.status AS ast,
    pr.stamp AS stp,
    pr.context AS ctx
   FROM public.tbs_privilege pr;


ALTER TABLE public.vws_privilege OWNER TO kpuser;

--
-- TOC entry 383 (class 1255 OID 58538)
-- Name: sps_privilege_find(bigint, character varying, character varying, bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_privilege_find(p_roleid bigint, p_menu character varying, p_submenu character varying, p_contextid bigint, p_status integer, p_userid bigint) RETURNS SETOF public.vws_privilege
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_ackey bigint;
    v_cur   CURSOR(v_accesskey int4, v_rolests int4)
	FOR SELECT * FROM vws_privilege 
	WHERE v_rolests*(acl::bit(32) & coalesce(v_accesskey,0)::bit(32))::bigint = v_rolests*coalesce(v_accesskey,0) 
	  --AND v_accesskey<>0 
	  AND mnm = coalesce(p_menu,mnm)
	  AND smn = coalesce(p_submenu,smn)
	  AND sts = coalesce(p_status,sts)
	  AND ctx = coalesce(p_contextid,ctx)
	  AND sts < 2
	    
	ORDER BY ord;

    v_rec  vws_privilege%ROWTYPE;
    v_rolests int4;
BEGIN 
	SELECT acl
          INTO v_ackey
          FROM vws_role
	WHERE rid=p_roleid;

	--IF NOT FOUND THEN
	--   RETURN;
	--END IF;

	v_rolests := least(1,coalesce(p_roleid,0));

	OPEN v_cur(v_ackey,v_rolests); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_privilege_find(p_roleid bigint, p_menu character varying, p_submenu character varying, p_contextid bigint, p_status integer, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 239 (class 1259 OID 58539)
-- Name: vws_privs; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_privs AS
 SELECT NULL::bigint AS rid,
    NULL::character varying AS nam,
    NULL::character varying AS shc,
    NULL::character varying AS mnm,
    NULL::character varying AS snm,
    NULL::integer AS ord,
    NULL::bigint AS acl,
    NULL::integer AS sts,
    NULL::timestamp without time zone AS stp;


ALTER TABLE public.vws_privs OWNER TO kpuser;

--
-- TOC entry 384 (class 1255 OID 58543)
-- Name: sps_privilege_list(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sps_privilege_list(p_roleid bigint, p_userid bigint) RETURNS SETOF public.vws_privs
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_ackey bigint;
    v_cur   CURSOR(v_accesskey int4)
	FOR SELECT rid, nam, shc, mnm, smn, ord, acl, 
	    ((acl::bit(64) & v_accesskey::bit(64))::bigint = v_accesskey)::integer AS sts, 
	    stp FROM vws_privilege WHERE sts=1
	ORDER BY ord;

    v_rec  vws_privs%ROWTYPE;
BEGIN 
	SELECT acl
          INTO v_ackey
          FROM vws_role
	WHERE rid=p_roleid;

	IF NOT FOUND THEN
	   RETURN;
	END IF;

	OPEN v_cur(v_ackey); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_privilege_list(p_roleid bigint, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 385 (class 1255 OID 58544)
-- Name: sps_privilege_set(bigint, bigint, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_privilege_set(p_roleid bigint, p_privilegeid bigint, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_priv	vws_privilege%ROWTYPE;
	v_role	vws_role%ROWTYPE;
	v_audit text;
	v_accesslevel bigint;
BEGIN
	v_audit:='';

	/** Only superuser (id=1) can do this **/
	--TODO: use permission function to control access
	IF p_userid > 1 THEN
	  RAISE EXCEPTION '%',fns_errormessage(27);
	END IF;

	/** If privilege doesnt exist, raise exception **/
	SELECT * FROM vws_privilege INTO v_priv WHERE rid = p_privilegeid;
	IF NOT FOUND THEN
	  RAISE EXCEPTION '%',fns_errormessage(3);
	END IF;

	/** If role doesnt exist, raise exception **/
	SELECT * FROM vws_role INTO v_role WHERE rid = p_roleid;
	IF NOT FOUND THEN
	  RAISE EXCEPTION '%',fns_errormessage(3);
	END IF;

	/** If privilege is inactive and role bit is already set, exit **/
	SELECT -1*vp.sts, now() FROM vws_privilege vp, vws_role vr INTO v_rec WHERE
	vp.rid = p_privilegeid AND vr.rid = p_roleid AND 
	(vp.sts=0 OR ((vp.acl::bit(32) & vr.acl::bigint::bit(32))::bigint = vr.acl::bigint));
	IF FOUND THEN
	    RETURN NEXT v_rec;
	    RETURN;
	    --EXIT;
	END IF;
	--SELECT 0,now();
	/** Role bit is NOT set, Proceed to set it **/
	v_accesslevel := v_priv.acl + v_role.acl::bigint;

	/**Prepare Data for Audit **/
	SELECT ' :: Name = '      ||COALESCE(vps.nam::VARCHAR,'') ||
	       ' :: Shortcode = '      ||COALESCE(vps.shc::VARCHAR,'') ||
	       (CASE WHEN COALESCE(vps.acl,0) != COALESCE(v_accesslevel,0) 
		  THEN ' :: AccessLevel (O) = '|| COALESCE(vps.acl::VARCHAR,'')||', (N) = '|| COALESCE(v_accesslevel::VARCHAR,'')
		  ELSE '' END)
	INTO v_audit
	FROM vws_privilege vps
	WHERE vps.rid=p_privilegeid;

	/** Update Privileges table **/
	UPDATE tbs_privilege
	   SET accesslevel=v_accesslevel
	WHERE recid=p_privilegeid; 

	/** If there is the need for an audit trail, record it **/
	IF NOT(v_audit='') THEN
		v_audit:='RecId = '||p_privilegeid||v_audit;
		PERFORM fns_audittrail_add(p_userid,'Privilege Edit',v_audit);
	END IF;
	
	/**Return Data**/
	SELECT rid,now() 
	  INTO v_rec
	  FROM vws_privilege
	 WHERE rid = p_privilegeid;
	RETURN NEXT v_rec;
	
END;
$$;


ALTER FUNCTION public.sps_privilege_set(p_roleid bigint, p_privilegeid bigint, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 386 (class 1255 OID 58545)
-- Name: sps_privilege_unset(bigint, bigint, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_privilege_unset(p_roleid bigint, p_privilegeid bigint, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_priv	vws_privilege%ROWTYPE;
	v_role	vws_role%ROWTYPE;
	v_audit text;
	v_accesslevel bigint;
BEGIN
	v_audit:='';

	/** Only superuser (id=1) can do this **/
	--TODO: use permission function to control access
	IF p_userid > 1 THEN
	  RAISE EXCEPTION '%',fns_errormessage(27);
	END IF;

	/** If privilege doesnt exist, raise exception **/
	SELECT * FROM vws_privilege INTO v_priv WHERE rid = p_privilegeid;
	IF NOT FOUND THEN
	  RAISE EXCEPTION '%',fns_errormessage(3);
	END IF;

	/** If role doesnt exist, raise exception **/
	SELECT * FROM vws_role INTO v_role WHERE rid = p_roleid;
	IF NOT FOUND THEN
	  RAISE EXCEPTION '%',fns_errormessage(3);
	END IF;

	/** If privilege is inactive or role bit is NOT set, exit **/
	SELECT -1*vp.sts, now() FROM vws_privilege vp, vws_role vr INTO v_rec WHERE
	vp.rid = p_privilegeid AND vr.rid = p_roleid AND 
	(vp.sts=0 OR ((vp.acl::bit(32) & vr.acl::bigint::bit(32))::bigint != vr.acl::bigint));
	IF FOUND THEN
	    RETURN NEXT v_rec;
	    RETURN;
	END IF;
	
	/** Role bit is NOT set, Proceed to set it **/
	v_accesslevel := v_priv.acl - v_role.acl::bigint;

	/**Prepare Data for Audit **/
	SELECT ' :: Name = '      ||COALESCE(vps.nam::VARCHAR,'') ||
	       ' :: Shortcode = '      ||COALESCE(vps.shc::VARCHAR,'') ||
	       (CASE WHEN COALESCE(vps.acl,0) != COALESCE(v_accesslevel,0) 
		  THEN ' :: AccessLevel (O) = '|| COALESCE(vps.acl::VARCHAR,'')||', (N) = '|| COALESCE(v_accesslevel::VARCHAR,'')
		  ELSE '' END)
	INTO v_audit
	FROM vws_privilege vps
	WHERE vps.rid=p_privilegeid;

	/** Update Privileges table **/
	UPDATE tbs_privilege
	   SET accesslevel=v_accesslevel
	WHERE recid=p_privilegeid; 

	/** If there is the need for an audit trail, record it **/
	IF NOT(v_audit='') THEN
		v_audit:='RecId = '||p_privilegeid||v_audit;
		PERFORM fns_audittrail_add(p_userid,'Privilege Edit',v_audit);
	END IF;
	
	/**Return Data**/
	SELECT rid,now() 
	  INTO v_rec
	  FROM vws_privilege
	 WHERE rid = p_privilegeid;
	RETURN NEXT v_rec;
	
END;
$$;


ALTER FUNCTION public.sps_privilege_unset(p_roleid bigint, p_privilegeid bigint, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 387 (class 1255 OID 58546)
-- Name: sps_role_combo(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sps_role_combo(p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR
    FOR SELECT rid,nam FROM vws_role 
	WHERE ast = 1 AND acl>0 AND rid>2
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
    v_uroleid bigint;
BEGIN 
-- 	SELECT roi INTO v_uroleid FROM vws_user WHERE rid = p_userid;
-- 	IF NOT FOUND THEN
-- 	    RAISE EXCEPTION '%',fns_errormessage(27);
-- 	END IF;

	OPEN v_cur; 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_role_combo(p_userid bigint) OWNER TO postgres;

--
-- TOC entry 388 (class 1255 OID 58547)
-- Name: sps_role_combo(bigint, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_role_combo(p_etypeid bigint, p_userid bigint) RETURNS SETOF public.vws_combo
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_etypeid int8, v_uroleid int8)
    FOR SELECT rid,nam FROM vws_role 
	WHERE ast = 1 AND acl>0
	AND COALESCE("eti"::VARCHAR,'')= COALESCE(v_etypeid::VARCHAR,COALESCE("eti"::VARCHAR,''))
	--cant fetch system default roles superuser,admin)
	AND v_uroleid <= rid
	ORDER BY "nam" ASC;

    v_rec  vws_combo%ROWTYPE;
    v_uroleid bigint;
BEGIN 
	SELECT roi INTO v_uroleid FROM vws_user WHERE rid = p_userid;
	IF NOT FOUND THEN
	    RAISE EXCEPTION '%',fns_errormessage(27);
	END IF;

	OPEN v_cur(p_etypeid, v_uroleid); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_role_combo(p_etypeid bigint, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 389 (class 1255 OID 58548)
-- Name: sps_role_edit(bigint, character varying, text, bigint, integer, integer, timestamp without time zone, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_role_edit(p_recid bigint, p_name character varying, p_description text, p_entitytypeid bigint, p_sessiontimeout integer, p_status integer, p_stamp timestamp without time zone, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_audit text;
BEGIN
	v_audit:='';

	/**Prepare Data for Audit **/
	SELECT (CASE WHEN LOWER(TRIM(COALESCE(ro.nam::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_name::VARCHAR,''))) 
	          THEN ' :: Name (O) = '||TRIM(COALESCE(ro.nam::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_name::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(ro.dsc::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_description::VARCHAR,''))) 
	          THEN ' :: Description (O) = '||TRIM(COALESCE(ro.dsc::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_description::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN TRIM(COALESCE(ro.eti::VARCHAR,''))!= TRIM(COALESCE(p_entitytypeid::VARCHAR,''))
	          THEN ' :: EntityType (O) = '||TRIM(COALESCE(ro.eti::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_entitytypeid::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(ro.sto::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_sessiontimeout::VARCHAR,''))) 
	          THEN ' :: SessiontTimeOut (O) = '||TRIM(COALESCE(ro.sto::VARCHAR,''))||', (N) = '||TRIM(COALESCE(abs(p_sessiontimeout)::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN TRIM(COALESCE(ro.sts::VARCHAR,''))!= TRIM(COALESCE(p_status::VARCHAR,''))
	          THEN ' :: Status (O) = '||TRIM(COALESCE(ro.sts::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_status::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN TRIM(ro.stp::VARCHAR)!=TRIM(COALESCE(p_stamp::VARCHAR,''))
	          THEN ' :: Stamp (O) = '||TRIM(ro.stp::VARCHAR)||', (N) = '||TRIM(COALESCE(p_stamp::VARCHAR,''))
                  ELSE ''END)
	INTO v_audit
	FROM vws_role ro
	WHERE ro.rid=p_recid;

	UPDATE tbs_role
           SET recname=TRIM(p_name),
	       description=TRIM(p_description),
	       entitytypeid=p_entitytypeid,
	       sessiontimeout=abs(p_sessiontimeout),
	       status=p_status,
	       stamp= p_stamp
	 WHERE recid=p_recid; 
	

	/** If there is the need for an audit trail, record it **/
-- 	IF NOT(v_audit='') THEN
-- 		v_audit:='RecId = '||p_recid||v_audit;
-- 		PERFORM fns_audittrail_add(p_userid,'Role Edit',v_audit);
-- 	END IF;
	
	/**Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vws_role
	 WHERE rid = p_recid;
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sps_role_edit(p_recid bigint, p_name character varying, p_description text, p_entitytypeid bigint, p_sessiontimeout integer, p_status integer, p_stamp timestamp without time zone, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 390 (class 1255 OID 58549)
-- Name: sps_role_find(bigint, character varying, character varying, bigint, integer, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_role_find(p_recid bigint, p_name character varying, p_description character varying, p_entitytypeid bigint, p_status integer, p_apstatus integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vws_role
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_user_eti int8;

    v_cur   CURSOR(v_recid int8, 
		   v_name "varchar", 
		   v_description "varchar", 
		   v_entitytypeid int8,
		   v_status int4, 
		   v_apstatus int4, 
		   v_pageoffset int4, 
		   v_pagelimit int4,
		   v_queryuserid int8,
		   v_user_eti int8)
    FOR SELECT * FROM vws_role WHERE
	COALESCE("rid"::VARCHAR,'')= COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))	  
    AND	COALESCE("eti"::VARCHAR,'')= COALESCE(v_entitytypeid::VARCHAR,COALESCE("eti"::VARCHAR,''))
    AND	COALESCE("nam"::VARCHAR,'')ILIKE '%'||COALESCE(v_name::VARCHAR,COALESCE("nam"::VARCHAR,''))||'%'	  
    AND	COALESCE("dsc"::VARCHAR,'')ILIKE '%'||COALESCE(v_description::VARCHAR,COALESCE("dsc"::VARCHAR,''))||'%'	
    AND COALESCE("sts"::VARCHAR,'')= COALESCE(v_status::VARCHAR,COALESCE("sts"::VARCHAR,''))  
    AND COALESCE("ast"::VARCHAR,'')= COALESCE(v_apstatus::VARCHAR,COALESCE("ast"::VARCHAR,''))  
    /**Block Superuser and Guest roles from being fetched**/
    AND "rid" > 1
    /**Block Superuser from fetching non-mainorg entitytypes**/
    AND ( CASE WHEN v_user_eti = 1 AND v_queryuserid = 1 THEN "eti"=1 ELSE "eti"="eti" END) 
    /**Block MainOrg user from fetching mainorg entitytype **/
    AND ( CASE WHEN v_user_eti = 1 AND v_queryuserid <>1 THEN "eti"<>1 ELSE "eti"="eti" END)
    /**Block all other users from fetching entitytype **/
    AND ( CASE WHEN v_user_eti = -1 THEN "eti"=-1 ELSE "eti"="eti" END)

    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET greatest(COALESCE(v_pageoffset,0),1);
    v_rec  vws_role%ROWTYPE;
BEGIN 
    SELECT us."eti"
	  INTO v_user_eti
	  FROM vws_user us
	 WHERE us."rid"=p_userid AND "rid"<>0;

	v_user_eti:=COALESCE(v_user_eti,-1);


	--COUNT VALID RECORDS
	SELECT COUNT(*)
	  INTO v_rec.rid
	  FROM vws_role WHERE
	COALESCE("rid"::VARCHAR,'')= COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,''))	  
    AND	COALESCE("eti"::VARCHAR,'')= COALESCE(p_entitytypeid::VARCHAR,COALESCE("eti"::VARCHAR,''))
    AND	COALESCE("nam"::VARCHAR,'')ILIKE '%'||COALESCE(p_name::VARCHAR,COALESCE("nam"::VARCHAR,''))||'%'	  
    AND	COALESCE("dsc"::VARCHAR,'')ILIKE '%'||COALESCE(p_description::VARCHAR,COALESCE("dsc"::VARCHAR,''))||'%'	
    AND COALESCE("sts"::VARCHAR,'')= COALESCE(p_status::VARCHAR,COALESCE("sts"::VARCHAR,''))  
    AND COALESCE("ast"::VARCHAR,'')= COALESCE(p_apstatus::VARCHAR,COALESCE("ast"::VARCHAR,''))
    /**Block Superuser and Guest roles from being fetched**/
    AND "rid" > 1
    /**Block Superuser from fetching non-mainorg entitytypes**/
    AND ( CASE WHEN v_user_eti = 1 AND p_userid = 1 THEN "eti"=1 ELSE "eti"="eti" END) 
    /**Block Mainorg user from fetching mainorg entitytype **/
    AND ( CASE WHEN v_user_eti = 1 AND p_userid <>1 THEN "eti"<>1 ELSE "eti"="eti" END)
    /**Block all other users from fetching entitytype **/
    AND ( CASE WHEN v_user_eti = -1 THEN "eti"=-1 ELSE "eti"="eti" END);

	RETURN NEXT v_rec;

	OPEN v_cur(p_recid,p_name,p_description,p_entitytypeid,p_status,p_apstatus,p_pageoffset,p_pagelimit,p_userid,v_user_eti); 
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_role_find(p_recid bigint, p_name character varying, p_description character varying, p_entitytypeid bigint, p_status integer, p_apstatus integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 391 (class 1255 OID 58550)
-- Name: sps_security_basicdata(bigint, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_security_basicdata(p_recid bigint, p_userid bigint) RETURNS SETOF public.vws_user
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_rec  vws_user%ROWTYPE;

    v_cur   CURSOR(v_recid int8
--     , 
-- 		   v_pageoffset int4, 
-- 		   v_pagelimit int4
)
	    FOR SELECT *
		  FROM vws_user 
		 WHERE COALESCE("rid"::VARCHAR,'')= COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,''));
    
BEGIN 
	
	OPEN v_cur(p_recid); 	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_security_basicdata(p_recid bigint, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 240 (class 1259 OID 58551)
-- Name: vws_secresult; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_secresult AS
 SELECT NULL::character varying AS rlt,
    NULL::character varying AS msg;


ALTER TABLE public.vws_secresult OWNER TO kpuser;

--
-- TOC entry 392 (class 1255 OID 58555)
-- Name: sps_security_login(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_security_login(p_username character varying, p_password character varying, p_sessionid character varying) RETURNS public.vws_secresult
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_username "varchar")
    FOR SELECT * FROM vws_user WHERE LOWER(TRIM("unm"))=LOWER(TRIM(v_username))
    LIMIT 1 OFFSET 0;
    v_count int4;
    v_rec  vws_user%ROWTYPE;
    v_rtnrec vws_secresult%ROWTYPE;
    v_password varchar;
    v_result varchar;
    v_message varchar;
BEGIN 
	v_result:='';

	OPEN v_cur(p_username); 
	
	FETCH v_cur INTO v_rec;
	
	--DOES A USER WITH THIS USERNAME EXIST?
	IF ((NOT FOUND) AND v_result='' ) THEN
		v_message:=fns_errormessage(6);
		v_result :='-6';
	END IF;

	--DOES THE USER HAVE A STATUS THAT IS VALID
	IF ((v_rec."ast"=0) AND v_result='') THEN
		--Supended / Locked ACCOUNT
		v_message:= fns_errormessage(7);
		v_result := '-7';
	ELSIF ((v_rec."sts"=2) AND v_result='') THEN
		-- Locked ACCOUNT
		v_message:= fns_errormessage(15);
		v_result := '-15';
	END IF;
	
	--DOES THE SESSION EXIST?
	 SELECT COUNT(*)
	   INTO v_count
	   FROM tbs_session
	  WHERE "sessionid"=p_sessionid;
	 IF ((v_count=0) AND v_result='') THEN
	     v_message:=fns_errormessage(8);
	     v_result:='-8';
	 END IF;

	--ACCOUNT EXIST AND IS IN A VALID STATE BUT DOES THE PASSWORD MATCH?
	SELECT userpass 
	  INTO v_password
	  FROM tbs_user
	 WHERE recid=v_rec."rid";
	
	IF (( v_password = md5(TRIM(p_password))::VARCHAR ) AND v_result='' ) THEN
	   --PASSWORD MATCH FOUND
	   --RESET LOGIN ATTEMPTS
	    UPDATE tbs_user
	      SET "falselogin"=0
            WHERE  recid=v_rec.rid;
	  
	   --DOUBLE LOGIN POSSIBLE?
	   SELECT COUNT(userid)
	     INTO v_count
	     FROM tbs_session
	    WHERE "userid"=v_rec.rid;
	   IF ((v_count>0) AND v_result='') THEN
	        v_message:=fns_errormessage(9);
		v_result :='-9';
	   END IF;

	   --SAME BROWSER INSTANCE SESSION
	   SELECT COUNT (userid)
           INTO v_count
           FROM tbs_session
           WHERE (    tbs_session."sessionid" = TRIM(p_sessionid)
		  AND tbs_session."userid" != v_rec.rid
                  AND tbs_session."expires" > current_timestamp
                 );
	   IF ((v_count>0) AND v_result='') THEN
	      v_message:=fns_errormessage(10);
	      v_result := '-10';
	   END IF;

	   -- ALAS, ALL IS WELL.
	   --UPDATE USER TABLE
	   UPDATE tbs_user 
	      SET 
		  "lastlogindate"=now(),
		  "sessionid"=p_sessionid,
		  "falselogin"=0
	   WHERE "recid"=v_rec."rid";


      --ASSOCIATE USER WITH A SESSION IN THE TABLE
      UPDATE tbs_session
         SET "userid" = v_rec."rid"
       WHERE "sessionid" = p_sessionid;


	   v_message:='Login Successful';
	   v_result:=v_rec."rid";

	   
	ELSE
	     --PASSWORD MIS-MATCH
		IF ((v_rec.flg >= v_rec.pla) AND  v_rec.flg < (v_rec.ila + v_rec.pla) AND v_result='') THEN
		    UPDATE tbs_user
	              SET falselogin=falselogin+1
	            WHERE tbs_user.recid=v_rec.rid;
		 
		   v_message := fns_errormessage(11);	
		   v_result  := '-11';
		ELSIF (( v_rec.flg >= (v_rec.ila + v_rec.pla) ) AND v_result='') THEN
		   --ENOUGH GUESSING, LOCK ACCOUNT
			UPDATE tbs_user
			   SET status=2
			WHERE tbs_user.recid=v_rec.rid;
			v_message :=fns_errormessage(7);
			v_result  := '-7';
		ELSIF(v_result='') THEN
  		    UPDATE tbs_user
	               SET falselogin=falselogin+1
	             WHERE tbs_user.recid=v_rec.rid;

		    v_message := fns_errormessage(12);
		    v_result  := '-12';
		END IF;
	END IF; 

	SELECT v_result AS rlt,v_message AS msg
	  INTO v_rtnrec;
	
	RETURN v_rtnrec;
END;
$$;


ALTER FUNCTION public.sps_security_login(p_username character varying, p_password character varying, p_sessionid character varying) OWNER TO kpuser;

--
-- TOC entry 393 (class 1255 OID 58556)
-- Name: sps_security_privileges(bigint, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_security_privileges(p_roleid bigint, p_context bigint) RETURNS SETOF public.vws_privilege
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_ackey  int4;
    v_status int4;
    
    v_cur   CURSOR(v_context int8, v_accesskey int4, v_status int4)
	FOR SELECT * FROM vws_privilege 
	    WHERE ((acl::bit(32) & v_accesskey::bit(32))::int4 = v_accesskey 
	      AND v_accesskey<>0 
	      AND sts <= v_status
	      AND ast > 0
	      AND (ctx::bit(32) & v_context::bit(32))::int4 = v_context)  --context...TODO: can we use role.privilegelist to resolve this?
	      
	    ORDER BY ord;

    v_rec  vws_privilege%ROWTYPE;
BEGIN 
	SELECT acl
          INTO v_ackey
          FROM vws_role
	 WHERE rid=p_roleid;

	IF NOT FOUND THEN
	   RETURN;
	END IF;
	-- For superuser privileges
	IF p_roleid = 1 THEN
	   v_status := 2;
	ELSE
	   v_status := 1;
	END IF;
	
	-- Use context to determine privilege domain
	-- Many applications may use the same db in diff context
	
	OPEN v_cur(p_context, v_ackey, v_status); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_security_privileges(p_roleid bigint, p_context bigint) OWNER TO kpuser;

--
-- TOC entry 394 (class 1255 OID 58557)
-- Name: sps_security_pwchange(bigint, character varying, character varying); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_security_pwchange(p_userid bigint, p_oldpassword character varying, p_newpassword character varying) RETURNS public.vws_secresult
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur CURSOR(v_userid int8)
    FOR SELECT * FROM vws_user WHERE "rid"=v_userid
    LIMIT 1 OFFSET 0;

    v_rec  vws_user%ROWTYPE;

    v_rtnrec vws_secresult%ROWTYPE;

    v_password varchar;
    v_result varchar;
    v_message varchar;
BEGIN 
	v_result:='';

	OPEN v_cur(p_userid); 
	
	FETCH v_cur INTO v_rec;
	
	--DOES A USER WITH THIS USERID EXIST?
	IF ((NOT FOUND) AND v_result='' ) THEN
		v_message:=fns_errormessage(13);
		v_result :='-13';
	END IF;

	--ACCOUNT EXIST BUT DOES THE CURRENT PASSWORD MATCH THE PROVIDED OLD PASSWORD?
	SELECT userpass 
	  INTO v_password
	  FROM tbs_user
	 WHERE recid=v_rec."rid";
	
	IF (( v_password = md5(TRIM(p_oldpassword))::VARCHAR ) AND v_result='' ) THEN
	   --OLD PASSWORD MATCH FOUND
	   --CHANGE PASSWORD
	    UPDATE tbs_user
	      SET  userpass= md5(TRIM(p_newpassword))::VARCHAR,
		   "loginstatus"=1
            WHERE  recid=v_rec.rid;
	  
	    v_message:='Change password successful';
	    v_result:=1;
	ELSE
	   --PASSWORD MIS-MATCH
	     v_message:=fns_errormessage(14);
	     v_result:='-14';
	END IF; 

	SELECT v_result AS rlt,v_message AS msg 
	  INTO v_rtnrec;
		
	CLOSE v_cur;

	RETURN v_rtnrec;
END;
$$;


ALTER FUNCTION public.sps_security_pwchange(p_userid bigint, p_oldpassword character varying, p_newpassword character varying) OWNER TO kpuser;

--
-- TOC entry 395 (class 1255 OID 58558)
-- Name: sps_session_close(); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_session_close() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE	
	
BEGIN
	/**
		THIS IS JUST A DUMMY FUNCTION
	**/
	RETURN;
END;
$$;


ALTER FUNCTION public.sps_session_close() OWNER TO kpuser;

--
-- TOC entry 396 (class 1255 OID 58559)
-- Name: sps_session_destroy(character varying); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_session_destroy(p_sessionid character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE	
	
BEGIN
	DELETE FROM tbs_session WHERE TRIM(UPPER(sessionid))=TRIM(UPPER(p_sessionid));
	RETURN;
END;
$$;


ALTER FUNCTION public.sps_session_destroy(p_sessionid character varying) OWNER TO kpuser;

--
-- TOC entry 397 (class 1255 OID 58560)
-- Name: sps_session_gc(); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_session_gc() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE	
	
BEGIN
	DELETE FROM tbs_session WHERE current_timestamp>"expires";
	RETURN;
END;
$$;


ALTER FUNCTION public.sps_session_gc() OWNER TO kpuser;

--
-- TOC entry 399 (class 1255 OID 58561)
-- Name: sps_session_open(character varying); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_session_open(p_sessionid character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_cur CURSOR(v_sessionid VARCHAR)
	      FOR SELECT * FROM tbs_session
	      WHERE TRIM(LOWER(sessionid))=TRIM(LOWER(v_sessionid));
        
        
	v_rec tbs_session%ROWTYPE;
	v_sessiontimeout varchar;
	v_userid int8;
	v_sto int4;
	v_errnum int4;
BEGIN
	/** SET SESSION ERROR NUMBER in tbs_error**/
	v_errnum := 4;
	/** MOP UP EXPIRED SESSIONS **/
	PERFORM sps_session_gc();
	

	OPEN v_cur(p_sessionid);
	
	FETCH v_cur INTO v_rec;
	
	IF (NOT FOUND ) THEN
	   CLOSE v_cur;
	   --SESSION DOES NOT EXIST AND SO WE CREATE A NEW ONE USING
	   --DEFAULT SESSION TIMEOUT.
	          v_sessiontimeout:=fns_defaultsessiontimeout()||' MIN';

		   --INSERT SESSION RECORD INTO TABLE
		   INSERT INTO tbs_session
			       (sessionid, expires,data)
		      VALUES   (p_sessionid, (current_timestamp + COALESCE(v_sessiontimeout::interval,'0 sec'::interval )), '');
	ELSE 
	   CLOSE v_cur;
	   --SESSION EXIST.

	   --VALIDATE IF IT HAS EXPIRED AND CLEAN UP SESSION
	   IF (current_timestamp >= v_rec.expires )
	   THEN
		DELETE FROM tbs_session WHERE "sessionid"=p_sessionid;
		RAISE EXCEPTION '%',fns_errormessage(v_errnum);
	   END IF;
	   
	   --SESSION HAS NOT EXPIRED, UPDATE IT.
	   SELECT "sto"
	     INTO v_sto
	     FROM vws_user
	    WHERE "rid" IN (SELECT "userid" FROM tbs_session WHERE TRIM(LOWER("sessionid"))=TRIM(LOWER(p_sessionid)));
	   
	   v_sessiontimeout:=COALESCE(v_sto,fns_defaultsessiontimeout())||' MIN';
	   
	   UPDATE tbs_session 
	   SET expires=(current_timestamp  + COALESCE(v_sessiontimeout::interval,'0 SEC'::interval ) )
	   WHERE TRIM(LOWER("sessionid"))=TRIM(LOWER(p_sessionid));
	END IF;
	RETURN;
END;
$$;


ALTER FUNCTION public.sps_session_open(p_sessionid character varying) OWNER TO kpuser;

--
-- TOC entry 400 (class 1255 OID 58562)
-- Name: sps_session_read(character varying); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_session_read(p_sessionid character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_data text;
BEGIN
	/** MOP UP EXPIRED SESSIONS **/
	PERFORM sps_session_gc();
	
	SELECT data as sesiondata
	  INTO v_data
	  FROM tbs_session
	 WHERE "sessionid"=TRIM(p_sessionid);

	RETURN v_data;
END;
$$;


ALTER FUNCTION public.sps_session_read(p_sessionid character varying) OWNER TO kpuser;

--
-- TOC entry 401 (class 1255 OID 58563)
-- Name: sps_session_write(character varying, text); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_session_write(p_sessionid character varying, p_data text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_cur CURSOR(v_sessionid VARCHAR)
	      FOR SELECT * FROM tbs_session
	      WHERE TRIM(LOWER(sessionid))=TRIM(LOWER(v_sessionid));
        
        
	v_rec tbs_session%ROWTYPE;
	v_sessiontimeout varchar;
	v_sto int4;
	v_errnum int4;
BEGIN
	/** SET SESSION ERROR NUMBER in tbs_error**/
	v_errnum := 4;
	/** MOP UP EXPIRED SESSIONS **/
	PERFORM sps_session_gc();
	

	OPEN v_cur(p_sessionid);
	
	FETCH v_cur INTO v_rec;

	--OBTAIN SESSION_TIMEOUT FROM SYSTEMDEFAULT TABLE

        v_sessiontimeout:=fns_defaultsessiontimeout()||' MIN';
	
	IF (NOT FOUND ) THEN
	   --SESSION DOES NOT EXIST AND SO WE CREATE A NEW ONE.
	   INSERT INTO tbs_session
	               (sessionid, expires,data)
	      VALUES   (p_sessionid, (current_timestamp + COALESCE(v_sessiontimeout::interval,'0 SEC'::interval )), '');	
	ELSE
	   --SESSION EXIST.

	   --VALIDATE IF IT HAS EXPIRED AND CLEAN UP SESSION
	   IF (current_timestamp >= v_rec.expires )
	   THEN
		DELETE FROM tbs_session WHERE "sessionid"=p_sessionid;
		RAISE EXCEPTION '%',error_message(v_errnum);
	   END IF;
	   
	   --SESSION HAS NOT EXPIRED, UPDATE IT.
	   SELECT "sto"
	     INTO v_sto
	     FROM "vws_user"
	    WHERE "rid" IN (SELECT "userid" FROM tbs_session WHERE TRIM(LOWER("sessionid"))=TRIM(LOWER(p_sessionid)));
	   
	   v_sessiontimeout:=COALESCE(v_sto,fns_defaultsessiontimeout())||' MIN';

	   UPDATE tbs_session 
	   SET expires=(current_timestamp  + COALESCE(v_sessiontimeout::interval,'0 sec'::interval ) ),
	       "data"=COALESCE(p_data,'')
	   WHERE "sessionid"=p_sessionid;
  
	END IF;
	RETURN;
END;
$$;


ALTER FUNCTION public.sps_session_write(p_sessionid character varying, p_data text) OWNER TO kpuser;

--
-- TOC entry 402 (class 1255 OID 58564)
-- Name: sps_systemdefault_edit(bigint, character varying, timestamp without time zone, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_systemdefault_edit(p_recid bigint, p_value character varying, p_stamp timestamp without time zone, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_audit text;
BEGIN
	v_audit:='';

	/**Prepare Data for Audit **/
	SELECT (CASE WHEN LOWER(TRIM(COALESCE(sd.val,''))) != LOWER(TRIM(COALESCE(p_value,''))) 
	          THEN ' :: Value (O) = '||TRIM(COALESCE(sd.val,''))||', (N) = '||TRIM(COALESCE(p_value,''))
                  ELSE ''END)
	INTO v_audit
	FROM vws_systemdefault sd
	WHERE sd.rid=p_recid;

	/** Update **/
	UPDATE tbs_systemdefault
           SET recvalue=TRIM(p_value),
	       stamp=p_stamp
	 WHERE recid=p_recid;

	/** Get Return Data**/
	SELECT rid,stp
	  INTO v_rec
	  FROM vws_systemdefault
	 WHERE rid = p_recid;

	/** If there is the need for an audit trail, record it **/
-- 	IF v_audit!='' THEN
-- 		v_audit:='RecId = '||p_recid||v_audit;
-- 		PERFORM fns_audittrail_add(p_userid,'SystemDefault Edit',v_audit);
-- 	END IF;
	
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sps_systemdefault_edit(p_recid bigint, p_value character varying, p_stamp timestamp without time zone, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 241 (class 1259 OID 58565)
-- Name: tbs_systemdefault; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_systemdefault (
    recid bigint NOT NULL,
    rectype character(1) DEFAULT 'G'::bpchar NOT NULL,
    reckey character varying(50) NOT NULL,
    recvalue character varying(4000) NOT NULL,
    description text,
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tbs_systemdefault OWNER TO kpuser;

--
-- TOC entry 242 (class 1259 OID 58573)
-- Name: vws_systemdefault; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_systemdefault AS
 SELECT sd.recid AS rid,
    sd.rectype AS typ,
    sd.reckey AS nam,
    sd.description AS dsc,
    sd.recvalue AS val,
    sd.stamp AS stp
   FROM public.tbs_systemdefault sd;


ALTER TABLE public.vws_systemdefault OWNER TO kpuser;

--
-- TOC entry 403 (class 1255 OID 58577)
-- Name: sps_systemdefault_find(bigint, character varying, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sps_systemdefault_find(p_recid bigint, p_name character varying, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vws_systemdefault
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_cur   CURSOR(v_recid int8, 
		   v_name "varchar", 
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vws_systemdefault WHERE
	  COALESCE("rid"::VARCHAR,'') = COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,'') )
      AND COALESCE(nam,'') = COALESCE(v_name, nam, '')
      --AND UPPER(TRIM("type"))='G'
    LIMIT COALESCE(v_pagelimit,9223372036854775807)  OFFSET COALESCE(v_pageoffset,0);

    v_rec  vws_systemdefault%ROWTYPE;
BEGIN 
	--COUNT OF VALID RECORDS
	SELECT COUNT(*)
	  INTO v_rec.rid
	  FROM vws_systemdefault WHERE
	  COALESCE("rid"::VARCHAR,'') = COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,'') )
      AND COALESCE(nam,'') = COALESCE(p_name, nam,'')
      /*AND UPPER(TRIM("type"))='G'*/;
	  RETURN NEXT v_rec;

	OPEN v_cur(p_recid,p_name,p_pageoffset,p_pagelimit); 
	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;

	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_systemdefault_find(p_recid bigint, p_name character varying, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 398 (class 1255 OID 58578)
-- Name: sps_user_add(character varying, character varying, character varying, character varying, bigint, bigint, character varying, character varying, character varying, text, integer, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_user_add(p_surname character varying, p_othernames character varying, p_username character varying, p_password character varying, p_entityid bigint, p_roleid bigint, p_contactno1 character varying, p_contactno2 character varying, p_email character varying, p_comments text, p_status integer, p_userid bigint) RETURNS SETOF public.vws_add
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_add%ROWTYPE;
	v_audit text;
BEGIN
        IF p_roleid=1 THEN
	  RAISE EXCEPTION '%',fns_errormessage(3);
	END IF;

	/**Insert Data Into Table**/
	INSERT INTO tbs_user (entityid,
			    surname,
			    othernames,
			    username,
			    userpass,
			    roleid,
			    loginstatus,
	                    datecreated,
			    lastpasswordresetdate,
			    lastlogindate,
                            contactno1,
			    contactno2,
			    email,
			    comments,
			    status,
			    stamp) 
	     VALUES 	    (p_entityid,
			     TRIM(p_surname),
			     TRIM(p_othernames),
			     TRIM(p_username),
			     md5(TRIM(p_password)),
			     p_roleid,
			     0,
			     now(),
			     now(),
			     now(),
			     TRIM(p_contactno1),
			     TRIM(p_contactno2),
			     TRIM(p_email),
			     TRIM(p_comments),
			     p_status,
			     now());

	/**Obtain Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vws_user
	 WHERE rid IN (SELECT MAX(rid) FROM vws_user);

	/**Prepare Data for Audit **/
	 SELECT 'RecId = '              ||COALESCE(us.rid::varchar,'')
		||' :: Surname = '      ||COALESCE(us.snm::VARCHAR,'')
		||' :: OtherNames = '   ||COALESCE(us.onm::varchar,'')
	        ||' :: Username = '     ||COALESCE(us.unm::varchar,'')
		||' :: EntityId = '     ||COALESCE(us.eni::varchar,'')
		||' :: RoleId = '       ||COALESCE(us.roi::varchar,'')
		||' :: LoginStatus = '  ||COALESCE(us.lst::varchar,'')
		||' :: ContactNo1 = '   ||COALESCE(us.ct1::varchar,'')
		||' :: ContactNo2 = '   ||COALESCE(us.ct2::varchar,'')
		||' :: Email = '        ||COALESCE(us.eml::varchar,'')
		||' :: DateCreated = '  ||COALESCE(us.dct::varchar,'')
		||' :: LastLoginDate = '||COALESCE(us.lld::varchar,'')
		||' :: Comments = '     ||COALESCE(us.com::varchar,'')
		||' :: Status = '       ||COALESCE(us.sts::varchar,'')
		||' :: ApStatus = '     ||COALESCE(us.ast::varchar,'')
		||' :: Stamp = '        ||COALESCE(us.stp::varchar,'')
	INTO v_audit
	FROM vws_user us
	WHERE us.rid=v_rec.rid;
	
	/**Record Audit**/
	PERFORM fns_audittrail_add(p_userid,'User Add',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sps_user_add(p_surname character varying, p_othernames character varying, p_username character varying, p_password character varying, p_entityid bigint, p_roleid bigint, p_contactno1 character varying, p_contactno2 character varying, p_email character varying, p_comments text, p_status integer, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 404 (class 1255 OID 58579)
-- Name: sps_user_edit(bigint, character varying, character varying, bigint, character varying, character varying, character varying, text, integer, timestamp without time zone, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_user_edit(p_recid bigint, p_surname character varying, p_othernames character varying, p_roleid bigint, p_contactno1 character varying, p_contactno2 character varying, p_email character varying, p_comments text, p_status integer, p_stamp timestamp without time zone, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_audit text;
BEGIN
	IF p_roleid=1 THEN
	  RAISE EXCEPTION '%',fns_errormessage(3);
	END IF;

	v_audit:='';



	/**Prepare Data for Audit **/
	SELECT (CASE WHEN LOWER(TRIM(COALESCE(us.snm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_surname::VARCHAR,''))) 
	          THEN ' :: Surname (O) = '||TRIM(COALESCE(us.snm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_surname::VARCHAR,'')) 
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.onm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_othernames::VARCHAR,''))) 
	          THEN ' :: Other Names (O) = '||TRIM(COALESCE(us.onm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_othernames::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.roi::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_roleid::VARCHAR,''))) 
	          THEN ' :: Name (O) = '||TRIM(COALESCE(us.roi::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_roleid::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.ct1::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_contactno1::VARCHAR,'')))
	          THEN ' :: ContactNo1 (O) = '||TRIM(COALESCE(us.ct1::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_contactno1::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.ct2::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_contactno2::VARCHAR,'')))
	          THEN ' :: ContactNo2 (O) = '||TRIM(COALESCE(us.ct2::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_contactno2::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.eml::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_email::VARCHAR,'')))
	          THEN ' :: Email (O) = '||TRIM(COALESCE(us.eml::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_email::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.com::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_comments::VARCHAR,'')))
	          THEN ' :: Comments (O) = '||TRIM(COALESCE(us.com::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_comments::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN TRIM(COALESCE(us.sts::VARCHAR,'')) != TRIM(COALESCE(p_status::VARCHAR,''))
	          THEN ' :: Status (O) = '||TRIM(COALESCE(us.sts::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_status::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN TRIM(COALESCE(us.stp::VARCHAR,''))!=TRIM(TRIM(COALESCE(p_stamp::VARCHAR,'')))
	          THEN ' :: Stamp (O) = '||TRIM(COALESCE(us.stp::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_stamp::VARCHAR,''))
                  ELSE ''END)
	INTO v_audit
	FROM vws_user us
	WHERE us.rid=p_recid;

	UPDATE tbs_user
           SET surname=TRIM(p_surname),
	       othernames=TRIM(p_othernames),
	       roleid=p_roleid,
	       contactno1=TRIM(p_contactno1),
	       contactno2=TRIM(p_contactno2),
	       email=TRIM(p_email),
	       comments=TRIM(p_comments),
	       status=p_status,
	       stamp= p_stamp
	 WHERE recid=p_recid; 
	

	/** If there is the need for an audit trail, record it **/
	IF NOT(v_audit='') THEN
		v_audit:='RecId = '||p_recid||v_audit;
		PERFORM fns_audittrail_add(p_userid,'User Edit',v_audit);
	END IF;
	
	/**Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vws_user
	 WHERE rid = p_recid;
	RETURN NEXT v_rec;

END;
$$;


ALTER FUNCTION public.sps_user_edit(p_recid bigint, p_surname character varying, p_othernames character varying, p_roleid bigint, p_contactno1 character varying, p_contactno2 character varying, p_email character varying, p_comments text, p_status integer, p_stamp timestamp without time zone, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 405 (class 1255 OID 58580)
-- Name: sps_user_edit(bigint, character varying, character varying, character varying, bigint, character varying, character varying, character varying, text, integer, timestamp without time zone, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sps_user_edit(p_recid bigint, p_username character varying, p_surname character varying, p_othernames character varying, p_roleid bigint, p_contactno1 character varying, p_contactno2 character varying, p_email character varying, p_comments text, p_status integer, p_stamp timestamp without time zone, p_userid bigint) RETURNS SETOF public.vws_edit
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_edit%ROWTYPE;
	v_audit text;
BEGIN
	IF p_roleid=1 THEN
	  RAISE EXCEPTION '%',fns_errormessage(3);
	END IF;

	v_audit:='';



	/**Prepare Data for Audit **/
	SELECT (CASE WHEN LOWER(TRIM(COALESCE(us.unm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_username::VARCHAR,''))) 
	          THEN ' :: Username (O) = '||TRIM(COALESCE(us.unm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_username::VARCHAR,'')) 
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.snm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_surname::VARCHAR,''))) 
	          THEN ' :: Surname (O) = '||TRIM(COALESCE(us.snm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_surname::VARCHAR,'')) 
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.onm::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_othernames::VARCHAR,''))) 
	          THEN ' :: Other Names (O) = '||TRIM(COALESCE(us.onm::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_othernames::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.roi::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_roleid::VARCHAR,''))) 
	          THEN ' :: Name (O) = '||TRIM(COALESCE(us.roi::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_roleid::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.ct1::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_contactno1::VARCHAR,'')))
	          THEN ' :: ContactNo1 (O) = '||TRIM(COALESCE(us.ct1::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_contactno1::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.ct2::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_contactno2::VARCHAR,'')))
	          THEN ' :: ContactNo2 (O) = '||TRIM(COALESCE(us.ct2::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_contactno2::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.eml::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_email::VARCHAR,'')))
	          THEN ' :: Email (O) = '||TRIM(COALESCE(us.eml::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_email::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN LOWER(TRIM(COALESCE(us.com::VARCHAR,''))) != LOWER(TRIM(COALESCE(p_comments::VARCHAR,'')))
	          THEN ' :: Comments (O) = '||TRIM(COALESCE(us.com::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_comments::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN TRIM(COALESCE(us.sts::VARCHAR,'')) != TRIM(COALESCE(p_status::VARCHAR,''))
	          THEN ' :: Status (O) = '||TRIM(COALESCE(us.sts::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_status::VARCHAR,''))
                  ELSE ''END)||
	       (CASE WHEN TRIM(COALESCE(us.stp::VARCHAR,''))!=TRIM(TRIM(COALESCE(p_stamp::VARCHAR,'')))
	          THEN ' :: Stamp (O) = '||TRIM(COALESCE(us.stp::VARCHAR,''))||', (N) = '||TRIM(COALESCE(p_stamp::VARCHAR,''))
                  ELSE ''END)
	INTO v_audit
	FROM vws_user us
	WHERE us.rid=p_recid;

	UPDATE tbs_user
           SET username=TRIM(p_username), 
	       surname=TRIM(p_surname),
	       othernames=TRIM(p_othernames),
	       roleid=p_roleid,
	       contactno1=TRIM(p_contactno1),
	       contactno2=TRIM(p_contactno2),
	       email=TRIM(p_email),
	       comments=TRIM(p_comments),
	       status=p_status,
	       stamp= p_stamp
	 WHERE recid=p_recid; 
	

	/** If there is the need for an audit trail, record it **/
	IF NOT(v_audit='') THEN
		v_audit:='RecId = '||p_recid||v_audit;
		PERFORM fns_audittrail_add(p_userid,'User Edit',v_audit);
	END IF;
	
	/**Return Data**/
	SELECT rid,stp 
	  INTO v_rec
	  FROM vws_user
	 WHERE rid = p_recid;
	RETURN NEXT v_rec;

END;
$$;


ALTER FUNCTION public.sps_user_edit(p_recid bigint, p_username character varying, p_surname character varying, p_othernames character varying, p_roleid bigint, p_contactno1 character varying, p_contactno2 character varying, p_email character varying, p_comments text, p_status integer, p_stamp timestamp without time zone, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 406 (class 1255 OID 58581)
-- Name: sps_user_find(bigint, character varying, bigint, bigint, character varying, character varying, character varying, text, integer, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: kpuser
--

CREATE FUNCTION public.sps_user_find(p_recid bigint, p_name character varying, p_entityid bigint, p_roleid bigint, p_username character varying, p_contactno character varying, p_email character varying, p_comments text, p_status integer, p_apstatus integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vws_user
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_user_eti int8;

    v_cur   CURSOR(v_recid int8, 
		   v_name "varchar", 
		   v_entityid int8,
		   v_username "varchar",
		   v_roleid int8,
		   v_contactno "varchar",
		   v_email "varchar",
		   v_comments text,
		   v_status int4, 
		   v_apstatus int4, 
		   v_pageoffset int4, 
		   v_pagelimit int4,
		   v_queryuserid int8,
		   v_user_eti int8)
    FOR SELECT * FROM vws_user WHERE
        COALESCE("rid"::VARCHAR,'')= COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,'') )	    
    AND (
	  COALESCE("onm"::VARCHAR||"snm"::VARCHAR,'') ILIKE '%'|| COALESCE(replace(v_name::VARCHAR ,' ',''),COALESCE("onm"::VARCHAR||"snm"::VARCHAR,''))||'%'
	  OR
	  COALESCE("snm"::VARCHAR||"onm"::VARCHAR,'') ILIKE '%'|| COALESCE(replace(v_name::VARCHAR ,' ',''),COALESCE("snm"::VARCHAR||"onm"::VARCHAR,''))||'%'
	)
    AND COALESCE("eni"::VARCHAR,'')= COALESCE(v_entityid::VARCHAR,COALESCE("eni"::VARCHAR,'') )	  
    AND COALESCE("unm"::VARCHAR,'') ILIKE '%'|| COALESCE(v_username::VARCHAR ,COALESCE("unm"::VARCHAR,''))||'%'
    AND COALESCE("roi"::VARCHAR,'')= COALESCE(v_roleid::VARCHAR,COALESCE("roi"::VARCHAR,'') )	  
    AND (
	 COALESCE("ct1"::VARCHAR,'') ILIKE '%'|| COALESCE(v_contactno::VARCHAR,COALESCE("ct1"::VARCHAR,''))||'%'
	 OR
	 COALESCE("ct2"::VARCHAR,'') ILIKE '%'|| COALESCE(v_contactno::VARCHAR,COALESCE("ct1"::VARCHAR,''))||'%'
	)
    AND COALESCE("eml"::VARCHAR,'') ILIKE '%'|| COALESCE(v_email::VARCHAR ,COALESCE("eml"::VARCHAR,''))||'%'
    AND COALESCE("com"::VARCHAR,'') ILIKE '%'|| COALESCE(v_comments::VARCHAR ,COALESCE("com"::VARCHAR,''))||'%'
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND COALESCE("ast"::VARCHAR,'') = COALESCE(v_apstatus::VARCHAR ,COALESCE("ast"::VARCHAR,''))
    /**Block out fetch for superuser**/
    AND rid>2 
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vws_user%ROWTYPE;
BEGIN 
	SELECT us."eni"
	  INTO v_user_eti
	  FROM vws_user us
	 WHERE us."rid"=p_userid;

	SELECT COUNT(*)
	  INTO v_rec.rid
	FROM vws_user WHERE
        COALESCE("rid"::VARCHAR,'')= COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,'') )	    
    AND (
	  COALESCE("onm"::VARCHAR||"snm"::VARCHAR,'') ILIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("onm"::VARCHAR||"snm"::VARCHAR,''))||'%'
	  OR
	  COALESCE("snm"::VARCHAR||"onm"::VARCHAR,'') ILIKE '%'|| COALESCE(p_name::VARCHAR ,COALESCE("snm"::VARCHAR||"onm"::VARCHAR,''))||'%'
	)
    AND COALESCE("eni"::VARCHAR,'')= COALESCE(p_entityid::VARCHAR,COALESCE("eni"::VARCHAR,'') )	  
    AND COALESCE("unm"::VARCHAR,'') ILIKE '%'|| COALESCE(p_username::VARCHAR ,COALESCE("unm"::VARCHAR,''))||'%'
    AND COALESCE("roi"::VARCHAR,'')= COALESCE(p_roleid::VARCHAR,COALESCE("roi"::VARCHAR,'') )	  
    AND (
	 COALESCE("ct1"::VARCHAR,'') ILIKE '%'|| COALESCE(p_contactno::VARCHAR,COALESCE("ct1"::VARCHAR,''))||'%'
	 OR
	 COALESCE("ct2"::VARCHAR,'') ILIKE '%'|| COALESCE(p_contactno::VARCHAR,COALESCE("ct1"::VARCHAR,''))||'%'
	)
    AND COALESCE("eml"::VARCHAR,'') ILIKE '%'|| COALESCE(p_email::VARCHAR ,COALESCE("eml"::VARCHAR,''))||'%'
    AND COALESCE("com"::VARCHAR,'') ILIKE '%'|| COALESCE(p_comments::VARCHAR ,COALESCE("com"::VARCHAR,''))||'%'
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND COALESCE("ast"::VARCHAR,'') = COALESCE(p_apstatus::VARCHAR ,COALESCE("ast"::VARCHAR,''))
    AND rid>1 
    /**Block Superuser from fetching non-skyfox users**/
    AND ( CASE WHEN v_user_eti = 1 AND p_userid = 1 THEN "eni"=1 ELSE "rid"="rid"  END) 
    /**Block Skyfox user from fetching other skyfox users **/
    --AND ( CASE WHEN v_user_eti = 1 AND p_userid <>1 THEN "eni"<>1 ELSE "eni"="eni" END)
    /**Block all other users from fetching any record **/
    AND ( CASE WHEN v_user_eti<>1 THEN "eni"=-1 ELSE "eni"="eni" END)  ;

	RETURN NEXT v_rec;


	OPEN v_cur(p_recid,p_name,p_entityid,p_username,p_roleid,p_contactno,p_email,p_comments,p_status,p_apstatus,p_pageoffset,p_pagelimit,p_userid,v_user_eti); 	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_user_find(p_recid bigint, p_name character varying, p_entityid bigint, p_roleid bigint, p_username character varying, p_contactno character varying, p_email character varying, p_comments text, p_status integer, p_apstatus integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO kpuser;

--
-- TOC entry 408 (class 1255 OID 58582)
-- Name: sps_usernew_add(character varying, character varying, character varying, character varying, character varying, integer, bigint, text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sps_usernew_add(p_surname character varying, p_othernames character varying, p_username character varying, p_email character varying, p_contactno1 character varying, p_gender integer, p_roleid bigint, p_address text, p_userid bigint) RETURNS SETOF public.vws_user
    LANGUAGE plpgsql
    AS $$
DECLARE	
	v_rec vws_user%ROWTYPE;
	v_audit text;
	v_password character varying;
BEGIN
        IF p_roleid=1 THEN
	  RAISE EXCEPTION '%',fns_errormessage(3);
	END IF;
	v_password = '123456789';
	/**Insert Data Into Table**/
	INSERT INTO tbs_user (entityid,
			    surname,
			    othernames,
			    username,
			    userpass,
			    roleid,
			    loginstatus,
	                    datecreated,
			    lastpasswordresetdate,
			    lastlogindate,
                            contactno1,
			    email,
			    comments,
			    status,
			    stamp,
			    gender) 
	     VALUES 	    (1,
			     TRIM(p_surname),
			     TRIM(p_othernames),
			     TRIM(p_username),
			     md5(TRIM(v_password)),
			     p_roleid,
			     0,
			     now(),
			     now(),
			     now(),
			     TRIM(p_contactno1),
			     TRIM(p_email),
			     TRIM(p_address),
			     1,
			     now(),
			     p_gender);

	/**Obtain Return Data**/
	SELECT *
	  INTO v_rec
	  FROM vws_user
	 WHERE rid IN (SELECT MAX(rid) FROM vws_user);

	/**Prepare Data for Audit **/
	 SELECT 'RecId = '              ||COALESCE(us.rid::varchar,'')
		||' :: Surname = '      ||COALESCE(us.snm::VARCHAR,'')
		||' :: OtherNames = '   ||COALESCE(us.onm::varchar,'')
	        ||' :: Username = '     ||COALESCE(us.unm::varchar,'')
		||' :: EntityId = '     ||COALESCE(us.eni::varchar,'')
		||' :: RoleId = '       ||COALESCE(us.roi::varchar,'')
		||' :: LoginStatus = '  ||COALESCE(us.lst::varchar,'')
		||' :: ContactNo1 = '   ||COALESCE(us.ct1::varchar,'')
		||' :: ContactNo2 = '   ||COALESCE(us.ct2::varchar,'')
		||' :: Email = '        ||COALESCE(us.eml::varchar,'')
		||' :: DateCreated = '  ||COALESCE(us.dct::varchar,'')
		||' :: LastLoginDate = '||COALESCE(us.lld::varchar,'')
		||' :: Comments = '     ||COALESCE(us.com::varchar,'')
		||' :: Status = '       ||COALESCE(us.sts::varchar,'')
		||' :: ApStatus = '     ||COALESCE(us.ast::varchar,'')
		||' :: Stamp = '        ||COALESCE(us.stp::varchar,'')
	INTO v_audit
	FROM vws_user us
	WHERE us.rid=v_rec.rid;
	
	/**Record Audit**/
	PERFORM fns_audittrail_add(p_userid,'User Add',v_audit);

	/**Return Data**/
	RETURN NEXT v_rec;
END;
$$;


ALTER FUNCTION public.sps_usernew_add(p_surname character varying, p_othernames character varying, p_username character varying, p_email character varying, p_contactno1 character varying, p_gender integer, p_roleid bigint, p_address text, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 409 (class 1255 OID 58583)
-- Name: sps_usernew_find(bigint, character varying, character varying, character varying, character varying, character varying, integer, bigint, text, integer, integer, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sps_usernew_find(p_recid bigint, p_firstname character varying, p_surname character varying, p_username character varying, p_email character varying, p_contact character varying, p_gender integer, p_roleid bigint, p_address text, p_status integer, p_apstatus integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) RETURNS SETOF public.vws_user
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE	
    v_user_eti int8;

    v_cur   CURSOR(v_recid int8, 
		   v_firstname "varchar", 
		   v_surname "varchar",
		   v_username "varchar",
		   v_email "varchar",
		   v_contactno "varchar",
		   v_gender int4,
		   v_roleid int8,
		   v_address text,
		   v_status int4, 
		   v_apstatus int4, 
		   v_pageoffset int4, 
		   v_pagelimit int4)
    FOR SELECT * FROM vws_user WHERE
        COALESCE("rid"::VARCHAR,'')= COALESCE(v_recid::VARCHAR,COALESCE("rid"::VARCHAR,'') )	     
    AND COALESCE("onm"::VARCHAR,'') ILIKE '%'|| COALESCE(v_firstname::VARCHAR ,COALESCE("onm"::VARCHAR,''))||'%'
    AND COALESCE("snm"::VARCHAR,'') ILIKE '%'|| COALESCE(v_surname::VARCHAR ,COALESCE("snm"::VARCHAR,''))||'%'
    AND COALESCE("unm"::VARCHAR,'') ILIKE '%'|| COALESCE(v_username::VARCHAR ,COALESCE("unm"::VARCHAR,''))||'%'
    AND COALESCE("eml"::VARCHAR,'') ILIKE '%'|| COALESCE(v_email::VARCHAR ,COALESCE("eml"::VARCHAR,''))||'%'
    AND COALESCE("ct1"::VARCHAR,'') ILIKE '%'|| COALESCE(v_contactno::VARCHAR ,COALESCE("ct1"::VARCHAR,''))||'%'
    AND COALESCE("gen"::VARCHAR,'')= COALESCE(v_gender::VARCHAR,COALESCE("gen"::VARCHAR,'') )	  
    AND COALESCE("roi"::VARCHAR,'')= COALESCE(v_roleid::VARCHAR,COALESCE("roi"::VARCHAR,'') )
    AND COALESCE("com"::VARCHAR,'') ILIKE '%'|| COALESCE(v_address::VARCHAR ,COALESCE("com"::VARCHAR,''))||'%'
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(v_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND COALESCE("ast"::VARCHAR,'') = COALESCE(v_apstatus::VARCHAR ,COALESCE("ast"::VARCHAR,''))
    /**Block out fetch for superuser**/
    AND rid>1 
    LIMIT COALESCE(v_pagelimit,9223372036854775807) OFFSET COALESCE(v_pageoffset,0);
    v_rec  vws_user%ROWTYPE;
BEGIN 
-- 	SELECT us."eni"
-- 	  INTO v_user_eti
-- 	  FROM vws_user us
-- 	 WHERE us."rid"=p_userid;

	SELECT COUNT(*)
	  INTO v_rec.rid
	FROM vws_user WHERE
         COALESCE("rid"::VARCHAR,'')= COALESCE(p_recid::VARCHAR,COALESCE("rid"::VARCHAR,'') )	     
    AND COALESCE("onm"::VARCHAR,'') ILIKE '%'|| COALESCE(p_firstname::VARCHAR ,COALESCE("onm"::VARCHAR,''))||'%'
    AND COALESCE("snm"::VARCHAR,'') ILIKE '%'|| COALESCE(p_surname::VARCHAR ,COALESCE("snm"::VARCHAR,''))||'%'
    AND COALESCE("unm"::VARCHAR,'') ILIKE '%'|| COALESCE(p_username::VARCHAR ,COALESCE("unm"::VARCHAR,''))||'%'
    AND COALESCE("eml"::VARCHAR,'') ILIKE '%'|| COALESCE(p_email::VARCHAR ,COALESCE("eml"::VARCHAR,''))||'%'
    AND COALESCE("ct1"::VARCHAR,'') ILIKE '%'|| COALESCE(p_contact::VARCHAR ,COALESCE("ct1"::VARCHAR,''))||'%'
    AND COALESCE("gen"::VARCHAR,'')= COALESCE(p_gender::VARCHAR,COALESCE("gen"::VARCHAR,'') )	  
    AND COALESCE("roi"::VARCHAR,'')= COALESCE(p_roleid::VARCHAR,COALESCE("roi"::VARCHAR,'') )
    AND COALESCE("com"::VARCHAR,'') ILIKE '%'|| COALESCE(p_address::VARCHAR ,COALESCE("com"::VARCHAR,''))||'%'
    AND COALESCE("sts"::VARCHAR,'') = COALESCE(p_status::VARCHAR ,COALESCE("sts"::VARCHAR,''))
    AND COALESCE("ast"::VARCHAR,'') = COALESCE(p_apstatus::VARCHAR ,COALESCE("ast"::VARCHAR,''))
    /**Block out fetch for superuser**/
    AND rid>1 ;

	RETURN NEXT v_rec;


	OPEN v_cur(p_recid,p_firstname,p_surname,p_username,p_email,p_contact,p_gender,p_roleid,p_address,p_status,p_apstatus,p_pageoffset,p_pagelimit); 	
	LOOP
	    FETCH v_cur INTO v_rec;
	    EXIT WHEN NOT FOUND;
	    RETURN NEXT v_rec;
	END LOOP;
	CLOSE v_cur;
END;
$$;


ALTER FUNCTION public.sps_usernew_find(p_recid bigint, p_firstname character varying, p_surname character varying, p_username character varying, p_email character varying, p_contact character varying, p_gender integer, p_roleid bigint, p_address text, p_status integer, p_apstatus integer, p_pageoffset integer, p_pagelimit integer, p_userid bigint) OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 58584)
-- Name: tb_category_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_category_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_category_recid_seq OWNER TO postgres;

--
-- TOC entry 3827 (class 0 OID 0)
-- Dependencies: 243
-- Name: tb_category_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_category_recid_seq OWNED BY public.tb_category.recid;


--
-- TOC entry 244 (class 1259 OID 58586)
-- Name: tb_country; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_country (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    shortcode character varying(5) NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_country_name CHECK (((recname)::text <> ''::text)),
    CONSTRAINT chek_country_shortcode CHECK (((shortcode)::text <> ''::text))
);


ALTER TABLE public.tb_country OWNER TO kpuser;

--
-- TOC entry 245 (class 1259 OID 58592)
-- Name: tb_country_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tb_country_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_country_recid_seq OWNER TO kpuser;

--
-- TOC entry 3828 (class 0 OID 0)
-- Dependencies: 245
-- Name: tb_country_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tb_country_recid_seq OWNED BY public.tb_country.recid;


--
-- TOC entry 246 (class 1259 OID 58594)
-- Name: tb_currency_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_currency_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_currency_recid_seq OWNER TO postgres;

--
-- TOC entry 3829 (class 0 OID 0)
-- Dependencies: 246
-- Name: tb_currency_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_currency_recid_seq OWNED BY public.tb_currency.recid;


--
-- TOC entry 247 (class 1259 OID 58596)
-- Name: tb_district; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_district (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    regionid integer NOT NULL,
    description text,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tb_district OWNER TO kpuser;

--
-- TOC entry 248 (class 1259 OID 58603)
-- Name: tb_district_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tb_district_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_district_recid_seq OWNER TO kpuser;

--
-- TOC entry 3830 (class 0 OID 0)
-- Dependencies: 248
-- Name: tb_district_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tb_district_recid_seq OWNED BY public.tb_district.recid;


--
-- TOC entry 249 (class 1259 OID 58605)
-- Name: tb_education; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_education (
    recid bigint NOT NULL,
    recname character varying NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tb_education OWNER TO kpuser;

--
-- TOC entry 250 (class 1259 OID 58612)
-- Name: tb_emprank; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_emprank (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    description text,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_emprank_name CHECK (((recname)::text <> ''::text))
);


ALTER TABLE public.tb_emprank OWNER TO kpuser;

--
-- TOC entry 251 (class 1259 OID 58620)
-- Name: tb_empstatus; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_empstatus (
    recid bigint NOT NULL,
    recname character varying NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tb_empstatus OWNER TO kpuser;

--
-- TOC entry 252 (class 1259 OID 58627)
-- Name: tb_enquiry_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_enquiry_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_enquiry_recid_seq OWNER TO postgres;

--
-- TOC entry 3831 (class 0 OID 0)
-- Dependencies: 252
-- Name: tb_enquiry_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_enquiry_recid_seq OWNED BY public.tb_enquiry.recid;


--
-- TOC entry 253 (class 1259 OID 58629)
-- Name: tb_idtype; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_idtype (
    recid bigint NOT NULL,
    recname character varying(20) NOT NULL,
    shortcode character varying(5) NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_idtype_name CHECK (((recname)::text <> ''::text)),
    CONSTRAINT chek_idtype_shortcode CHECK (((shortcode)::text <> ''::text))
);


ALTER TABLE public.tb_idtype OWNER TO kpuser;

--
-- TOC entry 254 (class 1259 OID 58635)
-- Name: tb_idtype_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tb_idtype_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_idtype_recid_seq OWNER TO kpuser;

--
-- TOC entry 3832 (class 0 OID 0)
-- Dependencies: 254
-- Name: tb_idtype_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tb_idtype_recid_seq OWNED BY public.tb_idtype.recid;


--
-- TOC entry 255 (class 1259 OID 58637)
-- Name: tb_issues_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_issues_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_issues_recid_seq OWNER TO postgres;

--
-- TOC entry 3833 (class 0 OID 0)
-- Dependencies: 255
-- Name: tb_issues_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_issues_recid_seq OWNED BY public.tb_issues.recid;


--
-- TOC entry 256 (class 1259 OID 58639)
-- Name: tb_moneypaid_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_moneypaid_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_moneypaid_recid_seq OWNER TO postgres;

--
-- TOC entry 3834 (class 0 OID 0)
-- Dependencies: 256
-- Name: tb_moneypaid_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_moneypaid_recid_seq OWNED BY public.tb_moneypaid.recid;


--
-- TOC entry 257 (class 1259 OID 58641)
-- Name: tb_officeheld; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_officeheld (
    recid bigint NOT NULL,
    recname character varying NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tb_officeheld OWNER TO kpuser;

--
-- TOC entry 258 (class 1259 OID 58648)
-- Name: tb_officeheld_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tb_officeheld_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_officeheld_recid_seq OWNER TO kpuser;

--
-- TOC entry 3835 (class 0 OID 0)
-- Dependencies: 258
-- Name: tb_officeheld_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tb_officeheld_recid_seq OWNED BY public.tb_officeheld.recid;


--
-- TOC entry 259 (class 1259 OID 58650)
-- Name: tb_paymenttype_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_paymenttype_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_paymenttype_recid_seq OWNER TO postgres;

--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 259
-- Name: tb_paymenttype_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_paymenttype_recid_seq OWNED BY public.tb_paymenttype.recid;


--
-- TOC entry 260 (class 1259 OID 58652)
-- Name: tb_product_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_product_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_product_recid_seq OWNER TO postgres;

--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 260
-- Name: tb_product_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_product_recid_seq OWNED BY public.tb_product.recid;


--
-- TOC entry 261 (class 1259 OID 58654)
-- Name: tb_productlog_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_productlog_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_productlog_recid_seq OWNER TO postgres;

--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 261
-- Name: tb_productlog_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_productlog_recid_seq OWNED BY public.tb_productlog.recid;


--
-- TOC entry 262 (class 1259 OID 58656)
-- Name: tb_productstatus_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_productstatus_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_productstatus_recid_seq OWNER TO postgres;

--
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 262
-- Name: tb_productstatus_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_productstatus_recid_seq OWNED BY public.tb_productstatus.recid;


--
-- TOC entry 263 (class 1259 OID 58658)
-- Name: tb_profession; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_profession (
    recid bigint NOT NULL,
    recname character varying NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tb_profession OWNER TO kpuser;

--
-- TOC entry 264 (class 1259 OID 58665)
-- Name: tb_profession_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tb_profession_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_profession_recid_seq OWNER TO kpuser;

--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 264
-- Name: tb_profession_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tb_profession_recid_seq OWNED BY public.tb_profession.recid;


--
-- TOC entry 265 (class 1259 OID 58667)
-- Name: tb_quotationtype_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_quotationtype_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_quotationtype_recid_seq OWNER TO postgres;

--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 265
-- Name: tb_quotationtype_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_quotationtype_recid_seq OWNED BY public.tb_quotationtype.recid;


--
-- TOC entry 266 (class 1259 OID 58669)
-- Name: tb_region; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_region (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    shortcode character varying(20),
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_region_name CHECK (((recname)::text <> ''::text))
);


ALTER TABLE public.tb_region OWNER TO kpuser;

--
-- TOC entry 267 (class 1259 OID 58674)
-- Name: tb_region_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tb_region_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_region_recid_seq OWNER TO kpuser;

--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 267
-- Name: tb_region_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tb_region_recid_seq OWNED BY public.tb_region.recid;


--
-- TOC entry 268 (class 1259 OID 58676)
-- Name: tb_relationship; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_relationship (
    recid bigint NOT NULL,
    recname character varying(200) NOT NULL,
    description text,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_relationship_name CHECK (((recname)::text <> ''::text))
);


ALTER TABLE public.tb_relationship OWNER TO kpuser;

--
-- TOC entry 269 (class 1259 OID 58684)
-- Name: tb_relationship_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tb_relationship_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_relationship_recid_seq OWNER TO kpuser;

--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 269
-- Name: tb_relationship_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tb_relationship_recid_seq OWNED BY public.tb_relationship.recid;


--
-- TOC entry 270 (class 1259 OID 58686)
-- Name: tb_residenttype; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tb_residenttype (
    recid bigint NOT NULL,
    recname character varying(20) NOT NULL,
    shortcode character varying(5) NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_residentype_name CHECK (((recname)::text <> ''::text)),
    CONSTRAINT chek_residentype_shortcode CHECK (((shortcode)::text <> ''::text))
);


ALTER TABLE public.tb_residenttype OWNER TO kpuser;

--
-- TOC entry 271 (class 1259 OID 58692)
-- Name: tb_residentype_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tb_residentype_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_residentype_recid_seq OWNER TO kpuser;

--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 271
-- Name: tb_residentype_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tb_residentype_recid_seq OWNED BY public.tb_residenttype.recid;


--
-- TOC entry 272 (class 1259 OID 58694)
-- Name: tb_sales_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_sales_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_sales_recid_seq OWNER TO postgres;

--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 272
-- Name: tb_sales_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_sales_recid_seq OWNED BY public.tb_sales.recid;


--
-- TOC entry 273 (class 1259 OID 58696)
-- Name: tb_salescode_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_salescode_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_salescode_recid_seq OWNER TO postgres;

--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 273
-- Name: tb_salescode_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_salescode_recid_seq OWNED BY public.tb_salescode.recid;


--
-- TOC entry 274 (class 1259 OID 58698)
-- Name: tb_savings_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_savings_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_savings_recid_seq OWNER TO postgres;

--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 274
-- Name: tb_savings_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_savings_recid_seq OWNED BY public.tb_savings.recid;


--
-- TOC entry 275 (class 1259 OID 58700)
-- Name: tb_section_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_section_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_section_recid_seq OWNER TO postgres;

--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 275
-- Name: tb_section_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_section_recid_seq OWNED BY public.tb_section.recid;


--
-- TOC entry 276 (class 1259 OID 58702)
-- Name: tb_shop_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_shop_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_shop_recid_seq OWNER TO postgres;

--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 276
-- Name: tb_shop_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_shop_recid_seq OWNED BY public.tb_shop.recid;


--
-- TOC entry 306 (class 1259 OID 59082)
-- Name: tb_unit_recid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_unit_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_unit_recid_seq OWNER TO postgres;

--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 306
-- Name: tb_unit_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_unit_recid_seq OWNED BY public.tb_unit.recid;


--
-- TOC entry 277 (class 1259 OID 58704)
-- Name: tbs_audittrail_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tbs_audittrail_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbs_audittrail_recid_seq OWNER TO kpuser;

--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 277
-- Name: tbs_audittrail_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tbs_audittrail_recid_seq OWNED BY public.tbs_audittrail.recid;


--
-- TOC entry 278 (class 1259 OID 58706)
-- Name: tbs_entity_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tbs_entity_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbs_entity_recid_seq OWNER TO kpuser;

--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 278
-- Name: tbs_entity_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tbs_entity_recid_seq OWNED BY public.tbs_entity.recid;


--
-- TOC entry 279 (class 1259 OID 58708)
-- Name: tbs_entitytype_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tbs_entitytype_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbs_entitytype_recid_seq OWNER TO kpuser;

--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 279
-- Name: tbs_entitytype_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tbs_entitytype_recid_seq OWNED BY public.tbs_entitytype.recid;


--
-- TOC entry 280 (class 1259 OID 58710)
-- Name: tbs_error; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_error (
    errorid integer DEFAULT 0 NOT NULL,
    message character varying(500) NOT NULL
);


ALTER TABLE public.tbs_error OWNER TO kpuser;

--
-- TOC entry 281 (class 1259 OID 58714)
-- Name: tbs_inbox; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_inbox (
    recid bigint NOT NULL,
    caption character varying(200) NOT NULL,
    message text NOT NULL,
    senddate timestamp without time zone NOT NULL,
    expiredate timestamp without time zone NOT NULL,
    userid bigint NOT NULL,
    status integer NOT NULL,
    stamp timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chek_inbox_caption CHECK (((caption)::text <> ''::text)),
    CONSTRAINT chek_inbox_message CHECK ((message <> ''::text))
);


ALTER TABLE public.tbs_inbox OWNER TO kpuser;

--
-- TOC entry 282 (class 1259 OID 58723)
-- Name: tbs_inbox_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tbs_inbox_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbs_inbox_recid_seq OWNER TO kpuser;

--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 282
-- Name: tbs_inbox_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tbs_inbox_recid_seq OWNED BY public.tbs_inbox.recid;


--
-- TOC entry 283 (class 1259 OID 58725)
-- Name: tbs_role_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tbs_role_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbs_role_recid_seq OWNER TO kpuser;

--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 283
-- Name: tbs_role_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tbs_role_recid_seq OWNED BY public.tbs_role.recid;


--
-- TOC entry 284 (class 1259 OID 58727)
-- Name: tbs_session; Type: TABLE; Schema: public; Owner: kpuser
--

CREATE TABLE public.tbs_session (
    userid bigint,
    expires timestamp without time zone NOT NULL,
    data text,
    sessionid character varying(100) NOT NULL
);


ALTER TABLE public.tbs_session OWNER TO kpuser;

--
-- TOC entry 285 (class 1259 OID 58733)
-- Name: tbs_user_recid_seq; Type: SEQUENCE; Schema: public; Owner: kpuser
--

CREATE SEQUENCE public.tbs_user_recid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbs_user_recid_seq OWNER TO kpuser;

--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 285
-- Name: tbs_user_recid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kpuser
--

ALTER SEQUENCE public.tbs_user_recid_seq OWNED BY public.tbs_user.recid;


--
-- TOC entry 286 (class 1259 OID 58735)
-- Name: vw_country; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_country AS
 SELECT co.recid AS rid,
    co.recname AS nam,
    co.shortcode AS shc,
    co.status AS sts,
    co.status AS ast,
    co.stamp AS stp
   FROM public.tb_country co;


ALTER TABLE public.vw_country OWNER TO kpuser;

--
-- TOC entry 287 (class 1259 OID 58739)
-- Name: vw_credit_member_sum; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_credit_member_sum AS
 SELECT cm.mno,
    cm.nam,
    cm.pti,
    cm.ptn,
    sum(cm.amt) AS amt,
    (count(cm.amt) - 1) AS cnt
   FROM public.vw_credit_member cm
  GROUP BY cm.mno, cm.nam, cm.pti, cm.ptn;


ALTER TABLE public.vw_credit_member_sum OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 58743)
-- Name: vw_credit_member_sum_salescode; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_credit_member_sum_salescode AS
 SELECT cm.mno,
    cm.nam,
    cm.scn,
    cm.pti,
    cm.ptn,
    sum(cm.amt) AS amt,
    sum((cm.smt * (cm.qty)::double precision)) AS smt,
    (count(cm.amt) - 1) AS cnt
   FROM public.vw_credit_member cm
  GROUP BY cm.mno, cm.nam, cm.scn, cm.pti, cm.ptn;


ALTER TABLE public.vw_credit_member_sum_salescode OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 58747)
-- Name: vw_district; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_district AS
 SELECT ds.recid AS rid,
    ds.recname AS nam,
    ds.regionid AS rei,
    rg.recname AS ren,
    rg.shortcode AS rsc,
    ds.description AS dsc,
    ds.status AS sts,
    ds.stamp AS stp
   FROM public.tb_district ds,
    public.tb_region rg
  WHERE (ds.regionid = rg.recid);


ALTER TABLE public.vw_district OWNER TO kpuser;

--
-- TOC entry 290 (class 1259 OID 58751)
-- Name: vw_education; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_education AS
 SELECT ed.recid AS rid,
    ed.recname AS nam,
    ed.status AS sts,
    ed.status AS ast,
    ed.stamp AS stp
   FROM public.tb_education ed;


ALTER TABLE public.vw_education OWNER TO kpuser;

--
-- TOC entry 291 (class 1259 OID 58755)
-- Name: vw_emprank; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_emprank AS
 SELECT rk.recid AS rid,
    rk.recname AS nam,
    rk.description AS dsc,
    rk.status AS sts,
    rk.status AS ast,
    rk.stamp AS stp
   FROM public.tb_emprank rk;


ALTER TABLE public.vw_emprank OWNER TO kpuser;

--
-- TOC entry 292 (class 1259 OID 58759)
-- Name: vw_empstatus; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_empstatus AS
 SELECT es.recid AS rid,
    es.recname AS nam,
    es.status AS sts,
    es.status AS ast,
    es.stamp AS stp
   FROM public.tb_empstatus es;


ALTER TABLE public.vw_empstatus OWNER TO kpuser;

--
-- TOC entry 293 (class 1259 OID 58763)
-- Name: vw_idtype; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_idtype AS
 SELECT id.recid AS rid,
    id.recname AS nam,
    id.shortcode AS shc,
    id.status AS sts,
    id.status AS ast,
    id.stamp AS stp
   FROM public.tb_idtype id;


ALTER TABLE public.vw_idtype OWNER TO kpuser;

--
-- TOC entry 294 (class 1259 OID 58767)
-- Name: vw_memberr; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_memberr AS
 SELECT mm.recid AS rid,
    mm.memberno AS mno,
    mm.surname AS snm,
    mm.firstname AS fnm,
    mm.dateofbirth AS dob,
    mm.mobileno AS mob,
    mm.phoneno AS tel,
    mm.nextofkin AS nxk,
    mm.nkphoneno AS nkt,
    mm.address AS had,
    mm.datecreated AS dcd,
    mm.userid AS usi,
    mm.pimg AS pmg,
    mm.status AS sts,
    mm.stamp AS stp,
    mm.shopid AS shi,
    us.surname AS usn,
    us.othernames AS uso,
    us.username AS unm,
    (upper(((mm.surname)::text || ', '::text)) || (mm.firstname)::text) AS nam,
    mt.tot
   FROM public.tb_member mm,
    public.tbs_user us,
    public.vw_member_totals mt
  WHERE ((us.recid = mm.userid) AND (mt.mid = mm.recid));


ALTER TABLE public.vw_memberr OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 58772)
-- Name: vw_officeheld; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_officeheld AS
 SELECT oh.recid AS rid,
    oh.recname AS nam,
    oh.status AS sts,
    oh.status AS ast,
    oh.stamp AS stp
   FROM public.tb_officeheld oh;


ALTER TABLE public.vw_officeheld OWNER TO kpuser;

--
-- TOC entry 296 (class 1259 OID 58776)
-- Name: vw_productlog; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_productlog AS
 SELECT pd.recid AS rid,
    pd.recname AS nam,
    pd.productcode AS pdc,
    pl.price AS prc,
    pl.quantity AS qty,
    pd.categoryid AS cid,
    ct.recname AS ctn,
    pd.userid AS usi,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    pl.expirydate AS edt,
    pl.status AS sts,
    pl.datecreated AS dcd,
    pl.stamp AS stp,
    pl.datcreated AS dat
   FROM public.tbs_user us,
    public.tb_category ct,
    public.tb_product pd,
    public.tb_productlog pl
  WHERE ((us.recid = pl.userid) AND (pd.recid = pl.productid) AND (ct.recid = pd.categoryid));


ALTER TABLE public.vw_productlog OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 58786)
-- Name: vw_profession; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_profession AS
 SELECT pf.recid AS rid,
    pf.recname AS nam,
    pf.status AS sts,
    pf.status AS ast,
    pf.stamp AS stp
   FROM public.tb_profession pf;


ALTER TABLE public.vw_profession OWNER TO kpuser;

--
-- TOC entry 298 (class 1259 OID 58790)
-- Name: vw_region; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_region AS
 SELECT r.recid AS rid,
    r.recname AS nam,
    r.shortcode AS shc,
    r.status AS sts,
    r.status AS ast,
    r.stamp AS stp
   FROM public.tb_region r;


ALTER TABLE public.vw_region OWNER TO kpuser;

--
-- TOC entry 299 (class 1259 OID 58794)
-- Name: vw_relationship; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_relationship AS
 SELECT re.recid AS rid,
    re.recname AS nam,
    re.description AS dsc,
    re.status AS sts,
    re.status AS ast,
    re.stamp AS stp
   FROM public.tb_relationship re;


ALTER TABLE public.vw_relationship OWNER TO kpuser;

--
-- TOC entry 300 (class 1259 OID 58798)
-- Name: vw_residenttype; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vw_residenttype AS
 SELECT rs.recid AS rid,
    rs.recname AS nam,
    rs.shortcode AS shc,
    rs.status AS sts,
    rs.status AS ast,
    rs.stamp AS stp
   FROM public.tb_residenttype rs;


ALTER TABLE public.vw_residenttype OWNER TO kpuser;

--
-- TOC entry 301 (class 1259 OID 58802)
-- Name: vw_sales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_sales AS
 SELECT sa.recid AS rid,
    sa.productid AS pid,
    pd.recname AS pnm,
    sa.quantity AS qty,
    sa.amount AS amt,
    sa.salescodeid AS sci,
    sc.salescode AS scn,
    sc.userid AS usi,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    sa.status AS sts,
    sa.datecreated AS dcd,
    sa.stamp AS stp
   FROM public.tbs_user us,
    public.tb_product pd,
    public.tb_sales sa,
    public.tb_salescode sc
  WHERE ((us.recid = sc.userid) AND (pd.recid = sa.productid) AND (sc.recid = sa.salescodeid));


ALTER TABLE public.vw_sales OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 58807)
-- Name: vw_salescode; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_salescode AS
 SELECT sc.recid AS rid,
    sc.salescode AS scn,
    sc.userid AS usi,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    sc.status AS sts,
    sc.datecreated AS dcd,
    sc.stamp AS stp,
    sc.datcreated AS dat,
    sc.phone AS tel,
    sc.paymenttypeid AS pti,
    pt.recname AS ptn,
    sc.amountpaid AS amt
   FROM public.tbs_user us,
    public.tb_salescode sc,
    public.tb_paymenttype pt
  WHERE ((us.recid = sc.userid) AND (sc.paymenttypeid = pt.recid));


ALTER TABLE public.vw_salescode OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 58811)
-- Name: vw_salescode_member; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_salescode_member AS
 SELECT sc.recid AS rid,
    sc.salescode AS scn,
    sc.userid AS usi,
    us.surname AS snm,
    us.othernames AS onm,
    us.username AS unm,
    sc.status AS sts,
    sc.datecreated AS dcd,
    sc.stamp AS stp,
    sc.datcreated AS dat,
    sc.paymenttypeid AS pti,
    pt.recname AS ptn,
    sc.amountpaid AS amt,
    mm.memberno AS mno,
    (upper(((mm.surname)::text || ', '::text)) || (mm.firstname)::text) AS nam,
    mm.mobileno AS tel,
    mm.phoneno AS mob
   FROM public.tbs_user us,
    public.tb_salescode sc,
    public.tb_paymenttype pt,
    public.tb_member mm
  WHERE ((us.recid = sc.userid) AND (sc.paymenttypeid = pt.recid) AND ((mm.memberno)::text = (sc.phone)::text));


ALTER TABLE public.vw_salescode_member OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 58816)
-- Name: vwr_member_profile; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vwr_member_profile AS
 SELECT NULL::bigint AS rid,
    NULL::character varying AS mno,
    NULL::character varying AS fnm,
    NULL::character varying AS snm,
    NULL::character varying AS nam,
    NULL::character varying AS mob,
    NULL::character varying AS pho,
    NULL::character varying AS eml,
    NULL::character varying AS dob,
    NULL::bigint AS coi,
    NULL::character varying AS cou,
    NULL::bigint AS grp,
    NULL::character varying AS gpn,
    NULL::character varying AS sts,
    NULL::character varying AS dtc;


ALTER TABLE public.vwr_member_profile OWNER TO kpuser;

--
-- TOC entry 305 (class 1259 OID 58820)
-- Name: vws_entitytype; Type: VIEW; Schema: public; Owner: kpuser
--

CREATE VIEW public.vws_entitytype AS
 SELECT et.recid AS rid,
    et.recname AS nam,
    et.privilegelist AS pls,
    et.status AS sts,
    et.status AS ast,
    et.stamp AS stp
   FROM public.tbs_entitytype et;


ALTER TABLE public.vws_entitytype OWNER TO kpuser;

--
-- TOC entry 3338 (class 2604 OID 59273)
-- Name: tb_category recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_category ALTER COLUMN recid SET DEFAULT nextval('public.tb_category_recid_seq'::regclass);


--
-- TOC entry 3403 (class 2604 OID 59274)
-- Name: tb_country recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_country ALTER COLUMN recid SET DEFAULT nextval('public.tb_country_recid_seq'::regclass);


--
-- TOC entry 3345 (class 2604 OID 59275)
-- Name: tb_currency recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_currency ALTER COLUMN recid SET DEFAULT nextval('public.tb_currency_recid_seq'::regclass);


--
-- TOC entry 3407 (class 2604 OID 59276)
-- Name: tb_district recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_district ALTER COLUMN recid SET DEFAULT nextval('public.tb_district_recid_seq'::regclass);


--
-- TOC entry 3350 (class 2604 OID 59277)
-- Name: tb_enquiry recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_enquiry ALTER COLUMN recid SET DEFAULT nextval('public.tb_enquiry_recid_seq'::regclass);


--
-- TOC entry 3413 (class 2604 OID 59278)
-- Name: tb_idtype recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_idtype ALTER COLUMN recid SET DEFAULT nextval('public.tb_idtype_recid_seq'::regclass);


--
-- TOC entry 3358 (class 2604 OID 59279)
-- Name: tb_issues recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_issues ALTER COLUMN recid SET DEFAULT nextval('public.tb_issues_recid_seq'::regclass);


--
-- TOC entry 3362 (class 2604 OID 59280)
-- Name: tb_moneypaid recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_moneypaid ALTER COLUMN recid SET DEFAULT nextval('public.tb_moneypaid_recid_seq'::regclass);


--
-- TOC entry 3417 (class 2604 OID 59281)
-- Name: tb_officeheld recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_officeheld ALTER COLUMN recid SET DEFAULT nextval('public.tb_officeheld_recid_seq'::regclass);


--
-- TOC entry 3308 (class 2604 OID 59282)
-- Name: tb_paymenttype recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_paymenttype ALTER COLUMN recid SET DEFAULT nextval('public.tb_paymenttype_recid_seq'::regclass);


--
-- TOC entry 3318 (class 2604 OID 59283)
-- Name: tb_product recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_product ALTER COLUMN recid SET DEFAULT nextval('public.tb_product_recid_seq'::regclass);


--
-- TOC entry 3369 (class 2604 OID 59284)
-- Name: tb_productlog recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_productlog ALTER COLUMN recid SET DEFAULT nextval('public.tb_productlog_recid_seq'::regclass);


--
-- TOC entry 3340 (class 2604 OID 59285)
-- Name: tb_productstatus recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_productstatus ALTER COLUMN recid SET DEFAULT nextval('public.tb_productstatus_recid_seq'::regclass);


--
-- TOC entry 3419 (class 2604 OID 59286)
-- Name: tb_profession recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_profession ALTER COLUMN recid SET DEFAULT nextval('public.tb_profession_recid_seq'::regclass);


--
-- TOC entry 3352 (class 2604 OID 59287)
-- Name: tb_quotationtype recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_quotationtype ALTER COLUMN recid SET DEFAULT nextval('public.tb_quotationtype_recid_seq'::regclass);


--
-- TOC entry 3421 (class 2604 OID 59288)
-- Name: tb_region recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_region ALTER COLUMN recid SET DEFAULT nextval('public.tb_region_recid_seq'::regclass);


--
-- TOC entry 3424 (class 2604 OID 59289)
-- Name: tb_relationship recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_relationship ALTER COLUMN recid SET DEFAULT nextval('public.tb_relationship_recid_seq'::regclass);


--
-- TOC entry 3427 (class 2604 OID 59290)
-- Name: tb_residenttype recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_residenttype ALTER COLUMN recid SET DEFAULT nextval('public.tb_residentype_recid_seq'::regclass);


--
-- TOC entry 3323 (class 2604 OID 59291)
-- Name: tb_sales recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_sales ALTER COLUMN recid SET DEFAULT nextval('public.tb_sales_recid_seq'::regclass);


--
-- TOC entry 3327 (class 2604 OID 59292)
-- Name: tb_salescode recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_salescode ALTER COLUMN recid SET DEFAULT nextval('public.tb_salescode_recid_seq'::regclass);


--
-- TOC entry 3330 (class 2604 OID 59293)
-- Name: tb_savings recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_savings ALTER COLUMN recid SET DEFAULT nextval('public.tb_savings_recid_seq'::regclass);


--
-- TOC entry 3364 (class 2604 OID 59294)
-- Name: tb_section recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_section ALTER COLUMN recid SET DEFAULT nextval('public.tb_section_recid_seq'::regclass);


--
-- TOC entry 3343 (class 2604 OID 59295)
-- Name: tb_shop recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_shop ALTER COLUMN recid SET DEFAULT nextval('public.tb_shop_recid_seq'::regclass);


--
-- TOC entry 3435 (class 2604 OID 59087)
-- Name: tb_unit recid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_unit ALTER COLUMN recid SET DEFAULT nextval('public.tb_unit_recid_seq'::regclass);


--
-- TOC entry 3371 (class 2604 OID 59296)
-- Name: tbs_audittrail recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_audittrail ALTER COLUMN recid SET DEFAULT nextval('public.tbs_audittrail_recid_seq'::regclass);


--
-- TOC entry 3377 (class 2604 OID 59297)
-- Name: tbs_entity recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_entity ALTER COLUMN recid SET DEFAULT nextval('public.tbs_entity_recid_seq'::regclass);


--
-- TOC entry 3381 (class 2604 OID 59298)
-- Name: tbs_entitytype recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_entitytype ALTER COLUMN recid SET DEFAULT nextval('public.tbs_entitytype_recid_seq'::regclass);


--
-- TOC entry 3432 (class 2604 OID 59299)
-- Name: tbs_inbox recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_inbox ALTER COLUMN recid SET DEFAULT nextval('public.tbs_inbox_recid_seq'::regclass);


--
-- TOC entry 3386 (class 2604 OID 59300)
-- Name: tbs_role recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_role ALTER COLUMN recid SET DEFAULT nextval('public.tbs_role_recid_seq'::regclass);


--
-- TOC entry 3334 (class 2604 OID 59301)
-- Name: tbs_user recid; Type: DEFAULT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_user ALTER COLUMN recid SET DEFAULT nextval('public.tbs_user_recid_seq'::regclass);


--
-- TOC entry 3758 (class 0 OID 58313)
-- Dependencies: 211
-- Data for Name: tb_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_category VALUES (1, 'fresh', 'FYO', '2017-08-08 09:14:51.455966', 'fresh.png', 1);
INSERT INTO public.tb_category VALUES (2, 'pasteries', 'PAS', '2017-08-24 01:08:17.002828', 'pastries.png', 1);
INSERT INTO public.tb_category VALUES (3, 'soft drinks', 'SOD', '2018-01-29 13:16:07.111625', 'soft.png', 1);
INSERT INTO public.tb_category VALUES (4, 'herbicide/weedicide', 'DRU', '2018-03-25 02:10:13.069565', 'herb.png', 2);
INSERT INTO public.tb_category VALUES (5, 'insecticide', 'MED', '2018-03-25 02:10:33.431606', 'insect.png', 2);
INSERT INTO public.tb_category VALUES (6, 'fungicide', 'FAS', '2018-03-25 02:11:39.781491', 'fung.png', 2);
INSERT INTO public.tb_category VALUES (7, 'fertilizer', 'SEA', '2018-03-25 04:29:40.741371', 'fert.png', 2);
INSERT INTO public.tb_category VALUES (8, 'seed', 'STE', '2018-03-25 04:30:22.558884', 'sample.png', 2);
INSERT INTO public.tb_category VALUES (11, 'tools and equipment', 'TOL', '2018-04-06 01:10:04.478351', 'tool.png', 2);
INSERT INTO public.tb_category VALUES (9, 'seed dressing agrochemical', 'SED', '2018-04-06 01:09:27.988355', 'sample.png', 2);
INSERT INTO public.tb_category VALUES (10, 'storage agrochemicals', 'STO', '2018-04-06 01:09:40.869969', 'sample.png', 2);
INSERT INTO public.tb_category VALUES (0, 'N/A', 'NA', '2019-05-24 18:45:02.777855', NULL, 2);
INSERT INTO public.tb_category VALUES (12, 'gffhf', NULL, '2019-06-25 07:58:32.96947', NULL, NULL);
INSERT INTO public.tb_category VALUES (13, 'gfgff', NULL, '2019-06-25 07:59:45.174334', NULL, 2);
INSERT INTO public.tb_category VALUES (14, 'hjdhkd', NULL, '2019-06-25 09:31:57.208969', NULL, 2);
INSERT INTO public.tb_category VALUES (15, 'allen', NULL, '2019-06-25 09:33:41.554864', NULL, 2);
INSERT INTO public.tb_category VALUES (16, 'allen', NULL, '2019-06-25 12:29:30.60137', NULL, 2);
INSERT INTO public.tb_category VALUES (17, 'ljkjkjkjkj', NULL, '2019-06-26 01:35:20.091452', NULL, 2);
INSERT INTO public.tb_category VALUES (18, 'hghsgds', NULL, '2019-06-26 01:37:39.987206', NULL, 2);
INSERT INTO public.tb_category VALUES (19, 'sdsdsd', NULL, '2019-06-26 01:41:55.672284', NULL, 2);
INSERT INTO public.tb_category VALUES (20, 'nbnbncb', NULL, '2019-06-27 02:10:35.108458', NULL, 2);


--
-- TOC entry 3775 (class 0 OID 58586)
-- Dependencies: 244
-- Data for Name: tb_country; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_country VALUES (1, 'Ghana', 'GH', 1, '2016-03-07 18:28:19.553292');
INSERT INTO public.tb_country VALUES (2, 'Canada', 'CA', 1, '2017-05-28 11:56:34.955942');
INSERT INTO public.tb_country VALUES (3, 'United States of America', 'USA', 1, '2017-05-28 11:56:56.697337');


--
-- TOC entry 3761 (class 0 OID 58336)
-- Dependencies: 214
-- Data for Name: tb_currency; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_currency VALUES (1, 'Ghana Cedis', 'GHC', 1, '2017-05-20 16:30:36.309731');
INSERT INTO public.tb_currency VALUES (2, 'US Dollar', 'USD', 1, '2017-05-20 16:30:54.448898');


--
-- TOC entry 3778 (class 0 OID 58596)
-- Dependencies: 247
-- Data for Name: tb_district; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_district VALUES (21, 'Wa East', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (23, 'Lawra', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (64, 'Lambussie-Karni', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (71, 'Sissala West', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (4, 'Dormaa Municipal', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (10, 'Dormaa East', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (11, 'Asutifi North', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (31, 'Wenchi', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (50, 'Sunyani West', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (60, 'Asutifi South', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (65, 'Sene East', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (75, 'Jaman South', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (150, 'Sunyani Municipal', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (3, 'Talensi', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (12, 'Bawku West', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (46, 'Builsa South', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (52, 'Pusiga', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (53, 'Kassena/Nankana West', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (40, 'Assin South', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (2, 'Ningo-Prampram', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (6, 'Ayawaso', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (25, 'Adentan', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (30, 'Ledzokuku Krowor', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (48, 'Osu Clottey', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (68, 'Ada East', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (9, 'Tolon', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (15, 'Bole', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (24, 'Central Gonja', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (26, 'West Mamprusi', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (7, 'Sefwi Akontombra', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (18, 'Essikadu-Ketan Sub', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (19, 'Wassa Amenfi East', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (20, 'Wassa East', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (5, 'Subin', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (8, 'Asante Akim North', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (16, 'Bekwai Municipal', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (17, 'Mampong Municpal', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (35, 'Ejisu Juaben Municipal', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (36, 'Atwima Nwabiagya', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (41, 'Sekyere Afram Plains', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (55, 'Oforikrom', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (59, 'Afigya Kwabre', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (62, 'Sekyere East', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (73, 'Atwima Mponua', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (13, 'Denkyembuo', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (32, 'Upper West Akim', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (34, 'Akwapim North', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (37, 'East Akim', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (44, 'Kwahu West Municipality', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (47, 'Suhum', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (58, 'Afram Plains South', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (61, 'New Juaben Municipality', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (63, 'Asuogyaman', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (67, 'Yilo Krobo', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (69, 'Fanteakwa', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (74, 'Lower Manya Krobo', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (33, 'Sagnarigu', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (43, 'Chereponi', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (45, 'Karaga', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (57, 'Tamale', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (70, 'East Gonja', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (72, 'North Gonja', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (76, 'Wa Municipal', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (87, 'Wa West', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (143, 'Sissala East', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (84, 'Atebubu/ Amantin', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (96, 'Tano North', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (101, 'Asunafo North', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (106, 'Nkoranza North', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (113, 'Techiman North', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (124, 'Tain', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (130, 'Nkoranza South', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (142, 'Techiman Municipal', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (79, 'Bolga', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (104, 'Ellembele', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (108, 'Bia West District', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (118, 'Aowin', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (120, 'Effia-Kwesimintsim Sub', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (133, 'Mpohor', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (81, 'Kwabre East', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (85, 'Bosome Freho', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (103, 'Asante Akim Central Municipality', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (116, 'Ahafo Ano North', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (121, 'Offinso Municipal', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (125, 'Bantama', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (127, 'Asante Akim South', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (132, 'Old Tafo', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (88, 'Afram Plains North', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (93, 'Upper Manya Krobo', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (109, 'Atiwa', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (123, 'Ayensuano', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (128, 'Birim South', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (140, 'Kwaebibirem', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (146, 'Nsawam/Adoagyiri', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (86, 'Bawku Municipal', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (107, 'Garu-Tempane', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (112, 'Builsa  North', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (78, 'Ekumfi', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (82, 'Abura/Asebu/Kwamankese', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (90, 'Asikuma Odoben Brakwa', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (91, 'Gomoa West', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (97, 'Agona West', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (102, 'Awutu Senya West', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (119, 'Effutu', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (129, 'Twifo Atti Morkwaa', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (77, 'Ada West', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (95, 'Ga East', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (100, 'Tema', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (110, 'Ashaiman', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (131, 'Okaikwei', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (139, 'La', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (147, 'Ga Central', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (80, 'Yendi', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (89, 'Mion', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (94, 'Zabzugu', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (98, 'Nanumba North', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (99, 'Kumbungu', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (105, 'East Mamprusi', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (115, 'Tatale/Sanguli', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (122, 'Savelugu/Nanton', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (141, 'West Gonja', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (144, 'Kpandai', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (145, 'Mamprugu/Moagduri', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (161, 'Nadowli/Kaleo', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (171, 'Nandom', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (172, 'Jirapa', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (206, 'Daffiama/Bussie/Issa', 8, NULL, 1, '2015-04-03 11:15:57.560092');
INSERT INTO public.tb_district VALUES (158, 'Jaman North', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (164, 'Tano South', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (190, 'Banda', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (195, 'Dormaa West', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (196, 'Kintampo South', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (198, 'Sene West', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (202, 'Kintampo North', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (223, 'Berekum Municipal', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (151, 'Ho West', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (157, 'Kassena/Nankana East', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (170, 'Nabdam', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (183, 'Bongo', 7, NULL, 1, '2015-04-03 11:18:06.713624');
INSERT INTO public.tb_district VALUES (136, 'Komenda/Edina/Eguafo/Abrem', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (155, 'Assin North', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (159, 'Hemang Lower Denkyira', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (174, 'Upper Denkyira West', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (186, 'Mfansteman', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (199, 'Ajumako Enyan Esiam', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (217, 'Upper Denkyira East', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (221, 'Cape Coast', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (225, 'Agona East', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (226, 'Gomoa East', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (160, 'Juaboso', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (167, 'Wassa Amenfi West', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (177, 'Tarkwa Nsuaem', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (180, 'Sefwi Wiawso', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (207, 'Shama', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (211, 'Suaman', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (218, 'Ahanta West', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (154, 'Asokore Mampong', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (156, 'Suame', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (165, 'Asokwa', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (166, 'Bosomtwe', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (175, 'Adansi South', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (176, 'Sekyere Kumawu', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (179, 'Nhyiaeeso', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (188, 'Ejura Sekyedumase', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (189, 'Manhyia', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (152, 'West Akim Municipality', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (173, 'Birim Central', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (178, 'Kwahu East', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (197, 'Kwahu South', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (200, 'Akuapem South', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (214, 'Akyemansa', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (215, 'Birim North', 4, NULL, 1, '2015-04-03 11:14:27.596786');
INSERT INTO public.tb_district VALUES (163, 'Kpone Katamanso', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (184, 'Shai-Osudoku', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (187, 'Ga South', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (193, 'La - Nkwantanang / Madina Municipality', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (203, 'Ashiedu Keteke', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (220, 'Ga-West', 5, NULL, 1, '2015-04-03 11:18:26.93544');
INSERT INTO public.tb_district VALUES (162, 'Bunkpurugu/Yunyoo', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (168, 'Saboba', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (181, 'Sawla/Tuna/Kalba', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (205, 'Gushegu', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (216, 'Nanumba South', 6, NULL, 1, '2015-04-03 11:18:33.334078');
INSERT INTO public.tb_district VALUES (228, 'Pru', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (1, 'Asunafo South', 2, NULL, 1, '2015-04-03 11:16:02.66693');
INSERT INTO public.tb_district VALUES (22, 'Jomoro', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (27, 'Bia East District', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (29, 'Sekondi Sub', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (39, 'Takoradi Sub', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (49, 'Bibiani-Anhwiaso-Bekwai', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (51, 'Wassa Amenfi Central', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (56, 'Prestea/Huni-Valley', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (66, 'Nzema East Municipality', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (230, 'Bodi', 10, NULL, 1, '2015-04-03 11:13:49.714384');
INSERT INTO public.tb_district VALUES (138, 'Ahafo Ano South', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (148, 'Obuasi Municipal (Obuasi)', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (191, 'Sekyere South', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (201, 'Kwadaso', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (204, 'Amansie West', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (208, 'Amansie Central', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (210, 'Offinso North', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (212, 'Sekyere Central', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (213, 'Adansi North', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (224, 'Atwima Kwanwoma', 1, NULL, 1, '2015-04-03 11:13:58.52312');
INSERT INTO public.tb_district VALUES (14, 'Krachi West', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (28, 'Nkwanta South', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (38, 'Hohoe Municipal', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (42, 'Kadjebi', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (54, 'South Tongu', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (83, 'South Dayi', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (92, 'Ketu South', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (111, 'Krachi East', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (114, 'Adaklu', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (117, 'Agotime - Ziope', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (126, 'Ho Municipal', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (134, 'Keta', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (135, 'Nkwanta North', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (137, 'North Dayi', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (149, 'Ketu North', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (153, 'Afadjato South', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (169, 'Kpando Municipality', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (182, 'Krachi-Nchumuru', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (185, 'Akatsi North', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (192, 'Central Tongu', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (194, 'Akatsi South', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (219, 'Jasikan', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (222, 'North Tongu', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (229, 'Biakoye', 9, NULL, 1, '2015-04-03 11:17:00.468983');
INSERT INTO public.tb_district VALUES (227, 'Awutu Senya East', 3, NULL, 1, '2015-04-03 11:18:12.230316');
INSERT INTO public.tb_district VALUES (209, 'Ablekuma', 5, NULL, 1, '2015-04-03 11:18:26.93544');


--
-- TOC entry 3780 (class 0 OID 58605)
-- Dependencies: 249
-- Data for Name: tb_education; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_education VALUES (1, 'Tertiary', 1, '2016-03-19 16:48:56.320225');


--
-- TOC entry 3781 (class 0 OID 58612)
-- Dependencies: 250
-- Data for Name: tb_emprank; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_emprank VALUES (1, 'Senior Technician', 'Snr', 1, '2016-03-19 22:05:29.589481');


--
-- TOC entry 3782 (class 0 OID 58620)
-- Dependencies: 251
-- Data for Name: tb_empstatus; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_empstatus VALUES (1, 'Salaried', 1, '2016-03-19 18:47:58.231093');


--
-- TOC entry 3762 (class 0 OID 58342)
-- Dependencies: 215
-- Data for Name: tb_enquiry; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_enquiry VALUES (3, 'Toyota', 'Frank', '0008', '997', 'tdt', '2017-05-21', '2017-05-21', 1, 1, 1, '2017-05-21 17:17:51.603036', '2017-05-21 17:17:51.603036', 2);
INSERT INTO public.tb_enquiry VALUES (4, 'Allen', 'FGg', '0989', '898', '998', NULL, NULL, 1, 2, 1, '2017-05-24 11:32:08.39803', '2017-05-24 11:32:08.39803', 2);
INSERT INTO public.tb_enquiry VALUES (5, 'Total', 'Tehj', '89', '23', '21', NULL, NULL, 1, 2, 1, '2017-05-24 11:32:34.785906', '2017-05-24 11:32:34.785906', 2);
INSERT INTO public.tb_enquiry VALUES (7, 'Tarkwa', 'chi', 'tow', '6576', '322', NULL, NULL, 1, 2, 1, '2017-05-24 11:33:49.234471', '2017-05-24 11:33:49.234471', 2);
INSERT INTO public.tb_enquiry VALUES (1, 'DMS', 'Eric', '005', '006', 'test', '2017-05-19', '2017-05-19', 1, 1, 1, '2017-05-20 16:32:25.171044', '2017-05-20 16:32:25.171044', 3);
INSERT INTO public.tb_enquiry VALUES (2, 'Donaldson', 'Allen', '089', '879', 'TFT', '2017-05-20', '2017-05-20', 1, 2, 1, '2017-05-21 03:08:39.563619', '2017-05-21 03:08:39.563619', 3);
INSERT INTO public.tb_enquiry VALUES (6, 'Shell', 'sh', '8965', '5667', '54', NULL, NULL, 1, 1, 1, '2017-05-24 11:33:12.272465', '2017-05-24 11:33:12.272465', 3);
INSERT INTO public.tb_enquiry VALUES (8, 'Chirano', 'th', 'jkj', '434', '23', NULL, NULL, 1, 1, 1, '2017-05-24 11:34:19.265561', '2017-05-24 11:34:19.265561', 3);


--
-- TOC entry 3784 (class 0 OID 58629)
-- Dependencies: 253
-- Data for Name: tb_idtype; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_idtype VALUES (1, 'NHIS', 'NHIS', 1, '2016-03-25 07:22:24.541977');
INSERT INTO public.tb_idtype VALUES (2, 'Voter ID Show', 'Voter', 1, '2016-04-02 04:49:19.405046');


--
-- TOC entry 3764 (class 0 OID 58364)
-- Dependencies: 218
-- Data for Name: tb_issues; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_issues VALUES (1, 187, 'The buyer returned', 1, '2017-08-30 17:01:46.201', '2017-08-30 17:01:46.201', '2017-08-30', 3);
INSERT INTO public.tb_issues VALUES (2, 134, '1 was mistankenly sold in place of IF3500. Upon update IF3300 will be 0 and IF3500 will 4 since its quantity now is 5', 1, '2017-09-05 14:07:31.263', '2017-09-05 14:07:31.263', '2017-09-05', 3);


--
-- TOC entry 3751 (class 0 OID 58223)
-- Dependencies: 199
-- Data for Name: tb_member; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_member VALUES (1, 'mxn', 'test', 'test', '30-02-2018', '0277686939', '0277686939', 'test', '0277686939', 'text', 'test', 2, 'sample.png', 1, '2018-03-18 01:24:56.510816', 1);
INSERT INTO public.tb_member VALUES (2, 'FM00002', 'allen', 'eben', '2018-03-14', '888888888', '888888888', '8888888888', '8888888888', '8998998899', '2018-03-18', 3, 'sample.png', 1, '2018-03-18 01:34:23.752618', 1);
INSERT INTO public.tb_member VALUES (5, 'FM00005', 'v', 'v', '2018-12-31', 'yu', 'yu', 'yu', 'yu', 'yu', '2018-03-18', 3, 'sample.png', 1, '2018-03-18 01:48:42.998602', 1);
INSERT INTO public.tb_member VALUES (9, 'FM00009', 'jkjj', 'kjkjkj', '2018-12-31', 'hjhhjh', 'jhjhjhj', 'jhjhjh', 'jhjhjhjh', 'jhhjhjh', '2018-03-18', 3, 'sample.png', 1, '2018-03-18 01:59:54.789001', 1);
INSERT INTO public.tb_member VALUES (10, 'FM00010', 'Curry', 'Steph', '2018-03-18', '865', 'Jgksj', 'Hshs', 'Jsjs7', 'Hshbs', '2018-03-18', 3, 'sample.png', 1, '2018-03-18 03:31:24.014045', 1);
INSERT INTO public.tb_member VALUES (11, 'FM00011', 'Ab', 'As', '2018-03-24', '02568838', '638848', 'Ama', '97636', 'Amahbd', '2018-03-24', 3, 'sample.png', 1, '2018-03-24 11:41:12.476141', 1);
INSERT INTO public.tb_member VALUES (12, 'FM00012', 'Ag', 'Hsh', '2018-03-26', '634', '363y', '374', '373u3', 'Ueye', '2018-03-26', 3, 'sample.png', 1, '2018-03-26 10:11:48.470166', 1);
INSERT INTO public.tb_member VALUES (13, 'FM0001359', 'allen', 'eben', '2018-12-31', '0234567', '67766', 'kojo', '987767776', 'gfhgfhgs', '2018-12-23', 6, 'sample.png', 1, '2018-12-23 05:07:00.352533', 1);
INSERT INTO public.tb_member VALUES (14, 'FM0001456', 'kwaku', 'Mojo', '2018-12-31', '87654', '56789', 'kwajo', '98765', 'ghkl', '2018-12-23', 6, 'sample.png', 1, '2018-12-23 05:08:02.942839', 1);
INSERT INTO public.tb_member VALUES (15, 'FM0001553', 'yuy', 'uyy', '2018-12-31', '88787878', '87878787', '7878787', '87878787', '78787878', '2018-12-23', 6, 'sample.png', 1, '2018-12-23 05:14:06.510316', 1);
INSERT INTO public.tb_member VALUES (16, 'FM0001650', 'bnvn', 'nm', '2018-12-31', '5678', '6766', 'ghg', '565765', 'vdfdghshsh', '2019-01-22', 6, 'sample.png', 1, '2019-01-22 16:45:22.438788', 1);
INSERT INTO public.tb_member VALUES (17, 'FM0001747', 'allen', 'eben', NULL, '027768587', NULL, 'allen', '0245777', 'house', '2019-04-03', 6, 'sample.png', 1, '2019-04-03 21:44:36.030277', 1);
INSERT INTO public.tb_member VALUES (18, 'FM0001844', 'allen', 'eben', NULL, '027768587', NULL, 'allen', '0245777', 'house', '2019-04-03', 6, 'sample.png', 1, '2019-04-03 21:44:41.198091', 1);
INSERT INTO public.tb_member VALUES (19, 'FM01941', 'allen', 'eben', NULL, '027768587', NULL, 'allen', '0245777', 'house', '2019-04-03', 6, 'sample.png', 1, '2019-04-03 21:46:48.460032', 1);
INSERT INTO public.tb_member VALUES (20, 'FM02038', 'kwe', 'kwe', NULL, '0676766', NULL, 'kwe', '0888787', 'house', '2019-04-03', 6, 'sample.png', 1, '2019-04-03 21:48:36.599799', 1);
INSERT INTO public.tb_member VALUES (21, 'FM02135', 'Sambo', 'Susana', NULL, '0551200917', NULL, 'titus todeme', '0262922617', 'Mk 31/a', '2019-04-06', 6, 'sample.png', 1, '2019-04-06 14:51:53.294291', 1);


--
-- TOC entry 3765 (class 0 OID 58402)
-- Dependencies: 223
-- Data for Name: tb_moneypaid; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_moneypaid VALUES (2, 'Kodjo', 89.8900000000000006, 'PV0000292', 1, '2018-02-24 08:21:58.075864', '2018-02-24 08:21:58.075864', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (1, 'Allen', 567, 'Test', 1, '2018-02-24 08:21:11.401842', '2018-02-24 08:21:11.401842', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (3, 'yohjhh', 987, 'PV0000389', 1, '2018-02-24 08:23:21.833909', '2018-02-24 08:23:21.833909', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (4, 'alonso', 89.7800000000000011, 'PV0000486', 1, '2018-02-24 08:25:23.967802', '2018-02-24 08:25:23.967802', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (5, 'sedinam', 45.8900000000000006, 'PV0000583', 1, '2018-02-24 08:27:44.600775', '2018-02-24 08:27:44.600775', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (6, 'al', 987, 'PV0000680', 1, '2018-02-24 08:28:28.423908', '2018-02-24 08:28:28.423908', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (7, 'allen', 898, 'PV0000777', 1, '2018-02-24 08:28:45.413766', '2018-02-24 08:28:45.413766', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (8, 'assd', 7676, 'PV0000874', 1, '2018-02-24 08:32:26.945855', '2018-02-24 08:32:26.945855', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (9, 'allrfg', 6576, 'PV0000971', 1, '2018-02-24 08:32:54.83231', '2018-02-24 08:32:54.83231', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (10, 'v', 45, 'PV0001068', 1, '2018-02-24 09:01:55.944349', '2018-02-24 09:01:55.944349', '2018-02-24', 3);
INSERT INTO public.tb_moneypaid VALUES (11, 'Kwadjo', 365.985000000000014, 'PV0001165', 1, '2018-02-24 13:52:33.1496', '2018-02-24 13:52:33.1496', '2018-02-24', 4);
INSERT INTO public.tb_moneypaid VALUES (12, 'Ama', 500, 'PV0001262', 1, '2018-02-26 11:40:04.192483', '2018-02-26 11:40:04.192483', '2018-02-26', 3);
INSERT INTO public.tb_moneypaid VALUES (13, 'Ama-manager', 580, 'PV0001359', 1, '2018-02-26 11:41:52.778825', '2018-02-26 11:41:52.778825', '2018-02-26', 3);
INSERT INTO public.tb_moneypaid VALUES (14, 'allen', 4535, 'PV0001456', 1, '2018-03-03 10:45:03.332242', '2018-03-03 10:45:03.332242', '2018-03-03', 3);
INSERT INTO public.tb_moneypaid VALUES (15, 'alle', 87, 'PV0001553', 1, '2018-03-03 10:46:30.328949', '2018-03-03 10:46:30.328949', '2018-03-03', 3);
INSERT INTO public.tb_moneypaid VALUES (16, 'Allen', 500, 'PV0001650', 1, '2018-03-05 19:23:52.619722', '2018-03-05 19:23:52.619722', '2018-03-05', 3);
INSERT INTO public.tb_moneypaid VALUES (17, 'Dean', 200, 'PV0001747', 1, '2018-03-05 19:35:00.924252', '2018-03-05 19:35:00.924252', '2018-03-05', 3);
INSERT INTO public.tb_moneypaid VALUES (18, 'Allen', 250, 'PV0001844', 1, '2018-03-06 05:52:27.848944', '2018-03-06 05:52:27.848944', '2018-03-06', 3);
INSERT INTO public.tb_moneypaid VALUES (19, 'Allen', 23, 'PV0001941', 1, '2018-03-17 01:24:02.117975', '2018-03-17 01:24:02.117975', '2018-03-17', 3);
INSERT INTO public.tb_moneypaid VALUES (20, 'Ajh', 8289, 'PV0002038', 1, '2018-03-18 02:15:48.725819', '2018-03-18 02:15:48.725819', '2018-03-18', 3);
INSERT INTO public.tb_moneypaid VALUES (21, 'Test', 69.7999999999999972, 'PV0002135', 1, '2018-03-18 02:19:29.054634', '2018-03-18 02:19:29.054634', '2018-03-18', 3);
INSERT INTO public.tb_moneypaid VALUES (22, 'Bv', 6549, 'PV0002232', 1, '2018-03-18 02:19:51.153978', '2018-03-18 02:19:51.153978', '2018-03-18', 3);
INSERT INTO public.tb_moneypaid VALUES (23, 'Allen', 250, 'PV0002329', 1, '2018-04-06 08:56:53.011867', '2018-04-06 08:56:53.011867', '2018-04-06', 3);
INSERT INTO public.tb_moneypaid VALUES (24, 'allen', 500, 'PV0002426', 1, '2018-07-27 11:10:29.073893', '2018-07-27 11:10:29.073893', '2018-07-27', 3);
INSERT INTO public.tb_moneypaid VALUES (25, 'bn', 900, 'PV0002523', 1, '2018-09-12 10:48:28.776074', '2018-09-12 10:48:28.776074', '2018-09-12', 3);
INSERT INTO public.tb_moneypaid VALUES (26, 'allen', 20, 'PV0002620', 1, '2018-11-18 22:13:17.469681', '2018-11-18 22:13:17.469681', '2018-11-18', 3);
INSERT INTO public.tb_moneypaid VALUES (27, 'dfgg', 456, 'PV0002717', 1, '2019-01-22 16:38:47.006215', '2019-01-22 16:38:47.006215', '2019-01-22', 6);


--
-- TOC entry 3788 (class 0 OID 58641)
-- Dependencies: 257
-- Data for Name: tb_officeheld; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_officeheld VALUES (1, 'Secretary', 1, '2016-03-19 17:49:22.387216');
INSERT INTO public.tb_officeheld VALUES (2, 'Treasurer', 1, '2016-03-27 16:30:56.55076');


--
-- TOC entry 3752 (class 0 OID 58233)
-- Dependencies: 200
-- Data for Name: tb_paymenttype; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_paymenttype VALUES (1, 'Cash', 'CS', 1, '2018-12-23 02:45:38.002989');
INSERT INTO public.tb_paymenttype VALUES (2, 'Credit', 'CR', 1, '2018-12-23 02:45:46.293727');
INSERT INTO public.tb_paymenttype VALUES (3, 'Partial', 'PR', 1, '2018-12-23 02:45:57.438956');


--
-- TOC entry 3753 (class 0 OID 58239)
-- Dependencies: 201
-- Data for Name: tb_product; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_product VALUES (174, 'Tomatoes', '', 0, 80, 8, 3, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-05-26 17:25:32.080227', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (43, 'Kalach Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (57, 'MesheNwura Lt', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (155, 'NPK (15:15:15) Paint x 5', '', 12, 20, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 5, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (75, 'Nwurawura b/s 5Lt x 4', '', 70, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 69, 4, 65, 0, 1, 0);
INSERT INTO public.tb_product VALUES (93, 'Bisorice 200ml x 40', '', 42, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 4, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (83, 'Herbxtra Lt x 12', '', 20, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 19.8000000000000007, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (104, 'K-Optimal b/s Lt x 12', '', 30, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 29, 12, 28.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (29, 'Bextra Bx', '', 0, -508, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:18:05.731888', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (61, 'Paracort Lt x 12', '', 20, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 19.5, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (125, 'Saviour 20% 250ml x 40', '', 30, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (157, 'Sidalco 250ml s/s x 15', '', 6, 20, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 15, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (159, 'Sulpher 80 100g x 100', '', 3, 20, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (91, 'Sun Atrazine b/s (Powder) Kg x 10', '', 22, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 21.8999999999999986, 10, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (71, 'Sunphosate Lt x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (151, 'Urea W. 50kg', '', 1.5, 20, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 1, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (76, 'Nwurawurab/s Bx', '', 0, 18, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 14:45:41.877917', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (154, 'NPK (15:15:15) 50kg bag', '', 100, 14, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 68, 1, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (1, '1 Litre', '', 1.5, 20, 1, 2, 'fresh.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2018-03-17 01:24:25.345811', '2017-08-01', 0, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, 1, 0);
INSERT INTO public.tb_product VALUES (158, 'Sino Booster Lt x 12', '', 35, 18, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 14:49:11.054033', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (5, 'Meat Pie', '', 5, 29, 2, 3, 'pastries.png', '', 1, 1, '2017-08-31 12:24:54.64806', '2018-11-13 12:54:16.144119', '2017-10-20', 0, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, 1, 0);
INSERT INTO public.tb_product VALUES (2, 'Pancake', '', 2, 36, 2, 2, 'pastries.png', '', 1, 1, '2017-08-31 12:24:46.641665', '2018-08-16 15:01:14.445713', '2017-08-01', 0, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, 1, 0);
INSERT INTO public.tb_product VALUES (156, 'NPK (19 19 19) kg x 20', '', 12, 14, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 14:54:01.991688', '2017-08-01', 0, 0, 0, '', '', 20, 0, 20, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (152, 'SOA 50kg Bag', '', 75, 17, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 0, 1, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (24, 'Adwumawura Bx', '', 0, 11, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (146, 'Asasa Aban 2Lt', '', 18, 0, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-03 19:51:54.966097', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (42, 'Kalach Lt x 12', '', 14.5, 17, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (128, 'Aceta star Lt x 12', '', 50, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2018-04-06 09:51:13.077759', '2017-08-01', 0, 0, 0, '', '', 20, 49.5, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (22, 'Adom Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (23, 'Adom Lt x 12', '', 15, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (20, 'Aboboyaa Bx', '', 70, 13, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 13:48:27.006545', '2017-08-01', 0, 0, 0, '', '', 20, 69, 4, 65, 0, 1, 0);
INSERT INTO public.tb_product VALUES (135, 'Suncozeb 1kg x 10', '', 22, 20, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 21.8000000000000007, 10, 21.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (114, 'Sunhalothrine b/s Lt x 12', '', 16, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (41, 'Glycot Lt x 12', '', 14.5, 16, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-03 20:01:00.951474', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (90, 'Aligator Lt x 12', '', 30, 17, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 13:48:27.006545', '2017-08-01', 0, 0, 0, '', '', 20, 30, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (52, 'kwodwooto Lt x 12', '', 14.5, 15, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 14:59:08.640742', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (55, 'Mega super 200ml x 60', '', 35, 18, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 34.5, 60, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (101, 'Consider b/s Lt x 12', '', 50, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 59.5, 12, 57.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (102, 'Consider s/s 250ml x 40', '', 15, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.5, 40, 13, 0, 1, 0);
INSERT INTO public.tb_product VALUES (103, 'K-Optimal s/s 250ml x 40', '', 10, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 9.5, 40, 9, 0, 1, 0);
INSERT INTO public.tb_product VALUES (25, 'Adwumawura Lt x 12', '', 15, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (26, 'Atrazine (Liquid) Lt x 12', '', 18, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (27, 'Batrazine b/s (Powder) Kg x 10', '', 22, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 21.5, 10, 20.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (48, 'Kabasate s/s Lt x 12', '', 14.5, 17, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 14:59:08.640742', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (45, 'Kabasate b/s Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (62, 'Paracot Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (44, 'Kabaherb Lt x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (36, 'Glyking BX', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (49, 'Kingkong Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (51, 'Kwodwooto Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (53, 'Landlord Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (58, 'Nwurawura Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (60, 'Orizo Plus Lt x 12', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (64, 'Pronil Plus Lt x 12', '', 28, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 27.5, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (65, 'Power Lt x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (66, 'Ridout Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (33, 'Forceup Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (31, 'Bonquat Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (30, 'Bextra Lt x 12', '', 20, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 19.5, 12, 19, 0, 1, 0);
INSERT INTO public.tb_product VALUES (56, 'MesheNwura Lt X12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (38, 'Glyphader  Bx', '', 0, 19, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (40, 'Glycot Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (46, 'Kabasate b/s 5Lt x 4', '', 70, 11, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 68, 4, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (39, 'Glyphader  Lt x12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (32, 'Bonquat Lt x 12', '', 20, -0.0800000000000000017, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-06-23 02:40:34.289663', '2017-08-01', 0, 0, 0, '', '', 20, 19.5, 12, 17.5, 0, 1, -1);
INSERT INTO public.tb_product VALUES (3, 'Coca Cola', '', 1, 60, 3, 3, 'soft.png', '', 1, 1, '2017-08-31 12:24:46.662241', '2019-06-14 15:09:10.583917', '2017-08-01', 0, NULL, 69, NULL, NULL, 2, 5, 3, 6, 0, 1, 120);
INSERT INTO public.tb_product VALUES (34, 'Forceup Lt x 12', '', 14.5, 14, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:18:05.731888', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (47, 'Kabasate s/s Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (35, 'Glycot Bx', '', 0, 19, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:18:05.731888', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (50, 'Kingkong Lt x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (54, 'Landlord Lt x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (59, 'Nwurawura Lt x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (28, 'Batrazine s/s (Powder) 500g x 20', '', 11, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 10.8000000000000007, 20, 10.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (63, 'Paracot Lt x 12', '', 20, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 19.5, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (37, 'Glyking Lt  x 12', '', 14.5, 18, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-03 20:01:00.951474', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (81, 'Gramoquat Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (113, 'Sunhalothrine s/s 250ml x 40', '', 5, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (67, 'Ridout Lt x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (73, 'Tackle Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (69, 'Sinosate Lt  x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (80, 'Sun 2 4 D Lt x 12 ', '', 20, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 19.8000000000000007, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (74, 'Weedout Lt x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (78, 'Wynna Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (70, 'Sunphosate Bx', '', 0, 19, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2018-12-22 11:11:29.213578', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (111, 'Lambda s/s 250ml x 40', '', 6, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (84, 'Herbxtra Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (79, 'Sun 24D Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (112, 'Punto Lt x 12', '', 18, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (86, 'Nicoplus Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (92, 'Sun Atrazine s/s (Powder)100g x 100', '', 3, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 2.79999999999999982, 100, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (106, 'Bon-optimal s/s 250ml x 40', '', 10, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (107, 'Super Top  Lt x 12', '', 27, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (96, 'Attack (Liquid) 250ml x 40', '', 19, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 18.5, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (100, 'Confidor 200SL 30ml x 20', '', 10, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 9.5, 20, 8, 0, 1, 0);
INSERT INTO public.tb_product VALUES (95, 'Kum Wura s/s', '', 5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 4, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (109, 'Furadan x 10', '', 15, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14, 10, 13, 0, 1, 0);
INSERT INTO public.tb_product VALUES (68, 'Sharp Lt x 12', '', 14.5, 19, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (87, 'Nicobak Bx', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (98, 'Capizad 250ml x 40', '', 20, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 19.5, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (97, 'Attack (Powder) Sachet 30g x 193', '', 9, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 8.80000000000000071, 193, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (99, 'Condifor Lt x 12', '', 45, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 44.7999999999999972, 12, 43.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (115, 'Sunpyrifos b/s Lt x 12', '', 30, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 29.8000000000000007, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (105, 'Bon-optimal b/s Lt x 12', '', 29, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 28.5, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (72, 'Tackle Lt x 12', '', 14.5, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (77, 'Wynna Lt x 12', '', 15, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 14.1666666699999997, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (89, 'Sun Anico Lt x 12', '', 25, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 24.8000000000000007, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (82, 'Gramoquat Lt x 12', '', 20, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 19, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (94, 'Kum Wura m/s 500ml x 20', '', 9, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 9, 20, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (85, 'Nicoplus Lt x 12', '', 24, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 23.5, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (88, 'Nicobake Lt x 12', '', 23, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 23.8000000000000007, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (110, 'Lambada b/s Lt x 12', '', 16, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 15.8000000000000007, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (136, 'Top Cop Lt x 12', '', 27, 12, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 13:48:27.006545', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (161, 'Urea Paint x 5', '', 10, 20, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 5, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (149, 'NPK (20:10:5) 50kg bag', '', 100, 18, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 07:25:26.120002', '2017-08-01', 0, 0, 0, '', '', 20, 0, 1, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (153, 'SOA paint x 5', '', 9, 20, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 5, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (119, 'Sun Lambda b/s Lt x 12', '', 16, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (138, 'Viper 46 250ml x 48', '', 30, 20, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 48, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (134, 'Kabazeb 500g x 20', '', 12, 20, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 11.8000000000000007, 20, 11.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (140, 'Kumazeb m/s 500g x 20', '', 12, 20, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 11.8000000000000007, 20, 11.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (116, 'Sunpyrifos s/s 250ml x 40', '', 9, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 8.80000000000000071, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (120, 'Sun Lambda s/s 250ml x 40', '', 5, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (108, 'Akate Aduro Lt x 12', '', 35, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2018-04-06 09:51:13.077759', '2017-08-01', 0, 0, 0, '', '', 20, 34.5, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (137, 'Topson M (500g) x 20', '', 14, 20, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 13.8000000000000007, 20, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (124, 'Buffalo super Lt x 12', '', 45, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (123, 'Condor m/s 250ml x 40', '', 15, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 40, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (132, 'Fokozeb 80g x 100', '', 5, 17, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 0, 100, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (145, 'Asasa Aban 1Lt', '', 12, 0, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-03 20:40:28.213681', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (117, 'Adepa Lt x 12', '', 90, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (150, 'NPK (20:10:5) Paint x 5', '', 12, 17, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 07:39:59.863284', '2017-08-01', 0, 0, 0, '', '', 20, 0, 5, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (160, 'Urea 50kg bag', '', 90, 20, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 63, 1, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (141, 'Kumazeb s/s 80g x 100', '', 3, 20, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 100, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (139, 'Kumazeb b/s kg x 10', '', 22, 20, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 21.8000000000000007, 10, 21.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (163, 'Plant feed 2Lt', '', 18, 15, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 13:50:29.601425', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (118, 'Erodicoat Lt x 12', '', 90, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (143, 'Agyenkwa Lt x 12', '', 18, -67, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-01-22 16:33:10.909685', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (122, 'Goalan s/s 100ml x 100', '', 18, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 100, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (126, 'Mash s/s x 100', '', 6, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (121, 'Goalan b/s 200SL 250ml x 48', '', 43.5, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 43, 48, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (133, 'Kabazeb 1kg x 10', '', 22, 20, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 10, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (127, 'Nopest s/s x 100', '', 6, 20, 5, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (144, 'Asasa Aban 1/2lt', '', 7, -3, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-03 23:45:07.911569', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (162, 'Plant Feed 5Lt gallon x 4', '', 60, 20, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 4, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (167, 'Number One (cocoa) Lt x 12', '', 32, 19, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:25:42.223618', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (129, 'Bencon 800sc (Powder) kg x 10', '', 22, 20, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2018-04-19 05:51:46.384859', '2017-08-01', 0, 0, 0, '', '', 20, 21.8000000000000007, 10, 21.5, 0, 1, 0);
INSERT INTO public.tb_product VALUES (178, 'Bextoxin', '', 17, 20, 10, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (176, 'Onion', '', 1.5, 20, 8, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (173, 'Cabbage', '', 1.5, 20, 8, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (175, 'Pepper', '', 1.5, 20, 8, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (183, 'Poly 16 Sprayer x 1', '', 250, 20, 11, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 1, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (182, 'Sunshine Knapsack Sprayer x 1', '', 62, 20, 11, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 1, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (172, 'Watermelon b/s', '', 1.5, 20, 8, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (169, 'Agyenkwa Lt x 12', '', 18, -2, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-03 19:51:54.966097', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (171, 'Watermelon s/s', '', 1.5, 20, 8, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (130, 'Benco 500g x 20', '', 12, 18, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 13:48:27.006545', '2017-08-01', 0, 0, 0, '', '', 20, 0, 20, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (142, 'Agyenkwa  5Lt Gal x 4', '', 18, -2, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-01-22 16:19:41.575689', '2017-08-01', 0, 0, 0, '', '', 20, 0, 4, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (131, 'Fokozeb 500g x 20', '', 12, 12, 6, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 13:48:27.006545', '2017-08-01', 0, 0, 0, '', '', 20, 0, 20, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (165, 'Plant Feed 0.5 Lt', '', 7, 8, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 13:50:29.601425', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (166, 'Cocoa Wura Lt x 12', '', 32, 16, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:10:54.276116', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (168, 'Agyenkwa 5Lt x 4', '', 60, -3, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-01-22 16:19:41.575689', '2017-08-01', 0, 0, 0, '', '', 20, 0, 4, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (164, 'Plant Feed 1Lt', '', 12, 18, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-01-22 16:51:27.141557', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (181, 'Awuma Knapsack x 1', '', 62, 20, 11, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 1, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (180, 'Cuttlas ΓÇô crocodile x 60', '', 1.5, 20, 11, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 60, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (179, 'Cuttlas ΓÇô Mob x 60', '', 1.5, 20, 11, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 60, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (177, 'Dress force', '', 1.5, 20, 9, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (170, 'Maize scht', '', 1.5, 20, 8, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2017-08-31 12:24:46.601008', '2017-08-01', 0, 0, 0, '', '', 20, 0, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (147, 'Asasa Aban Lt', '', 12, 16, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-04-06 15:10:54.276116', '2017-08-01', 0, 0, 30, '', '', 20, 2, 0, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (4, '0.5 Litre', '', 1.19999999999999996, 40, 1, 3, 'fresh.png', '', 1, 1, '2017-08-31 12:24:46.702851', '2019-06-14 15:04:53.454051', '2017-08-01', 0, NULL, 2, NULL, NULL, 2, 3, 2, 2, 0, 1, 40);
INSERT INTO public.tb_product VALUES (148, 'Boost Xtra Lt x 12', '', 35, -0.0800000000000000017, 7, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2019-06-14 16:43:30.060333', '2017-08-01', 0, 0, 0, '', '', 20, 0, 12, 0, 0, 1, -1);
INSERT INTO public.tb_product VALUES (21, 'Aboboyaa 5Lt x 4 ', '', 0, 20, 4, 2, 'sample.png', '', 1, 1, '2017-08-31 12:24:46.601008', '2018-04-06 08:36:24.318313', '2017-08-01', 0, 0, 0, '', '', 20, 0, 4, 0, 0, 1, 0);
INSERT INTO public.tb_product VALUES (589, 'test', NULL, 7, 6, 1, 3, 'sample.png', '2019-06-25', 1, 1, '2019-06-25 06:03:58.314863', '2019-06-25 06:03:58.314863', '2019-06-25', 0, NULL, 67, NULL, NULL, 20, 7, 7, 7, 0, 1, 42);
INSERT INTO public.tb_product VALUES (590, 'vb', NULL, 9, 8, 1, 3, 'sample.png', '2019-06-25', 1, 1, '2019-06-25 06:04:29.416203', '2019-06-25 06:04:29.416203', '2019-06-25', 0, NULL, 8, NULL, NULL, 20, 8, 8, 8, 1, 1, 64);
INSERT INTO public.tb_product VALUES (591, 't', NULL, 8, 8, 8, 3, 'sample.png', '2019-06-27', 1, 1, '2019-06-27 02:10:21.500977', '2019-06-27 02:10:21.500977', '2019-06-27', 0, NULL, 8, NULL, NULL, 20, 8, 8, 8, 0, 1, 64);
INSERT INTO public.tb_product VALUES (592, 'jhjh', NULL, 6, 6, 0, 3, 'sample.png', '2019-07-04', 1, 1, '2019-06-27 02:16:10.013844', '2019-06-27 02:16:10.013844', '2019-06-27', 0, NULL, 6, NULL, NULL, 20, 6, 6, 6, 0, 1, 36);


--
-- TOC entry 3767 (class 0 OID 58432)
-- Dependencies: 227
-- Data for Name: tb_productlog; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_productlog VALUES (2, 4, 5, 3, 3, NULL, 1, '2018-03-03 12:37:08.125106', '2018-03-03 12:37:08.125106', '2017-10-20', NULL, NULL, 2, -1);
INSERT INTO public.tb_productlog VALUES (4, 3, 3, 5.79999999999999982, 3, NULL, 1, '2018-03-03 12:38:23.162387', '2018-03-03 12:38:23.162387', '2017-10-20', NULL, NULL, 2, -1);
INSERT INTO public.tb_productlog VALUES (1, 5, 4, 22, 3, '', 1, '2017-10-20 10:28:13.843239', '2017-10-20 10:28:13.843239', '2017-10-20', NULL, NULL, 1, 3);
INSERT INTO public.tb_productlog VALUES (3, 2, 6, 3.89000000000000012, 3, NULL, 1, '2018-03-03 12:37:53.034887', '2018-03-03 12:37:53.034887', '2017-10-20', NULL, NULL, 1, 3);


--
-- TOC entry 3759 (class 0 OID 58320)
-- Dependencies: 212
-- Data for Name: tb_productstatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_productstatus VALUES (1, 'st', 'st', '2017-08-08 09:15:07.052725');


--
-- TOC entry 3794 (class 0 OID 58658)
-- Dependencies: 263
-- Data for Name: tb_profession; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_profession VALUES (1, 'Banker', 1, '2016-03-19 16:49:14.753896');


--
-- TOC entry 3763 (class 0 OID 58350)
-- Dependencies: 216
-- Data for Name: tb_quotationtype; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_quotationtype VALUES (1, 'STOCK', 'STK', 1, '2017-05-20 16:29:52.66084');


--
-- TOC entry 3797 (class 0 OID 58669)
-- Dependencies: 266
-- Data for Name: tb_region; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_region VALUES (1, 'Ashanti', 'AS', 1, '2015-04-07 05:36:25.214063');
INSERT INTO public.tb_region VALUES (2, 'Brong Ahafo', 'BR', 1, '2015-04-07 05:36:27.701354');
INSERT INTO public.tb_region VALUES (3, 'Central', 'CR', 1, '2015-04-07 05:36:31.186219');
INSERT INTO public.tb_region VALUES (4, 'Eastern', 'ER', 1, '2015-04-07 05:36:35.615517');
INSERT INTO public.tb_region VALUES (5, 'Greater Accra', 'GR', 1, '2015-04-07 05:36:39.097458');
INSERT INTO public.tb_region VALUES (6, 'Northern', 'NR', 1, '2015-04-07 05:36:43.374384');
INSERT INTO public.tb_region VALUES (7, 'Upper East', 'UE', 1, '2015-04-07 05:36:49.017676');
INSERT INTO public.tb_region VALUES (8, 'Upper West', 'UW', 1, '2015-04-07 05:36:53.224407');
INSERT INTO public.tb_region VALUES (9, 'Volta', 'VR', 1, '2015-04-07 05:37:04.083047');
INSERT INTO public.tb_region VALUES (10, 'Western', 'WR', 1, '2015-04-07 05:37:07.80147');
INSERT INTO public.tb_region VALUES (11, 'West Africa', 'WA', 1, '2015-04-07 05:37:19.561608');
INSERT INTO public.tb_region VALUES (12, 'Other', 'OR', 1, '2015-04-07 05:37:26.892521');


--
-- TOC entry 3799 (class 0 OID 58676)
-- Dependencies: 268
-- Data for Name: tb_relationship; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_relationship VALUES (1, 'Spouse', NULL, 1, '2016-03-20 08:14:52.94879');


--
-- TOC entry 3801 (class 0 OID 58686)
-- Dependencies: 270
-- Data for Name: tb_residenttype; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tb_residenttype VALUES (1, 'My', 'mh', 1, '2016-03-25 07:23:10.315741');
INSERT INTO public.tb_residenttype VALUES (2, 'Yours', 'yr', 1, '2016-04-02 05:02:14.806015');


--
-- TOC entry 3754 (class 0 OID 58250)
-- Dependencies: 202
-- Data for Name: tb_sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_sales VALUES (376, 571, 1, 4, 185, 1, '2019-06-01 07:58:07.004008', '2019-06-01 07:58:07.004008', '2019-06-01');
INSERT INTO public.tb_sales VALUES (377, 571, 1, 4, 186, 1, '2019-06-01 08:07:11.388993', '2019-06-01 08:07:11.388993', '2019-06-01');
INSERT INTO public.tb_sales VALUES (378, 571, 1, 4, 187, 1, '2019-06-01 08:07:32.421289', '2019-06-01 08:07:32.421289', '2019-06-01');
INSERT INTO public.tb_sales VALUES (379, 571, 1, 4, 188, 1, '2019-06-01 08:07:42.353248', '2019-06-01 08:07:42.353248', '2019-06-01');
INSERT INTO public.tb_sales VALUES (383, 587, 1, 7, 190, 1, '2019-06-02 03:55:53.990535', '2019-06-02 03:55:53.990535', '2019-06-02');
INSERT INTO public.tb_sales VALUES (384, 586, 1, 7, 190, 1, '2019-06-02 03:55:53.990535', '2019-06-02 03:55:53.990535', '2019-06-02');
INSERT INTO public.tb_sales VALUES (385, 584, 1, 6, 190, 1, '2019-06-02 03:55:53.990535', '2019-06-02 03:55:53.990535', '2019-06-02');
INSERT INTO public.tb_sales VALUES (386, 583, 1, 4, 190, 1, '2019-06-02 03:55:53.990535', '2019-06-02 03:55:53.990535', '2019-06-02');
INSERT INTO public.tb_sales VALUES (397, 148, 1, 35, 197, 1, '2019-06-14 16:43:30.060333', '2019-06-14 16:43:30.060333', '2019-06-14');
INSERT INTO public.tb_sales VALUES (398, 573, 1, 7, 197, 1, '2019-06-14 16:43:30.060333', '2019-06-14 16:43:30.060333', '2019-06-14');
INSERT INTO public.tb_sales VALUES (402, 32, 1, 20, 200, 1, '2019-06-23 02:40:34.289663', '2019-06-23 02:40:34.289663', '2019-06-23');
INSERT INTO public.tb_sales VALUES (375, 571, 1, 4, 184, 1, '2019-06-01 07:54:24.703315', '2019-06-01 07:54:24.703315', '2019-06-01');
INSERT INTO public.tb_sales VALUES (380, 586, 1, 7, 189, 1, '2019-06-02 03:55:09.004643', '2019-06-02 03:55:09.004643', '2019-06-02');
INSERT INTO public.tb_sales VALUES (381, 587, 1, 7, 189, 1, '2019-06-02 03:55:09.004643', '2019-06-02 03:55:09.004643', '2019-06-02');
INSERT INTO public.tb_sales VALUES (382, 584, 1, 6, 189, 1, '2019-06-02 03:55:09.004643', '2019-06-02 03:55:09.004643', '2019-06-02');
INSERT INTO public.tb_sales VALUES (387, 586, 3, 7, 191, 1, '2019-06-02 04:19:17.339326', '2019-06-02 04:19:17.339326', '2019-06-02');
INSERT INTO public.tb_sales VALUES (388, 587, 3, 7, 191, 1, '2019-06-02 04:19:17.339326', '2019-06-02 04:19:17.339326', '2019-06-02');
INSERT INTO public.tb_sales VALUES (389, 584, 1, 6, 191, 1, '2019-06-02 04:19:17.339326', '2019-06-02 04:19:17.339326', '2019-06-02');
INSERT INTO public.tb_sales VALUES (390, 586, 1, 7, 192, 1, '2019-06-04 04:28:31.443726', '2019-06-04 04:28:31.443726', '2019-06-04');
INSERT INTO public.tb_sales VALUES (391, 583, 3, 4, 192, 1, '2019-06-04 04:28:31.443726', '2019-06-04 04:28:31.443726', '2019-06-04');
INSERT INTO public.tb_sales VALUES (392, 587, 1, 7, 193, 1, '2019-06-14 13:36:46.241544', '2019-06-14 13:36:46.241544', '2019-06-14');
INSERT INTO public.tb_sales VALUES (393, 586, 1, 7, 193, 1, '2019-06-14 13:36:46.241544', '2019-06-14 13:36:46.241544', '2019-06-14');
INSERT INTO public.tb_sales VALUES (396, 573, 1, 7, 196, 1, '2019-06-14 16:37:51.397212', '2019-06-14 16:37:51.397212', '2019-06-14');


--
-- TOC entry 3755 (class 0 OID 58256)
-- Dependencies: 203
-- Data for Name: tb_salescode; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_salescode VALUES (185, 'STS0018528', 3, 1, '2019-06-01 07:58:07.004008', '2019-06-01 07:58:07.004008', '2019-06-01', NULL, 'mxn', 1, 4);
INSERT INTO public.tb_salescode VALUES (186, 'STS0018625', 3, 1, '2019-06-01 08:07:11.388993', '2019-06-01 08:07:11.388993', '2019-06-01', NULL, 'mxn', 1, 4);
INSERT INTO public.tb_salescode VALUES (187, 'STS0018722', 3, 1, '2019-06-01 08:07:32.421289', '2019-06-01 08:07:32.421289', '2019-06-01', NULL, 'mxn', 1, 4);
INSERT INTO public.tb_salescode VALUES (188, 'STS0018819', 3, 1, '2019-06-01 08:07:42.353248', '2019-06-01 08:07:42.353248', '2019-06-01', NULL, 'mxn', 1, 4);
INSERT INTO public.tb_salescode VALUES (189, 'STS0018916', 3, 1, '2019-06-02 03:55:09.004643', '2019-06-02 03:55:09.004643', '2019-06-02', NULL, 'mxn', 1, 20);
INSERT INTO public.tb_salescode VALUES (191, 'STS0019110', 3, 1, '2019-06-02 04:19:17.339326', '2019-06-02 04:19:17.339326', '2019-06-02', NULL, 'mxn', 1, 46);
INSERT INTO public.tb_salescode VALUES (192, 'STS0019207', 3, 1, '2019-06-04 04:28:31.443726', '2019-06-04 04:28:31.443726', '2019-06-04', NULL, 'mxn', 1, 20);
INSERT INTO public.tb_salescode VALUES (193, 'STS0019304', 3, 1, '2019-06-14 13:36:46.241544', '2019-06-14 13:36:46.241544', '2019-06-14', NULL, 'mxn', 1, 34);
INSERT INTO public.tb_salescode VALUES (196, 'STS0019401', 3, 1, '2019-06-14 16:37:51.397212', '2019-06-14 16:37:51.397212', '2019-06-14', NULL, 'mxn', 2, 67);
INSERT INTO public.tb_salescode VALUES (184, 'STS0000292', 3, 1, '2019-06-01 07:54:24.703315', '2019-06-01 07:54:24.703315', '2019-06-01', NULL, 'mxn', 1, 4);
INSERT INTO public.tb_salescode VALUES (190, 'STS0019013', 3, 1, '2019-06-02 03:55:53.990535', '2019-06-02 03:55:53.990535', '2019-06-02', NULL, 'mxn', 1, 23);
INSERT INTO public.tb_salescode VALUES (197, 'STS0019789', 3, 1, '2019-06-14 16:43:30.060333', '2019-06-14 16:43:30.060333', '2019-06-14', NULL, 'mxn', 1, 40);
INSERT INTO public.tb_salescode VALUES (200, 'STS0019886', 3, 1, '2019-06-23 02:40:34.289663', '2019-06-23 02:40:34.289663', '2019-06-23', NULL, 'mxn', 1, 20);
INSERT INTO public.tb_salescode VALUES (1, 'test', 2, 1, '2019-06-01 07:50:06.527811', '2019-06-01 07:50:06.527811', NULL, 'al', 'la', 1, 2);


--
-- TOC entry 3756 (class 0 OID 58265)
-- Dependencies: 204
-- Data for Name: tb_savings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_savings VALUES (1, 2, 67.7999999999999972, 'dg', 1, '2018-03-18 02:45:07.884939', NULL, 3);
INSERT INTO public.tb_savings VALUES (2, 2, 78.5999999999999943, 'SA0000292', 1, '2018-03-18 02:59:04.843517', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (3, 9, 25, 'SA0000389', 1, '2018-03-18 02:59:36.302523', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (4, 2, 60, 'SA0000486', 1, '2018-03-18 02:59:51.434697', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (5, 1, 6, 'SA0000583', 1, '2018-03-18 03:00:55.439892', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (6, 5, 30, 'SA0000680', 1, '2018-03-18 03:03:45.523089', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (7, 5, 80, 'SA0000777', 1, '2018-03-18 03:03:55.878101', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (8, 5, 6, 'SA0000874', 1, '2018-03-18 03:04:15.664004', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (9, 9, 0, 'SA0000971', 1, '2018-03-18 03:28:56.568694', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (10, 10, 0, 'SA0001068', 1, '2018-03-18 03:31:24.014045', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (11, 10, 50, 'SA0001165', 1, '2018-03-18 03:36:42.21393', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (12, 10, 9, 'SA0001262', 1, '2018-03-18 03:40:25.659866', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (13, 5, 4, 'SA0001359', 1, '2018-03-18 03:40:41.417784', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (14, 10, 1, 'SA0001456', 1, '2018-03-18 03:43:16.334775', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (15, 10, 3.5, 'SA0001553', 1, '2018-03-18 03:53:40.880072', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (16, 10, 3, 'SA0001650', 1, '2018-03-18 05:44:14.237906', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (17, 10, -6, 'SA0001747', 1, '2018-03-18 05:44:28.335702', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (18, 10, -0.5, 'SA0001844', 1, '2018-03-18 05:44:41.804903', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (19, 2, -6.40000000000000036, 'SA0001941', 1, '2018-03-18 05:44:53.349591', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (20, 2, 20, 'SA0002038', 1, '2018-03-18 05:51:46.605217', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (21, 2, -20, 'WD0002135', 1, '2018-03-18 05:51:59.317286', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (22, 10, -60, 'WD0002232', 1, '2018-03-18 05:53:11.333688', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (23, 10, 10, 'SA0002329', 1, '2018-03-18 05:55:29.678609', '2018-03-18', 3);
INSERT INTO public.tb_savings VALUES (24, 2, -50, 'WD0002426', 1, '2018-03-24 10:51:45.585671', '2018-03-24', 0);
INSERT INTO public.tb_savings VALUES (25, 2, 50, 'SA0002523', 1, '2018-03-24 10:51:56.496138', '2018-03-24', 0);
INSERT INTO public.tb_savings VALUES (26, 10, 50, 'SA0002620', 1, '2018-03-24 10:53:21.895342', '2018-03-24', 0);
INSERT INTO public.tb_savings VALUES (27, 10, -10, 'WD0002717', 1, '2018-03-24 10:53:38.499561', '2018-03-24', 0);
INSERT INTO public.tb_savings VALUES (28, 11, 0, 'SA0002814', 1, '2018-03-24 11:41:12.476141', '2018-03-24', 3);
INSERT INTO public.tb_savings VALUES (29, 1, -6, 'WD0002911', 1, '2018-03-24 11:43:52.533521', '2018-03-24', 3);
INSERT INTO public.tb_savings VALUES (30, 1, 80, 'SA0003008', 1, '2018-03-24 11:44:18.33132', '2018-03-24', 3);
INSERT INTO public.tb_savings VALUES (31, 9, -5, 'WD0003105', 1, '2018-03-26 05:00:03.375294', '2018-03-26', 0);
INSERT INTO public.tb_savings VALUES (32, 9, 500, 'SA0003202', 1, '2018-03-26 05:00:13.960523', '2018-03-26', 0);
INSERT INTO public.tb_savings VALUES (33, 9, -150, 'WD0003396', 1, '2018-03-26 05:00:30.299172', '2018-03-26', 0);
INSERT INTO public.tb_savings VALUES (34, 12, 0, 'SA0003493', 1, '2018-03-26 10:11:48.470166', '2018-03-26', 3);
INSERT INTO public.tb_savings VALUES (35, 11, 50, 'SA0003590', 1, '2018-04-06 09:49:04.72167', '2018-04-06', 3);
INSERT INTO public.tb_savings VALUES (36, 11, -34, 'WD0003687', 1, '2018-07-27 11:09:25.82437', '2018-07-27', 3);
INSERT INTO public.tb_savings VALUES (37, 11, 50, 'SA0003784', 1, '2018-07-27 11:09:38.575393', '2018-07-27', 3);
INSERT INTO public.tb_savings VALUES (38, 11, 50, 'SA0003881', 1, '2018-07-27 11:09:54.011316', '2018-07-27', 3);
INSERT INTO public.tb_savings VALUES (39, 11, -100, 'WD0003978', 1, '2018-07-27 11:10:03.145135', '2018-07-27', 3);
INSERT INTO public.tb_savings VALUES (40, 10, 200, 'SA0004075', 1, '2018-07-27 11:15:44.081289', '2018-07-27', 6);
INSERT INTO public.tb_savings VALUES (41, 11, -5000, 'WD0004172', 1, '2018-11-18 22:22:09.2989', '2018-11-18', 3);
INSERT INTO public.tb_savings VALUES (42, 11, 60000, 'SA0004269', 1, '2018-11-18 22:22:36.655823', '2018-11-18', 3);
INSERT INTO public.tb_savings VALUES (43, 13, 0, 'SA0004366', 1, '2018-12-23 05:07:00.352533', '2018-12-23', 6);
INSERT INTO public.tb_savings VALUES (44, 14, 0, 'SA0004463', 1, '2018-12-23 05:08:02.942839', '2018-12-23', 6);
INSERT INTO public.tb_savings VALUES (45, 15, 0, 'SA0004560', 1, '2018-12-23 05:14:06.510316', '2018-12-23', 6);
INSERT INTO public.tb_savings VALUES (46, 15, 600, 'SA0004657', 1, '2018-12-23 06:19:07.994034', '2018-12-23', 6);
INSERT INTO public.tb_savings VALUES (47, 15, 700, 'SA0004754', 1, '2018-12-23 06:19:26.596257', '2018-12-23', 6);
INSERT INTO public.tb_savings VALUES (48, 15, -50, 'WD0004851', 1, '2018-12-23 06:19:50.815967', '2018-12-23', 6);
INSERT INTO public.tb_savings VALUES (49, 12, 10, 'SA0004948', 1, '2018-12-23 08:51:23.371756', '2018-12-23', 6);
INSERT INTO public.tb_savings VALUES (50, 12, 4, 'SA0005045', 1, '2018-12-23 08:52:28.51488', '2018-12-23', 6);
INSERT INTO public.tb_savings VALUES (51, 12, 490, 'SA0005142', 1, '2018-12-23 08:57:08.744014', '2018-12-23', 6);
INSERT INTO public.tb_savings VALUES (52, 11, 30, 'SA0005239', 1, '2019-01-22 16:39:54.860716', '2019-01-22', 6);
INSERT INTO public.tb_savings VALUES (53, 11, -20, 'WD0005336', 1, '2019-01-22 16:42:10.85333', '2019-01-22', 6);
INSERT INTO public.tb_savings VALUES (54, 16, 0, 'SA0005433', 1, '2019-01-22 16:45:22.438788', '2019-01-22', 6);
INSERT INTO public.tb_savings VALUES (55, 17, 0, 'SA0005530', 1, '2019-04-03 21:44:36.030277', '2019-04-03', 6);
INSERT INTO public.tb_savings VALUES (56, 18, 0, 'SA0005627', 1, '2019-04-03 21:44:41.198091', '2019-04-03', 6);
INSERT INTO public.tb_savings VALUES (57, 19, 0, 'SA0005724', 1, '2019-04-03 21:46:48.460032', '2019-04-03', 6);
INSERT INTO public.tb_savings VALUES (58, 20, 0, 'SA0005821', 1, '2019-04-03 21:48:36.599799', '2019-04-03', 6);
INSERT INTO public.tb_savings VALUES (59, 21, 0, 'SA0005918', 1, '2019-04-06 14:51:53.294291', '2019-04-06', 6);


--
-- TOC entry 3766 (class 0 OID 58417)
-- Dependencies: 225
-- Data for Name: tb_section; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_section VALUES (1, 'Yoghurt', 'YOH', '2018-04-06 01:06:22.141419');
INSERT INTO public.tb_section VALUES (2, 'Agric', 'AGR', '2018-04-06 01:06:35.83684');


--
-- TOC entry 3760 (class 0 OID 58324)
-- Dependencies: 213
-- Data for Name: tb_shop; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_shop VALUES (1, 'Shop A', 'SHA', 1, '2018-02-03 13:29:47.113785');
INSERT INTO public.tb_shop VALUES (2, 'Shop B', 'SHB', 1, '2018-02-03 13:30:03.985637');
INSERT INTO public.tb_shop VALUES (20, 'Shop 20', 'S20', 1, '2018-04-06 01:29:03.532147');


--
-- TOC entry 3818 (class 0 OID 59084)
-- Dependencies: 307
-- Data for Name: tb_unit; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tb_unit VALUES (1, 'Kilogram', 'kg', '2019-05-12 09:17:58.23004');
INSERT INTO public.tb_unit VALUES (2, 'Box', 'box', '2019-05-12 09:18:43.214192');
INSERT INTO public.tb_unit VALUES (0, 'No Unit', 'na', '2019-05-12 09:21:11.881799');


--
-- TOC entry 3768 (class 0 OID 58461)
-- Dependencies: 229
-- Data for Name: tbs_audittrail; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tbs_audittrail VALUES (1, 1, 'User Edit', 'RecId = 5 :: Username (O) = examadmin, (N) = chcadmin :: Other Names (O) = Exam, (N) = Church :: Email (O) = examsupport@kpoly.edu.gh, (N) = chcsupport@cac4.com', '2016-04-10 17:56:14.527993');
INSERT INTO public.tbs_audittrail VALUES (2, 1, 'User Add', 'RecId = 45 :: Surname = napoleon :: OtherNames = napoleaon :: Username = naps :: EntityId = 1 :: RoleId = 9 :: LoginStatus = 0 :: ContactNo1 = 00000000 :: ContactNo2 =  :: Email = naps@gmai.com :: DateCreated = 2016-04-10 17:58:47.600162 :: LastLoginDate = 2016-04-10 17:58:47.600162 :: Comments =  :: Status = 1 :: ApStatus = 1 :: Stamp = 2016-04-10 17:58:47.600162', '2016-04-10 17:58:47.600162');
INSERT INTO public.tbs_audittrail VALUES (3, 1, 'Privilege Edit', 'RecId = 836 :: Name = Print Certificate statistics :: Shortcode = fbi :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:02:20.741');
INSERT INTO public.tbs_audittrail VALUES (4, 1, 'Privilege Edit', 'RecId = 835 :: Name = View Certificate statistics :: Shortcode = fbk :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:02:30.086341');
INSERT INTO public.tbs_audittrail VALUES (5, 1, 'Privilege Edit', 'RecId = 812 :: Name = Print Admissions statistics :: Shortcode = fbb :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:02:38.067726');
INSERT INTO public.tbs_audittrail VALUES (6, 1, 'Privilege Edit', 'RecId = 110 :: Name = Update Candidate :: Shortcode = aaj :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:02:53.268668');
INSERT INTO public.tbs_audittrail VALUES (7, 1, 'Privilege Edit', 'RecId = 121 :: Name = View Ranking :: Shortcode = abb :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:02:58.928465');
INSERT INTO public.tbs_audittrail VALUES (8, 1, 'Privilege Edit', 'RecId = 122 :: Name = Print Ranking :: Shortcode = abc :: AccessLevel (O) = 33286, (N) = 32774', '2016-04-10 18:03:04.919332');
INSERT INTO public.tbs_audittrail VALUES (9, 1, 'Privilege Edit', 'RecId = 123 :: Name = Generate Admission :: Shortcode = aca :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:03:11.003691');
INSERT INTO public.tbs_audittrail VALUES (10, 1, 'Privilege Edit', 'RecId = 124 :: Name = View Admission :: Shortcode = acb :: AccessLevel (O) = 49670, (N) = 49158', '2016-04-10 18:03:16.447275');
INSERT INTO public.tbs_audittrail VALUES (11, 1, 'Privilege Edit', 'RecId = 125 :: Name = Print Admission :: Shortcode = acc :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:03:21.972765');
INSERT INTO public.tbs_audittrail VALUES (12, 1, 'Privilege Edit', 'RecId = 126 :: Name = Print Letters :: Shortcode = ada :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:03:27.092334');
INSERT INTO public.tbs_audittrail VALUES (13, 1, 'Privilege Edit', 'RecId = 127 :: Name = Search Protocol :: Shortcode = afa :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:03:32.773698');
INSERT INTO public.tbs_audittrail VALUES (14, 1, 'Privilege Edit', 'RecId = 128 :: Name = Rank Protocol :: Shortcode = afb :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:03:38.025096');
INSERT INTO public.tbs_audittrail VALUES (15, 1, 'Privilege Edit', 'RecId = 811 :: Name = View Admissions statistics :: Shortcode = fba :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:03:45.223661');
INSERT INTO public.tbs_audittrail VALUES (16, 1, 'Privilege Edit', 'RecId = 129 :: Name = Admit Protocol :: Shortcode = afc :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:03:51.673572');
INSERT INTO public.tbs_audittrail VALUES (17, 1, 'Privilege Edit', 'RecId = 130 :: Name = Protocol Letter :: Shortcode = afd :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:03:56.482325');
INSERT INTO public.tbs_audittrail VALUES (18, 1, 'Privilege Edit', 'RecId = 131 :: Name = View Protocol :: Shortcode = afe :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:04:01.681101');
INSERT INTO public.tbs_audittrail VALUES (19, 1, 'Privilege Edit', 'RecId = 132 :: Name = Send SMS Notification :: Shortcode = aff :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:04:06.715429');
INSERT INTO public.tbs_audittrail VALUES (20, 1, 'Privilege Edit', 'RecId = 133 :: Name = Print Matriculant :: Shortcode = ack :: AccessLevel (O) = 49670, (N) = 49158', '2016-04-10 18:04:12.501868');
INSERT INTO public.tbs_audittrail VALUES (21, 1, 'Privilege Edit', 'RecId = 134 :: Name = View Matriculant :: Shortcode = acl :: AccessLevel (O) = 49670, (N) = 49158', '2016-04-10 18:04:17.818437');
INSERT INTO public.tbs_audittrail VALUES (22, 1, 'Privilege Edit', 'RecId = 135 :: Name = Print Letter :: Shortcode = acm :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:04:23.761266');
INSERT INTO public.tbs_audittrail VALUES (23, 1, 'Privilege Edit', 'RecId = 165 :: Name = Generate Index Number :: Shortcode = aje :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:04:29.111259');
INSERT INTO public.tbs_audittrail VALUES (24, 1, 'Privilege Edit', 'RecId = 166 :: Name = Export Index Number :: Shortcode = ajf :: AccessLevel (O) = 37542, (N) = 37030', '2016-04-10 18:04:34.08598');
INSERT INTO public.tbs_audittrail VALUES (25, 1, 'Privilege Edit', 'RecId = 167 :: Name = Generate Naptex Index :: Shortcode = ajg :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:04:39.504175');
INSERT INTO public.tbs_audittrail VALUES (26, 1, 'Privilege Edit', 'RecId = 168 :: Name = Export Naptex Index Number :: Shortcode = ajh :: AccessLevel (O) = 37510, (N) = 36998', '2016-04-10 18:04:45.065362');
INSERT INTO public.tbs_audittrail VALUES (27, 1, 'Privilege Edit', 'RecId = 180 :: Name = View Remote Applicants :: Shortcode = aba :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:04:49.529181');
INSERT INTO public.tbs_audittrail VALUES (28, 1, 'Privilege Edit', 'RecId = 412 :: Name = Edit Program :: Shortcode = blb :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:04:56.353936');
INSERT INTO public.tbs_audittrail VALUES (29, 1, 'Privilege Edit', 'RecId = 231 :: Name = View Admissions statistics :: Shortcode = aub :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:00.972024');
INSERT INTO public.tbs_audittrail VALUES (30, 1, 'Privilege Edit', 'RecId = 232 :: Name = Print Admissions statistics :: Shortcode = auc :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:06.696129');
INSERT INTO public.tbs_audittrail VALUES (31, 1, 'Privilege Edit', 'RecId = 233 :: Name = View Certificate statistics :: Shortcode = aud :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:12.142647');
INSERT INTO public.tbs_audittrail VALUES (32, 1, 'Privilege Edit', 'RecId = 234 :: Name = Print Certificate statistics :: Shortcode = auf :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:16.94887');
INSERT INTO public.tbs_audittrail VALUES (33, 1, 'Privilege Edit', 'RecId = 321 :: Name = Add Subjects :: Shortcode = bca :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:22.148775');
INSERT INTO public.tbs_audittrail VALUES (34, 1, 'Privilege Edit', 'RecId = 322 :: Name = Edit Subjects :: Shortcode = bcb :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:27.823628');
INSERT INTO public.tbs_audittrail VALUES (35, 1, 'Privilege Edit', 'RecId = 332 :: Name = Edit Subject Types :: Shortcode = bdb :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:34.059498');
INSERT INTO public.tbs_audittrail VALUES (36, 1, 'Privilege Edit', 'RecId = 342 :: Name = Edit Grade :: Shortcode = beb :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:39.032598');
INSERT INTO public.tbs_audittrail VALUES (37, 1, 'Privilege Edit', 'RecId = 405 :: Name = Configure Program :: Shortcode = bke :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:47.091201');
INSERT INTO public.tbs_audittrail VALUES (38, 1, 'Privilege Edit', 'RecId = 402 :: Name = Edit Program :: Shortcode = bkb :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:53.36004');
INSERT INTO public.tbs_audittrail VALUES (39, 1, 'Privilege Edit', 'RecId = 401 :: Name = Add Program :: Shortcode = bka :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:05:58.32834');
INSERT INTO public.tbs_audittrail VALUES (40, 1, 'Privilege Edit', 'RecId = 115 :: Name = Mopup Data from Remote :: Shortcode = alo :: AccessLevel (O) = 6, (N) = 518', '2016-04-10 18:10:14.738726');
INSERT INTO public.tbs_audittrail VALUES (41, 1, 'Privilege Edit', 'RecId = 115 :: Name = Mopup Data from Remote :: Shortcode = alo :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:11:40.247738');
INSERT INTO public.tbs_audittrail VALUES (42, 1, 'Privilege Edit', 'RecId = 106 :: Name = Add Wizard :: Shortcode = aaf :: AccessLevel (O) = 6, (N) = 518', '2016-04-10 18:13:54.682353');
INSERT INTO public.tbs_audittrail VALUES (43, 1, 'Privilege Edit', 'RecId = 106 :: Name = Add Wizard :: Shortcode = aaf :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:15:04.593858');
INSERT INTO public.tbs_audittrail VALUES (44, 1, 'Privilege Edit', 'RecId = 110 :: Name = Update Candidate :: Shortcode = aaj :: AccessLevel (O) = 6, (N) = 518', '2016-04-10 18:15:16.55378');
INSERT INTO public.tbs_audittrail VALUES (45, 1, 'Privilege Edit', 'RecId = 215 :: Name = View Member Profile :: Shortcode = aye :: AccessLevel (O) = 70, (N) = 582', '2016-04-10 18:17:59.609196');
INSERT INTO public.tbs_audittrail VALUES (46, 1, 'Privilege Edit', 'RecId = 135 :: Name = Print Letter :: Shortcode = acm :: AccessLevel (O) = 6, (N) = 518', '2016-04-10 18:27:43.005883');
INSERT INTO public.tbs_audittrail VALUES (47, 1, 'Privilege Edit', 'RecId = 135 :: Name = Print Letter :: Shortcode = acm :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:28:18.76801');
INSERT INTO public.tbs_audittrail VALUES (48, 1, 'Privilege Edit', 'RecId = 126 :: Name = Print Letters :: Shortcode = ada :: AccessLevel (O) = 6, (N) = 518', '2016-04-10 18:28:33.94434');
INSERT INTO public.tbs_audittrail VALUES (49, 1, 'Privilege Edit', 'RecId = 126 :: Name = Print Letters :: Shortcode = ada :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 18:29:29.014824');
INSERT INTO public.tbs_audittrail VALUES (50, 1, 'Privilege Edit', 'RecId = 121 :: Name = View Ranking :: Shortcode = abb :: AccessLevel (O) = 6, (N) = 518', '2016-04-10 19:19:01.362897');
INSERT INTO public.tbs_audittrail VALUES (51, 1, 'Privilege Edit', 'RecId = 464 :: Name = View Rank :: Shortcode = btd :: AccessLevel (O) = 6, (N) = 518', '2016-04-10 19:19:31.723826');
INSERT INTO public.tbs_audittrail VALUES (52, 1, 'Privilege Edit', 'RecId = 464 :: Name = View Rank :: Shortcode = btd :: AccessLevel (O) = 518, (N) = 6', '2016-04-10 19:20:25.46289');
INSERT INTO public.tbs_audittrail VALUES (53, 1, 'Privilege Edit', 'RecId = 122 :: Name = View Events :: Shortcode = abc :: AccessLevel (O) = 32774, (N) = 33286', '2016-04-10 19:28:21.54298');
INSERT INTO public.tbs_audittrail VALUES (54, 1, 'Privilege Edit', 'RecId = 122 :: Name = View Events :: Shortcode = abc :: AccessLevel (O) = 33286, (N) = 32774', '2016-04-10 22:15:25.647275');
INSERT INTO public.tbs_audittrail VALUES (55, 1, 'Privilege Edit', 'RecId = 122 :: Name = View Events :: Shortcode = abc :: AccessLevel (O) = 32774, (N) = 33286', '2016-04-10 22:28:29.421679');
INSERT INTO public.tbs_audittrail VALUES (56, 1, 'Privilege Edit', 'RecId = 122 :: Name = View Events :: Shortcode = abc :: AccessLevel (O) = 33286, (N) = 32774', '2016-04-10 22:37:21.85522');
INSERT INTO public.tbs_audittrail VALUES (57, 1, 'User Edit', 'RecId = 44 :: ContactNo1 (O) = 021-257803, (N) = 0277686939 :: ContactNo2 (O) = 024-456883, (N) =  :: Email (O) = amoako-yirenkyi@gmail.com, (N) = alleneben@gmail.com', '2016-04-14 11:23:35.490564');
INSERT INTO public.tbs_audittrail VALUES (58, 1, 'User Edit', 'RecId = 2 :: ContactNo1 (O) = 021-257803, (N) = 0277686939 :: ContactNo2 (O) = 024-456883, (N) =', '2016-04-14 11:24:18.144611');
INSERT INTO public.tbs_audittrail VALUES (64, 3, 'User Add', 'RecId = 13 :: Surname = allen :: OtherNames = kay :: Username = a.kay :: EntityId = 1 :: RoleId = 5 :: LoginStatus = 0 :: ContactNo1 = 9879898 :: ContactNo2 =  :: Email = a@gmail.com :: DateCreated = 2017-12-30 14:48:31.238428 :: LastLoginDate = 2017-12-30 14:48:31.238428 :: Comments = Accra :: Status = 1 :: ApStatus = 1 :: Stamp = 2017-12-30 14:48:31.238428', '2017-12-30 14:48:31.238428');
INSERT INTO public.tbs_audittrail VALUES (66, 3, 'User Add', 'RecId = 15 :: Surname = asad :: OtherNames = saas :: Username = a.nbnb :: EntityId = 1 :: RoleId = 5 :: LoginStatus = 0 :: ContactNo1 = ghghgh :: ContactNo2 =  :: Email = hghgh :: DateCreated = 2017-12-30 14:49:13.517723 :: LastLoginDate = 2017-12-30 14:49:13.517723 :: Comments = hjhjhjh :: Status = 1 :: ApStatus = 1 :: Stamp = 2017-12-30 14:49:13.517723', '2017-12-30 14:49:13.517723');
INSERT INTO public.tbs_audittrail VALUES (67, 3, 'Add Category', 'RecId = 11 :: CategoryName = tools and equipment :: Stamp = 2018-04-06 01:10:04.478351', '2019-06-25 07:58:32.96947');
INSERT INTO public.tbs_audittrail VALUES (68, 3, 'Add Category', 'RecId = 13 :: CategoryName = gfgff :: Stamp = 2019-06-25 07:59:45.174334', '2019-06-25 07:59:45.174334');
INSERT INTO public.tbs_audittrail VALUES (69, 3, 'Add Category', 'RecId = 14 :: CategoryName = hjdhkd :: Stamp = 2019-06-25 09:31:57.208969', '2019-06-25 09:31:57.208969');
INSERT INTO public.tbs_audittrail VALUES (70, 3, 'Add Category', 'RecId = 15 :: CategoryName = allen :: Stamp = 2019-06-25 09:33:41.554864', '2019-06-25 09:33:41.554864');
INSERT INTO public.tbs_audittrail VALUES (71, 3, 'Add Category', 'RecId = 16 :: CategoryName = allen :: Stamp = 2019-06-25 12:29:30.60137', '2019-06-25 12:29:30.60137');
INSERT INTO public.tbs_audittrail VALUES (72, 3, 'Add Category', 'RecId = 17 :: CategoryName = ljkjkjkjkj :: Stamp = 2019-06-26 01:35:20.091452', '2019-06-26 01:35:20.091452');
INSERT INTO public.tbs_audittrail VALUES (73, 3, 'Add Category', 'RecId = 18 :: CategoryName = hghsgds :: Stamp = 2019-06-26 01:37:39.987206', '2019-06-26 01:37:39.987206');
INSERT INTO public.tbs_audittrail VALUES (74, 3, 'Add Category', 'RecId = 19 :: CategoryName = sdsdsd :: Stamp = 2019-06-26 01:41:55.672284', '2019-06-26 01:41:55.672284');
INSERT INTO public.tbs_audittrail VALUES (75, 3, 'Add Category', 'RecId = 20 :: CategoryName = nbnbncb :: Stamp = 2019-06-27 02:10:35.108458', '2019-06-27 02:10:35.108458');


--
-- TOC entry 3769 (class 0 OID 58470)
-- Dependencies: 230
-- Data for Name: tbs_entity; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tbs_entity VALUES (0, 'Customer', 0, '*', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2008-05-27 18:01:38.833996', 0, 0);
INSERT INTO public.tbs_entity VALUES (1, 'S T S', 1, 'Adum', 'Kejetia', NULL, NULL, NULL, 'hg', NULL, NULL, 1, '2017-12-29 05:27:23.984953', 100, 100);


--
-- TOC entry 3770 (class 0 OID 58481)
-- Dependencies: 231
-- Data for Name: tbs_entitytype; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tbs_entitytype VALUES (0, 'Customers', 0, '2011-01-30 08:20:13.202826', NULL);
INSERT INTO public.tbs_entitytype VALUES (1, 'STS', 1, '2017-12-28 17:51:21.234859', NULL);
INSERT INTO public.tbs_entitytype VALUES (2, 'Another Company', 1, '2017-12-29 05:27:11.761545', NULL);


--
-- TOC entry 3811 (class 0 OID 58710)
-- Dependencies: 280
-- Data for Name: tbs_error; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tbs_error VALUES (1, '::DBERR-001::Update Concurrency::');
INSERT INTO public.tbs_error VALUES (2, '::DBERR-002::Main Entity cannot be deleted::');
INSERT INTO public.tbs_error VALUES (3, '::DBERR-003::Superuser role not support in this context::');
INSERT INTO public.tbs_error VALUES (4, '::DBERR-004::User Session Expired::');
INSERT INTO public.tbs_error VALUES (5, '::DBERR-005::Cannot read from or write to a non-existent session::');
INSERT INTO public.tbs_error VALUES (7, '::DBERR-007::User Account has been Suspended::');
INSERT INTO public.tbs_error VALUES (8, '::DBERR-008::Session does not exist::');
INSERT INTO public.tbs_error VALUES (9, '::DBERR-009::Another user is currently using the account::');
INSERT INTO public.tbs_error VALUES (10, '::DBERR-010::The browser is already running an instance of the application::');
INSERT INTO public.tbs_error VALUES (11, '::DBERR-011::Image verification required::');
INSERT INTO public.tbs_error VALUES (12, '::DBERR-012::Invalid login details::');
INSERT INTO public.tbs_error VALUES (13, '::DBERR-013::Invalid User ID::');
INSERT INTO public.tbs_error VALUES (14, '::DBERR-014::Old Password value does not match Current Password value::');
INSERT INTO public.tbs_error VALUES (15, '::DBERR-015::User Account has been Locked::');
INSERT INTO public.tbs_error VALUES (16, '::DBERR-016::Number of FieldName fields do not match number of FieldTypeId fields::');
INSERT INTO public.tbs_error VALUES (17, '::DBERR-017::No record found for this record id::');
INSERT INTO public.tbs_error VALUES (18, '::DBERR-018::Number of IsMandatory Fields do not match number of FieldTypeId fields::');
INSERT INTO public.tbs_error VALUES (19, '::DBERR-019::User Account cannot be found::');
INSERT INTO public.tbs_error VALUES (20, '::DBERR-020::Forgotten Password Activation is invalid::');
INSERT INTO public.tbs_error VALUES (21, '::DBERR-021::Record of the Subscriber cannot be found::');
INSERT INTO public.tbs_error VALUES (22, '::DBERR-022::Only the user who placed the request can cancel it::');
INSERT INTO public.tbs_error VALUES (23, '::DBERR-023::Only pending request may be cancelled.::');
INSERT INTO public.tbs_error VALUES (24, '::DBERR-024::Invalid Authorization Code::');
INSERT INTO public.tbs_error VALUES (25, '::DBERR-025::No Message::');
INSERT INTO public.tbs_error VALUES (26, '::DBERR-026::No Message::');
INSERT INTO public.tbs_error VALUES (27, '::DBERR-027::Permission Denied');
INSERT INTO public.tbs_error VALUES (6, '::DBERR-006::Invalid Username and Password::');


--
-- TOC entry 3812 (class 0 OID 58714)
-- Dependencies: 281
-- Data for Name: tbs_inbox; Type: TABLE DATA; Schema: public; Owner: kpuser
--



--
-- TOC entry 3772 (class 0 OID 58518)
-- Dependencies: 237
-- Data for Name: tbs_privilege; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tbs_privilege VALUES (522, 'View Role', 'ccd', 'Security', 'Roles', 'EN', 522, 6, 'role', 'SECU', 'View', 'viewfn', 1, '2019-06-15 05:08:37.069487', 2);
INSERT INTO public.tbs_privilege VALUES (511, 'Add User', 'cba', 'Security', 'User', 'EN', 511, 1, 'user', 'SECU', 'New', 'addfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (512, 'Edit User', 'cbb', 'Security', 'User', 'EN', 512, 1, 'user', 'SECU', 'Edit', 'editfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (513, 'Del User', 'cbc', 'Security', 'User', 'EN', 513, 1, 'user', 'SECU', 'Delete', 'delfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (521, 'Edit Role', 'ccb', 'Security', 'Role', 'EN', 521, 1, 'role', 'SECU', 'Edit', 'editfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (531, 'Add Privilege', 'cda', 'Security', 'Privilege', 'EN', 531, 1, 'privilege', 'SECU', 'New', 'addfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (532, 'Edit Privilege', 'cdb', 'Security', 'Privilege', 'EN', 532, 1, 'privilege', 'SECU', 'Edit', 'editfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (533, 'Del Privilege', 'cdc', 'Security', 'Privilege', 'EN', 533, 1, 'privilege', 'SECU', 'Delete', 'delfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (541, 'View Audit', 'cea', 'Security', 'Audit', 'EN', 541, 1, 'audit', 'SECU', 'View', 'viewfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (621, 'Configure Status', 'dba', 'System', 'Statuses', 'EN', 621, 1, 'statuses', 'SYST', 'Edit', 'editfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (505, 'User Profile', 'cae', 'Security', 'Profile', 'EN', 505, 20735, 'profile', 'SECU', 'Profile', 'profilefn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (515, 'Set Password', 'cbe', 'Security', 'User', 'EN', 515, 1, 'user', 'SECU', 'Password', 'passwdfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (514, 'View User', 'cbd', 'Security', 'User', 'EN', 514, 32769, 'user', 'SECU', 'View', 'viewfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (534, 'View Privilege', 'cdd', 'Security', 'Privilege', 'EN', 534, 1, 'privilege', 'SECU', 'View', 'viewfn', 0, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (611, 'Edit Settings', 'daa', 'System', 'Settings', 'EN', 611, 1, 'settings', 'SYST', 'Edit', 'editfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (506, 'Change Password', 'caf', 'Security', 'Profile', 'EN', 506, 53375, 'profile', 'SECU', 'Password', 'passwdfn', 1, '2017-05-19 02:41:27.892809', 4);
INSERT INTO public.tbs_privilege VALUES (113, 'New Sales', 'aak', 'POS', 'Manage Customers', 'EN', 113, 14, 'newsales', 'NUSL', 'Edit', 'editfn', 1, '2019-06-15 02:02:50.079968', 2);
INSERT INTO public.tbs_privilege VALUES (115, 'Sales Summary', 'alo', 'Sales Summary', 'Manage Customers', 'EN', 115, 518, 'salesummary', 'SSUM', 'Products', 'printfn', 0, '2019-05-11 16:50:08.559419', 2);
INSERT INTO public.tbs_privilege VALUES (119, 'Print Sales', 'aaq', 'Sales Summary', 'Manage Reports', 'EN', 178, 518, 'salesummary', 'SSUM', 'Sales', 'salesfn', 0, '2019-05-11 16:50:12.158109', 2);
INSERT INTO public.tbs_privilege VALUES (120, 'Extra Stock', 'aar', 'Products', 'Manage Products', 'EN', 179, 518, 'product', 'PROD', 'Extra', 'extrafn', 0, '2019-05-11 16:50:13.373905', 4);
INSERT INTO public.tbs_privilege VALUES (108, 'Product Unit', 'aah', 'Categories', 'Categories', 'EN', 108, 518, 'productcategories', 'PROD', 'Add Unit', 'adduint', 0, '2019-06-23 02:35:09.889401', 2);
INSERT INTO public.tbs_privilege VALUES (104, 'Sales', 'aad', 'Shops', 'Sales', 'EN', 104, 6, 'sales', 'SHPS', 'Generate Barcodes', 'genbarcd', 1, '2019-06-24 18:49:19.590084', 2);
INSERT INTO public.tbs_privilege VALUES (102, 'Add Stock', 'aab', 'Products', 'Create', 'EN', 102, 14, 'product', 'SLST', 'Add Stock', 'addstock', 1, '2019-06-24 19:24:09.529959', 2);
INSERT INTO public.tbs_privilege VALUES (101, 'Edit Stock', 'aaa', 'New Stock', 'Manage Sales', 'EN', 101, 518, 'stock', 'NSTK', 'Edit Stock', 'editstock', 0, '2019-05-11 16:49:36.349603', 4);
INSERT INTO public.tbs_privilege VALUES (112, 'Users', 'aam', 'Users', 'Manage Customers', 'EN', 112, 518, 'users', 'USRS', 'Add User', 'addfn', 0, '2019-05-11 16:49:49.684268', 2);
INSERT INTO public.tbs_privilege VALUES (114, 'Sales', 'aal', 'Sales', 'Manage Products', 'EN', 114, 518, 'sales', 'SALE', 'Add', 'addfn', 0, '2019-05-11 16:49:53.9432', 2);
INSERT INTO public.tbs_privilege VALUES (117, 'Add Sales', 'ajl', 'Sales', 'Manage Reports', 'EN', 177, 518, 'reports', 'SALE', 'Add Sales', 'salesfn', 0, '2019-05-11 16:50:10.198066', 2);
INSERT INTO public.tbs_privilege VALUES (118, 'Save Sales', 'aap', 'Sales', 'Manage Reports', 'EN', 176, 518, 'reports', 'SALE', 'Products List', 'printfn', 0, '2019-05-11 16:50:11.373917', 2);
INSERT INTO public.tbs_privilege VALUES (121, 'New Stocks', 'abb', 'New Stock', 'Manage Events', 'EN', 121, 518, 'product', 'ADMI', 'Add New', 'addfn', 0, '2019-05-11 16:50:14.293997', 4);
INSERT INTO public.tbs_privilege VALUES (105, 'Product Categories', 'aae', 'Categories', 'Create', 'EN', 105, 6, 'productcategories', 'PROD', 'Create', 'addcat', 1, '2019-06-23 02:35:02.607367', 2);
INSERT INTO public.tbs_privilege VALUES (109, 'Product List', 'aai', 'Shops', 'Products', 'EN', 109, 6, 'products', 'SHPS', 'List', 'addusr', 1, '2019-06-24 19:21:23.946038', 2);
INSERT INTO public.tbs_privilege VALUES (103, 'Shop', 'aac', 'Shops', 'Create', 'EN', 103, 6, 'product', 'SHPS', 'Stock List', 'stocklist', 1, '2019-06-24 19:24:05.486787', 2);


--
-- TOC entry 3771 (class 0 OID 58489)
-- Dependencies: 232
-- Data for Name: tbs_role; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tbs_role VALUES (1, 'SuperUser', 'Role for Super User', 1, 0, 60, 1, '2010-10-20 13:31:07.039555');
INSERT INTO public.tbs_role VALUES (2, 'System Admin', 'System Administrator', 1, 2, 600, 1, '2010-10-20 13:31:07.039555');
INSERT INTO public.tbs_role VALUES (3, 'Data Entry', 'Data Entry Officer', 1, 3, 600, 1, '2010-09-15 07:04:34.492823');
INSERT INTO public.tbs_role VALUES (0, 'Guest', 'Guest Role', 0, 16, 10000, 0, '2011-09-06 09:06:04.36884');
INSERT INTO public.tbs_role VALUES (4, 'Sales Officer/Cashier', 'Cash Office staff', 1, 4, 600, 1, '2017-12-29 06:36:20.3698');
INSERT INTO public.tbs_role VALUES (5, 'Administrator', 'Administrative Officer', 1, 5, 600, 1, '2017-12-29 06:37:08.608745');


--
-- TOC entry 3815 (class 0 OID 58727)
-- Dependencies: 284
-- Data for Name: tbs_session; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tbs_session VALUES (3, '2019-06-27 02:19:48.585007', '', 'rj5vj59c9qvm6969tkedqs8a76');


--
-- TOC entry 3773 (class 0 OID 58565)
-- Dependencies: 241
-- Data for Name: tbs_systemdefault; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tbs_systemdefault VALUES (1, 'G', 'DEFAULT_SESSION_TIMEOUT', '10', 'Time in seconds after which the session of a client is terminated.', '2008-06-04 18:55:40.95826');
INSERT INTO public.tbs_systemdefault VALUES (2, 'G', 'MESSAGE_VALIDITY', '10', 'Time in days after which a message is automatically deleted from system.', '2008-05-01 23:23:33.745967');
INSERT INTO public.tbs_systemdefault VALUES (3, 'G', 'INBOX_CAPACITY', '100', 'Maximum number of messages that can be contained in an inbox before LIFO starts.', '2008-06-01 17:34:49.557033');
INSERT INTO public.tbs_systemdefault VALUES (4, 'G', 'FORGOTTEN_PASSWORD_VALIDITY', '1', 'Time in days after which password link sent to user''s email will expire.', '2008-05-06 10:48:48.581377');
INSERT INTO public.tbs_systemdefault VALUES (6, 'G', 'MAIL_SERVER', 'localhost', 'Mail Server Name or IP Address', '2008-06-04 19:01:37.447112');
INSERT INTO public.tbs_systemdefault VALUES (7, 'G', 'MAIL_FROM_NAME', 'The Platform', 'Name value that will be captured in the ''From'' field of the email', '2008-06-04 19:02:10.648759');
INSERT INTO public.tbs_systemdefault VALUES (8, 'G', 'MAIL_WRAP', '100', 'Number of words on a line of an email before wrapping', '2008-06-04 19:03:09.503537');
INSERT INTO public.tbs_systemdefault VALUES (9, 'G', 'NU_SUBJECT', 'Welcome to the Platform', 'The subject of the system mail sent to a new user.', '2008-06-04 21:09:42.592098');
INSERT INTO public.tbs_systemdefault VALUES (10, 'G', 'NU_HTMLBODY', 'Dear #NAME#,<br>
Welcome to the Platform.<br>
To login, use the username given to you by the System
Administrator and the password below:<br>
<b>#PASS#<b>', 'The body of the system mail sent to a new user. 
Please note that #NAME# and #PASS# would be substituted with the 
respective Name and Password value. This field may contain html tags', '2008-06-05 19:54:56.011408');
INSERT INTO public.tbs_systemdefault VALUES (11, 'G', 'NU_TEXTBODY', 'Dear #NAME#,
Welcome to the Platform.
To login, use the username given to you by the System
Administrator and the password  #PASS#', 'The body of the system email sent to a new user.
Please note that #NAME# and #PASS# would be substituted with the
respective Name and Password value. This field contains no special tags.', '2008-06-04 21:10:45.003115');
INSERT INTO public.tbs_systemdefault VALUES (12, 'G', 'FP_SUBJECT', 'Platform Change Password', 'The subject of the Forgotten Password email', '2008-06-04 21:11:08.788441');
INSERT INTO public.tbs_systemdefault VALUES (13, 'G', 'FP_HTMLBODY', 'Dear #NAME#,<br>
To reset your password, either click the link below or
copy and paste the link in a browser.<br>
<a href=''#LINK#'' target=''_blank'' >#LINK#</a>
<br>Thank You.', 'The body of the system email sent to a user who has forgotten his password.
Please note that #NAME# and #LINK# would be substituted with the respective
Name and Web Link. This field may contain html tags', '2008-06-15 14:28:28.592137');
INSERT INTO public.tbs_systemdefault VALUES (14, 'G', 'FP_TEXTBODY', 'Dear #NAME#,
To reset your password, either click the link below or
copy and paste the link in a browser.
#LINK#
<br>Thank you', 'The body of the system email sent to a user who has forgotten his password.
Please note that #NAME# and #LINK# would be substituted with the respective
Name and Web Link. This field may contain html tags', '2008-06-15 14:29:09.081973');
INSERT INTO public.tbs_systemdefault VALUES (15, 'G', 'INST_CODE', '05', 'Intitutional Code of the College', '2011-08-14 19:54:41.753467');
INSERT INTO public.tbs_systemdefault VALUES (30, 'G', 'ADMLET_REF', '332', 'Admission Letter Ref', '2011-08-14 19:40:44.121233');
INSERT INTO public.tbs_systemdefault VALUES (19, 'G', 'ADM_THRORIG', '5', 'Admission ', '2011-08-17 16:20:05.52028');
INSERT INTO public.tbs_systemdefault VALUES (37, 'G', 'ADM_DEFEXAMTYPEID', '1', 'Admission Default ExamtypeId (Used for EQV)', '2012-07-16 15:27:24.040031');
INSERT INTO public.tbs_systemdefault VALUES (18, 'G', 'ADM_MAXOPCORES', '1', 'Maximum number of optional core subjects used in admission processing', '2013-06-12 13:35:36.903263');
INSERT INTO public.tbs_systemdefault VALUES (38, 'G', 'ADM_CURROFFSET', '150001', 'Admission Current Offset for Candidate IDs', '2015-04-27 14:34:32.898496');
INSERT INTO public.tbs_systemdefault VALUES (20, 'G', 'ADM_THREQUIV', '8', 'Admission ', '2015-07-27 10:12:12.077568');
INSERT INTO public.tbs_systemdefault VALUES (42, 'G', 'FEE_RATIO', '0.5', 'Ratio of minimum:total fee', '2015-09-22 15:22:00.797938');
INSERT INTO public.tbs_systemdefault VALUES (46, 'G', 'APPLICATION_YEAR', '2015', 'Application Year', '2015-10-13 12:45:40.931438');
INSERT INTO public.tbs_systemdefault VALUES (40, 'G', 'ADM_EQFAILMARK', '9', 'Global Equivalent Fail Mark', '2015-07-27 10:29:10.673331');
INSERT INTO public.tbs_systemdefault VALUES (45, 'G', 'ADM_DEADLINE_WEEKS', '1', 'Weeks before deadline', '2015-10-01 12:13:36.053358');
INSERT INTO public.tbs_systemdefault VALUES (44, 'G', 'FINANCIAL_YEAR', '2015', 'Current Financial Year', '2016-01-06 10:10:47.630206');
INSERT INTO public.tbs_systemdefault VALUES (39, 'G', 'ADM_EQPASSMARK', '8', 'Global Equivalent Pass Mark', '2015-07-27 09:49:37.129098');
INSERT INTO public.tbs_systemdefault VALUES (43, 'G', 'ADMISSION_YEAR', '2015', 'Current Admission Year', '2015-12-22 13:12:38.202083');
INSERT INTO public.tbs_systemdefault VALUES (31, 'G', 'ADMLET_SALUTATION', 'High', 'Admission Letter Salutation', '2016-04-10 16:57:54.163883');
INSERT INTO public.tbs_systemdefault VALUES (17, 'G', 'INTEREST_RATE', '0.03', 'Total subjects required for admission processing', '2017-06-30 21:06:32.629762');
INSERT INTO public.tbs_systemdefault VALUES (41, 'G', 'CURRENT_YEAR', '2017', 'Current Academic Year', '2017-07-02 05:08:04.15832');
INSERT INTO public.tbs_systemdefault VALUES (25, 'G', 'ADMLET_TITLE', 'STS', 'Admission Letter TItle', '2017-12-29 05:19:12.906003');
INSERT INTO public.tbs_systemdefault VALUES (21, 'G', 'ADM_NOTIFY', '8878787', NULL, '2017-12-29 05:19:16.13256');
INSERT INTO public.tbs_systemdefault VALUES (26, 'G', 'ADMLET_CONTACT', 're', 'Admission Letter Contact', '2017-12-29 05:19:22.721589');
INSERT INTO public.tbs_systemdefault VALUES (27, 'G', 'ADMLET_ADDRESS', 'gghhgg', 'Admission Letter Address', '2017-12-29 05:19:26.18407');
INSERT INTO public.tbs_systemdefault VALUES (28, 'G', 'ADMLET_TEL', '454554', 'Admission Letter Tel', '2017-12-29 05:19:30.804935');
INSERT INTO public.tbs_systemdefault VALUES (29, 'G', 'ADMLET_FAX', '454545', 'Admission Letter Fax', '2017-12-29 05:19:34.291825');
INSERT INTO public.tbs_systemdefault VALUES (32, 'G', 'ADMLET_SIGNAME', 'hghghg', 'Admission Letter Signature Name', '2017-12-29 05:19:41.023183');
INSERT INTO public.tbs_systemdefault VALUES (33, 'G', 'ADMLET_SIGTITLE', 'hjhjhj', 'Admission Letter Signature Title', '2017-12-29 05:19:43.324191');
INSERT INTO public.tbs_systemdefault VALUES (34, 'G', 'ADMLET_REOPEN', 'hhhghg', 'Date School Reopens', '2017-12-29 05:19:45.924239');
INSERT INTO public.tbs_systemdefault VALUES (35, 'G', 'ADMLET_BANKNAME', 'hjhj', 'Admission Letter Bank Name', '2017-12-29 05:19:50.422583');
INSERT INTO public.tbs_systemdefault VALUES (36, 'G', 'ADMLET_BANKACCOUNT', '676676', 'Admission Letter Bank Account', '2017-12-29 05:19:54.853962');
INSERT INTO public.tbs_systemdefault VALUES (47, 'G', 'VISALET_SIGNAME', 'hghghghg', NULL, '2017-12-29 05:20:02.992969');
INSERT INTO public.tbs_systemdefault VALUES (48, 'G', 'VISALET_NAMETITLE', 'gfgfgfgfgf', NULL, '2017-12-29 05:20:05.301162');
INSERT INTO public.tbs_systemdefault VALUES (49, 'G', 'VISALET_SIGTITLE', 'yuyuyuyuyu', NULL, '2017-12-29 05:20:07.539671');
INSERT INTO public.tbs_systemdefault VALUES (50, 'G', 'ILO_SIGNAME', '343', NULL, '2017-12-29 05:20:23.907015');
INSERT INTO public.tbs_systemdefault VALUES (56, 'G', 'ILO_END', 'fdfdf', NULL, '2017-12-29 05:20:33.283779');
INSERT INTO public.tbs_systemdefault VALUES (51, 'G', 'ILO_CONTACT', '343', NULL, '2017-12-29 05:20:22.018782');
INSERT INTO public.tbs_systemdefault VALUES (52, 'G', 'ILO_FAX', '34343', NULL, '2017-12-29 05:20:25.932054');
INSERT INTO public.tbs_systemdefault VALUES (53, 'G', 'ILO_EMAIL', '343434', NULL, '2017-12-29 05:20:27.598542');
INSERT INTO public.tbs_systemdefault VALUES (54, 'G', 'ILO_TITLE', 'dffdf', NULL, '2017-12-29 05:20:29.912899');
INSERT INTO public.tbs_systemdefault VALUES (55, 'G', 'ILO_BEGIN', 'fdfdf', NULL, '2017-12-29 05:20:31.614932');
INSERT INTO public.tbs_systemdefault VALUES (67, 'G', 'ILO_SIGTITLE', 'dfdf', NULL, '2017-12-29 05:20:35.296331');
INSERT INTO public.tbs_systemdefault VALUES (72, 'G', 'RESIT_FEE', '30', 'ewewew', '2017-12-29 05:20:56.421109');
INSERT INTO public.tbs_systemdefault VALUES (70, 'G', 'NABPTEX_LIAISON', '45', 'fdgdfgd', '2017-12-29 05:20:50.460378');
INSERT INTO public.tbs_systemdefault VALUES (71, 'G', 'RESIT_OPEN', '1', 'dfdfdf', '2017-12-29 05:20:54.18691');
INSERT INTO public.tbs_systemdefault VALUES (5, 'G', 'MAIL_FROM', 'dfdfd', 'Email address from which the message will be sent.', '2017-12-29 05:21:08.84794');
INSERT INTO public.tbs_systemdefault VALUES (68, 'G', 'RESULT_CHECKING', '1', 'yyt', '2017-12-29 05:21:37.291301');


--
-- TOC entry 3757 (class 0 OID 58273)
-- Dependencies: 205
-- Data for Name: tbs_user; Type: TABLE DATA; Schema: public; Owner: kpuser
--

INSERT INTO public.tbs_user VALUES (-1, 1, 'Unknown User', '*', 'unknown', '1a456756d45bb', 0, NULL, 0, '2010-10-20 14:40:11.167032', '2010-10-20 14:40:11.167032', '2010-10-20 14:40:11.167032', NULL, NULL, 'unknown@platform.com', NULL, 0, 0, '2018-04-06 01:48:36.58438', NULL, NULL, 1, 1);
INSERT INTO public.tbs_user VALUES (0, 0, 'Guest User', '*', 'guest', '1a456756d45bb', 0, NULL, 1, '2010-10-20 14:40:11.167032', '2010-10-20 14:40:11.167032', '2010-10-20 14:40:11.167032', NULL, NULL, 'onliner@platform.com', NULL, 0, 0, '2018-04-06 01:48:37.52847', NULL, NULL, 1, 1);
INSERT INTO public.tbs_user VALUES (1, 1, 'Super User', '*', 'superuser', 'e1e08b7f279f2ad7ad243135151deb97', 1, 'djvtieoo5a3791vs0b4m8idkm7', 1, '2010-10-20 14:40:11.167032', '2010-10-20 14:40:11.167032', '2016-04-14 11:22:45.829985', NULL, NULL, 'superuser@platform.com', NULL, 0, 1, '2018-04-06 01:48:38.280879', NULL, NULL, 1, 1);
INSERT INTO public.tbs_user VALUES (2, 1, 'Administrator', 'Admin', 'admin', 'b84d06eab9413d91259bea997b63d0c1', 2, 'baag75j7thbci6gjrhn8lm8uk6', 1, '2010-10-20 14:40:11.167032', '2010-10-20 14:40:11.167032', '2016-04-10 18:38:22.242742', '0277686939', NULL, 'admin@platform.com', 'None', 0, 1, '2018-04-06 01:48:38.865546', NULL, NULL, 1, 1);
INSERT INTO public.tbs_user VALUES (13, 1, 'Awusi', 'Awusi', 'aw', '0cc175b9c0f1b6a831c399e269772661', 3, 'j7qh3dk219ho7bbe18snc8svi7', 1, '2017-12-30 14:48:31.238428', '2017-12-30 14:48:31.238428', '2019-06-15 04:49:33.680416', '9879898', NULL, 'a@gmail.com', 'Accra', 0, 1, '2019-06-15 04:49:33.680416', NULL, 0, 2, 1);
INSERT INTO public.tbs_user VALUES (3, 1, 'tetteh', 'Allen', 'a', '0cc175b9c0f1b6a831c399e269772661', 2, 'rj5vj59c9qvm6969tkedqs8a76', 1, '2008-05-23 10:08:51.153977', '2008-05-23 10:08:51.153977', '2019-06-27 03:39:20.067437', '0277686939', NULL, 'alleneben@gmail.com', 'None', 0, 1, '2019-06-27 03:39:20.067437', 'allen.jpg', NULL, 20, 2);
INSERT INTO public.tbs_user VALUES (6, 1, 'Mercy', 'Mercy', 'mercy', '0cc175b9c0f1b6a831c399e269772661', 3, 'umgqs60g5s5cf9vg6m8s2g29f0', 1, '2016-04-10 00:00:00', '2016-04-10 00:00:00', '2019-04-06 15:02:56.807785', '000000', NULL, 'eric', NULL, 0, 0, '2019-06-15 05:19:30.538088', NULL, NULL, 20, 2);
INSERT INTO public.tbs_user VALUES (15, 1, 'asad', 'saas', 'a.nbnb', '25f9e794323b453885f5181f1b624d0b', 3, NULL, 1, '2017-12-30 14:49:13.517723', '2017-12-30 14:49:13.517723', '2017-12-30 14:49:13.517723', 'ghghgh', NULL, 'hghgh', 'hjhjhjh', 0, 0, '2019-06-15 05:19:47.54656', NULL, 0, 1, 1);
INSERT INTO public.tbs_user VALUES (4, 1, 'napoleon', 'napoleaon', 'n', '0cc175b9c0f1b6a831c399e269772661', 3, 'ln2r8fh52s5m2dbs5p1otrprv4', 1, '2016-04-10 17:58:47.600162', '2016-04-10 17:58:47.600162', '2019-06-15 02:03:13.576496', '00000000', NULL, 'naps@gmai.com', NULL, 0, 1, '2019-06-15 05:20:10.762187', 'sample.png', NULL, 20, 2);
INSERT INTO public.tbs_user VALUES (7, 1, 'Veronica', 'Veronica', 'v', '0cc175b9c0f1b6a831c399e269772661', 3, '6q2ik1idcurb6id75ugps7fp03', 1, '2017-09-12 00:00:00', '2017-09-12 00:00:00', '2019-06-15 04:45:24.460048', NULL, NULL, 'KHADIJAH', NULL, 0, 1, '2019-06-15 04:45:24.460048', NULL, NULL, 1, 2);


--
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 243
-- Name: tb_category_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_category_recid_seq', 20, true);


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 245
-- Name: tb_country_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tb_country_recid_seq', 1, false);


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 246
-- Name: tb_currency_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_currency_recid_seq', 1, false);


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 248
-- Name: tb_district_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tb_district_recid_seq', 1, false);


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 252
-- Name: tb_enquiry_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_enquiry_recid_seq', 1, false);


--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 254
-- Name: tb_idtype_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tb_idtype_recid_seq', 1, false);


--
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 255
-- Name: tb_issues_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_issues_recid_seq', 2, true);


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 256
-- Name: tb_moneypaid_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_moneypaid_recid_seq', 27, true);


--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 258
-- Name: tb_officeheld_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tb_officeheld_recid_seq', 1, false);


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 259
-- Name: tb_paymenttype_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_paymenttype_recid_seq', 1, false);


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 260
-- Name: tb_product_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_product_recid_seq', 592, true);


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 261
-- Name: tb_productlog_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_productlog_recid_seq', 214, true);


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 262
-- Name: tb_productstatus_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_productstatus_recid_seq', 1, false);


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 264
-- Name: tb_profession_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tb_profession_recid_seq', 1, false);


--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 265
-- Name: tb_quotationtype_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_quotationtype_recid_seq', 1, false);


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 267
-- Name: tb_region_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tb_region_recid_seq', 1, false);


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 269
-- Name: tb_relationship_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tb_relationship_recid_seq', 1, false);


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 271
-- Name: tb_residentype_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tb_residentype_recid_seq', 1, false);


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 272
-- Name: tb_sales_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_sales_recid_seq', 402, true);


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 273
-- Name: tb_salescode_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_salescode_recid_seq', 200, true);


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 274
-- Name: tb_savings_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_savings_recid_seq', 59, true);


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 275
-- Name: tb_section_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_section_recid_seq', 1, false);


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 276
-- Name: tb_shop_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_shop_recid_seq', 1, false);


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 306
-- Name: tb_unit_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_unit_recid_seq', 1, false);


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 277
-- Name: tbs_audittrail_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tbs_audittrail_recid_seq', 75, true);


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 278
-- Name: tbs_entity_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tbs_entity_recid_seq', 1, false);


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 279
-- Name: tbs_entitytype_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tbs_entitytype_recid_seq', 1, false);


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 282
-- Name: tbs_inbox_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tbs_inbox_recid_seq', 1, false);


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 283
-- Name: tbs_role_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tbs_role_recid_seq', 5, true);


--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 285
-- Name: tbs_user_recid_seq; Type: SEQUENCE SET; Schema: public; Owner: kpuser
--

SELECT pg_catalog.setval('public.tbs_user_recid_seq', 15, true);


--
-- TOC entry 3485 (class 2606 OID 58854)
-- Name: tbs_audittrail pkey_audittrail_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_audittrail
    ADD CONSTRAINT pkey_audittrail_recid PRIMARY KEY (recid);


--
-- TOC entry 3458 (class 2606 OID 58856)
-- Name: tb_category pkey_category_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_category
    ADD CONSTRAINT pkey_category_recid PRIMARY KEY (recid);


--
-- TOC entry 3506 (class 2606 OID 58858)
-- Name: tb_country pkey_country_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_country
    ADD CONSTRAINT pkey_country_recid PRIMARY KEY (recid);


--
-- TOC entry 3464 (class 2606 OID 58860)
-- Name: tb_currency pkey_currency_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_currency
    ADD CONSTRAINT pkey_currency_recid PRIMARY KEY (recid);


--
-- TOC entry 3512 (class 2606 OID 58862)
-- Name: tb_education pkey_education_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_education
    ADD CONSTRAINT pkey_education_recid PRIMARY KEY (recid);


--
-- TOC entry 3514 (class 2606 OID 58864)
-- Name: tb_emprank pkey_emprank_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_emprank
    ADD CONSTRAINT pkey_emprank_recid PRIMARY KEY (recid);


--
-- TOC entry 3517 (class 2606 OID 58866)
-- Name: tb_empstatus pkey_empstatus_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_empstatus
    ADD CONSTRAINT pkey_empstatus_recid PRIMARY KEY (recid);


--
-- TOC entry 3467 (class 2606 OID 58868)
-- Name: tb_enquiry pkey_enquiry_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_enquiry
    ADD CONSTRAINT pkey_enquiry_recid PRIMARY KEY (recid);


--
-- TOC entry 3488 (class 2606 OID 58870)
-- Name: tbs_entity pkey_entity; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_entity
    ADD CONSTRAINT pkey_entity PRIMARY KEY (recid);


--
-- TOC entry 3491 (class 2606 OID 58872)
-- Name: tbs_entitytype pkey_entitytype_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_entitytype
    ADD CONSTRAINT pkey_entitytype_recid PRIMARY KEY (recid);


--
-- TOC entry 3537 (class 2606 OID 58874)
-- Name: tbs_error pkey_error_errorid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_error
    ADD CONSTRAINT pkey_error_errorid PRIMARY KEY (errorid);


--
-- TOC entry 3519 (class 2606 OID 58876)
-- Name: tb_idtype pkey_idtype_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_idtype
    ADD CONSTRAINT pkey_idtype_recid PRIMARY KEY (recid);


--
-- TOC entry 3539 (class 2606 OID 58878)
-- Name: tbs_inbox pkey_inbox_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_inbox
    ADD CONSTRAINT pkey_inbox_recid PRIMARY KEY (recid);


--
-- TOC entry 3476 (class 2606 OID 58880)
-- Name: tb_issues pkey_issues_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_issues
    ADD CONSTRAINT pkey_issues_recid PRIMARY KEY (recid);


--
-- TOC entry 3438 (class 2606 OID 58882)
-- Name: tb_member pkey_member_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_member
    ADD CONSTRAINT pkey_member_recid PRIMARY KEY (recid);


--
-- TOC entry 3478 (class 2606 OID 58884)
-- Name: tb_moneypaid pkey_moneypaidcode_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_moneypaid
    ADD CONSTRAINT pkey_moneypaidcode_recid PRIMARY KEY (recid);


--
-- TOC entry 3440 (class 2606 OID 58886)
-- Name: tb_paymenttype pkey_paymenttype_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_paymenttype
    ADD CONSTRAINT pkey_paymenttype_recid PRIMARY KEY (recid);


--
-- TOC entry 3497 (class 2606 OID 58888)
-- Name: tbs_privilege pkey_privilege_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_privilege
    ADD CONSTRAINT pkey_privilege_recid PRIMARY KEY (recid);


--
-- TOC entry 3444 (class 2606 OID 58890)
-- Name: tb_product pkey_product_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_product
    ADD CONSTRAINT pkey_product_recid PRIMARY KEY (recid);


--
-- TOC entry 3482 (class 2606 OID 58892)
-- Name: tb_productlog pkey_productlog_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_productlog
    ADD CONSTRAINT pkey_productlog_recid PRIMARY KEY (recid);


--
-- TOC entry 3525 (class 2606 OID 58894)
-- Name: tb_profession pkey_profession_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_profession
    ADD CONSTRAINT pkey_profession_recid PRIMARY KEY (recid);


--
-- TOC entry 3473 (class 2606 OID 58896)
-- Name: tb_quotationtype pkey_quotationtype_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_quotationtype
    ADD CONSTRAINT pkey_quotationtype_recid PRIMARY KEY (recid);


--
-- TOC entry 3527 (class 2606 OID 58898)
-- Name: tb_region pkey_region_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_region
    ADD CONSTRAINT pkey_region_recid PRIMARY KEY (recid);


--
-- TOC entry 3530 (class 2606 OID 58900)
-- Name: tb_relationship pkey_relationship_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_relationship
    ADD CONSTRAINT pkey_relationship_recid PRIMARY KEY (recid);


--
-- TOC entry 3533 (class 2606 OID 58902)
-- Name: tb_residenttype pkey_residentype_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_residenttype
    ADD CONSTRAINT pkey_residentype_recid PRIMARY KEY (recid);


--
-- TOC entry 3494 (class 2606 OID 58904)
-- Name: tbs_role pkey_role_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_role
    ADD CONSTRAINT pkey_role_recid PRIMARY KEY (recid);


--
-- TOC entry 3448 (class 2606 OID 58906)
-- Name: tb_salescode pkey_sales_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_salescode
    ADD CONSTRAINT pkey_sales_recid PRIMARY KEY (recid);


--
-- TOC entry 3446 (class 2606 OID 58908)
-- Name: tb_sales pkey_salescode_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_sales
    ADD CONSTRAINT pkey_salescode_recid PRIMARY KEY (recid);


--
-- TOC entry 3450 (class 2606 OID 58910)
-- Name: tb_savings pkey_savingscode_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_savings
    ADD CONSTRAINT pkey_savingscode_recid PRIMARY KEY (recid);


--
-- TOC entry 3480 (class 2606 OID 58912)
-- Name: tb_section pkey_section_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_section
    ADD CONSTRAINT pkey_section_recid PRIMARY KEY (recid);


--
-- TOC entry 3541 (class 2606 OID 58914)
-- Name: tbs_session pkey_session_sessionid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_session
    ADD CONSTRAINT pkey_session_sessionid PRIMARY KEY (sessionid);


--
-- TOC entry 3462 (class 2606 OID 58916)
-- Name: tb_shop pkey_shop_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_shop
    ADD CONSTRAINT pkey_shop_recid PRIMARY KEY (recid);


--
-- TOC entry 3460 (class 2606 OID 58918)
-- Name: tb_productstatus pkey_status_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_productstatus
    ADD CONSTRAINT pkey_status_recid PRIMARY KEY (recid);


--
-- TOC entry 3503 (class 2606 OID 58920)
-- Name: tbs_systemdefault pkey_systemdefault_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_systemdefault
    ADD CONSTRAINT pkey_systemdefault_recid PRIMARY KEY (recid);


--
-- TOC entry 3510 (class 2606 OID 58922)
-- Name: tb_district pkey_tb_district; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_district
    ADD CONSTRAINT pkey_tb_district PRIMARY KEY (recid);


--
-- TOC entry 3543 (class 2606 OID 59090)
-- Name: tb_unit pkey_unit_recid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_unit
    ADD CONSTRAINT pkey_unit_recid PRIMARY KEY (recid);


--
-- TOC entry 3454 (class 2606 OID 58924)
-- Name: tbs_user pkey_user_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_user
    ADD CONSTRAINT pkey_user_recid PRIMARY KEY (recid);


--
-- TOC entry 3523 (class 2606 OID 58926)
-- Name: tb_officeheld pkeyofficeheld_recid; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_officeheld
    ADD CONSTRAINT pkeyofficeheld_recid PRIMARY KEY (recid);


--
-- TOC entry 3452 (class 2606 OID 58928)
-- Name: tb_savings savings_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_savings
    ADD CONSTRAINT savings_code UNIQUE (savingscode);


--
-- TOC entry 3499 (class 2606 OID 58930)
-- Name: tbs_privilege ucon_privilege_menuorder; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_privilege
    ADD CONSTRAINT ucon_privilege_menuorder UNIQUE (menuorder);


--
-- TOC entry 3501 (class 2606 OID 58932)
-- Name: tbs_privilege ucon_privilege_shortcode; Type: CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_privilege
    ADD CONSTRAINT ucon_privilege_shortcode UNIQUE (shortcode);


--
-- TOC entry 3469 (class 2606 OID 58934)
-- Name: tb_enquiry unc_enquiry_no; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_enquiry
    ADD CONSTRAINT unc_enquiry_no UNIQUE (enquiryno);


--
-- TOC entry 3471 (class 2606 OID 58936)
-- Name: tb_enquiry unc_quotation_no; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_enquiry
    ADD CONSTRAINT unc_quotation_no UNIQUE (quotationno);


--
-- TOC entry 3483 (class 1259 OID 58937)
-- Name: fkey_audittrail_userid; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE INDEX fkey_audittrail_userid ON public.tbs_audittrail USING btree (userid);


--
-- TOC entry 3486 (class 1259 OID 58938)
-- Name: uidx_audittrail_record; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE INDEX uidx_audittrail_record ON public.tbs_audittrail USING gin (to_tsvector('english'::regconfig, arecord));


--
-- TOC entry 3507 (class 1259 OID 58939)
-- Name: uidx_country_name; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_country_name ON public.tb_country USING btree (upper((recname)::text));


--
-- TOC entry 3508 (class 1259 OID 58940)
-- Name: uidx_country_shortcode; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_country_shortcode ON public.tb_country USING btree (upper((shortcode)::text));


--
-- TOC entry 3465 (class 1259 OID 58941)
-- Name: uidx_currency_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uidx_currency_name ON public.tb_currency USING btree (upper((recname)::text));


--
-- TOC entry 3515 (class 1259 OID 58942)
-- Name: uidx_emprank_name; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_emprank_name ON public.tb_emprank USING btree (upper((recname)::text));


--
-- TOC entry 3489 (class 1259 OID 58943)
-- Name: uidx_entity_name; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_entity_name ON public.tbs_entity USING btree (upper((recname)::text));


--
-- TOC entry 3492 (class 1259 OID 58944)
-- Name: uidx_entitytype_name; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_entitytype_name ON public.tbs_entitytype USING btree (upper((recname)::text));


--
-- TOC entry 3520 (class 1259 OID 58945)
-- Name: uidx_idtype_name; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_idtype_name ON public.tb_idtype USING btree (upper((recname)::text));


--
-- TOC entry 3521 (class 1259 OID 58946)
-- Name: uidx_idtype_shortcode; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_idtype_shortcode ON public.tb_idtype USING btree (upper((shortcode)::text));


--
-- TOC entry 3441 (class 1259 OID 58947)
-- Name: uidx_paymenttype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uidx_paymenttype_name ON public.tb_paymenttype USING btree (upper((recname)::text));


--
-- TOC entry 3442 (class 1259 OID 58948)
-- Name: uidx_paymenttype_shortcode; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uidx_paymenttype_shortcode ON public.tb_paymenttype USING btree (upper((shortcode)::text));


--
-- TOC entry 3474 (class 1259 OID 58949)
-- Name: uidx_quotationtype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uidx_quotationtype_name ON public.tb_quotationtype USING btree (upper((recname)::text));


--
-- TOC entry 3528 (class 1259 OID 58950)
-- Name: uidx_region_name; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_region_name ON public.tb_region USING btree (upper((recname)::text));


--
-- TOC entry 3531 (class 1259 OID 58951)
-- Name: uidx_relationship_name; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_relationship_name ON public.tb_relationship USING btree (upper((recname)::text));


--
-- TOC entry 3534 (class 1259 OID 58952)
-- Name: uidx_residentype_name; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_residentype_name ON public.tb_residenttype USING btree (upper((recname)::text));


--
-- TOC entry 3535 (class 1259 OID 58953)
-- Name: uidx_residentype_shortcode; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_residentype_shortcode ON public.tb_residenttype USING btree (upper((shortcode)::text));


--
-- TOC entry 3495 (class 1259 OID 58954)
-- Name: uidx_role_name; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_role_name ON public.tbs_role USING btree (upper((recname)::text));


--
-- TOC entry 3504 (class 1259 OID 58955)
-- Name: uidx_systemdefault_reckey; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_systemdefault_reckey ON public.tbs_systemdefault USING btree (upper((reckey)::text));


--
-- TOC entry 3455 (class 1259 OID 58956)
-- Name: uidx_user_email; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_user_email ON public.tbs_user USING btree (upper((email)::text));


--
-- TOC entry 3456 (class 1259 OID 58957)
-- Name: uidx_user_username; Type: INDEX; Schema: public; Owner: kpuser
--

CREATE UNIQUE INDEX uidx_user_username ON public.tbs_user USING btree (upper((username)::text));


--
-- TOC entry 3573 (class 2620 OID 58958)
-- Name: tb_country tg_country_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_country_cc BEFORE UPDATE ON public.tb_country FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3574 (class 2620 OID 58959)
-- Name: tb_education tg_education_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_education_cc BEFORE UPDATE ON public.tb_education FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3575 (class 2620 OID 58960)
-- Name: tb_emprank tg_emprank_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_emprank_cc BEFORE UPDATE ON public.tb_emprank FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3576 (class 2620 OID 58961)
-- Name: tb_empstatus tg_empstatus_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_empstatus_cc BEFORE UPDATE ON public.tb_empstatus FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3568 (class 2620 OID 58962)
-- Name: tbs_entity tg_entity_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_entity_cc BEFORE UPDATE ON public.tbs_entity FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3569 (class 2620 OID 58963)
-- Name: tbs_entitytype tg_entitytype_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_entitytype_cc BEFORE UPDATE ON public.tbs_entitytype FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3577 (class 2620 OID 58964)
-- Name: tb_idtype tg_idtype_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_idtype_cc BEFORE UPDATE ON public.tb_idtype FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3566 (class 2620 OID 58965)
-- Name: tb_paymenttype tg_idtype_cc; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_idtype_cc BEFORE UPDATE ON public.tb_paymenttype FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3578 (class 2620 OID 58966)
-- Name: tb_officeheld tg_officeheld_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_officeheld_cc BEFORE UPDATE ON public.tb_officeheld FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3571 (class 2620 OID 58967)
-- Name: tbs_privilege tg_privilege_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_privilege_cc BEFORE UPDATE ON public.tbs_privilege FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3579 (class 2620 OID 58968)
-- Name: tb_profession tg_profession_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_profession_cc BEFORE UPDATE ON public.tb_profession FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3580 (class 2620 OID 58969)
-- Name: tb_region tg_region_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_region_cc BEFORE UPDATE ON public.tb_region FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3581 (class 2620 OID 58970)
-- Name: tb_relationship tg_relationship_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_relationship_cc BEFORE UPDATE ON public.tb_relationship FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3582 (class 2620 OID 58971)
-- Name: tb_residenttype tg_residentype_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_residentype_cc BEFORE UPDATE ON public.tb_residenttype FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3570 (class 2620 OID 58972)
-- Name: tbs_role tg_role_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_role_cc BEFORE UPDATE ON public.tbs_role FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3572 (class 2620 OID 58973)
-- Name: tbs_systemdefault tg_systemdefault_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_systemdefault_cc BEFORE UPDATE ON public.tbs_systemdefault FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3567 (class 2620 OID 58974)
-- Name: tbs_user tg_user_cc; Type: TRIGGER; Schema: public; Owner: kpuser
--

CREATE TRIGGER tg_user_cc BEFORE UPDATE ON public.tbs_user FOR EACH ROW EXECUTE PROCEDURE public.check_concurrency();


--
-- TOC entry 3563 (class 2606 OID 58975)
-- Name: tbs_audittrail fkey_audittrail_userid; Type: FK CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_audittrail
    ADD CONSTRAINT fkey_audittrail_userid FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3545 (class 2606 OID 58980)
-- Name: tb_product fkey_category_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_product
    ADD CONSTRAINT fkey_category_product FOREIGN KEY (categoryid) REFERENCES public.tb_category(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3565 (class 2606 OID 58985)
-- Name: tbs_inbox fkey_inbox_userid; Type: FK CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_inbox
    ADD CONSTRAINT fkey_inbox_userid FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3551 (class 2606 OID 58990)
-- Name: tb_savings fkey_member_savings; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_savings
    ADD CONSTRAINT fkey_member_savings FOREIGN KEY (memberid) REFERENCES public.tb_member(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3548 (class 2606 OID 59099)
-- Name: tb_product fkey_product_unit; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_product
    ADD CONSTRAINT fkey_product_unit FOREIGN KEY (unit) REFERENCES public.tb_unit(recid);


--
-- TOC entry 3560 (class 2606 OID 58995)
-- Name: tb_productlog fkey_productlog_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_productlog
    ADD CONSTRAINT fkey_productlog_product FOREIGN KEY (productid) REFERENCES public.tb_product(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3549 (class 2606 OID 59000)
-- Name: tb_sales fkey_salescode_sales; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_sales
    ADD CONSTRAINT fkey_salescode_sales FOREIGN KEY (salescodeid) REFERENCES public.tb_salescode(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3554 (class 2606 OID 59005)
-- Name: tb_category fkey_section_category; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_category
    ADD CONSTRAINT fkey_section_category FOREIGN KEY (sectionid) REFERENCES public.tb_section(recid);


--
-- TOC entry 3546 (class 2606 OID 59010)
-- Name: tb_product fkey_status_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_product
    ADD CONSTRAINT fkey_status_product FOREIGN KEY (productstatusid) REFERENCES public.tb_productstatus(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3558 (class 2606 OID 59015)
-- Name: tb_issues fkey_user_issues; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_issues
    ADD CONSTRAINT fkey_user_issues FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3544 (class 2606 OID 59020)
-- Name: tb_member fkey_user_member; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_member
    ADD CONSTRAINT fkey_user_member FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3547 (class 2606 OID 59025)
-- Name: tb_product fkey_user_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_product
    ADD CONSTRAINT fkey_user_product FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3561 (class 2606 OID 59030)
-- Name: tb_productlog fkey_user_productlog; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_productlog
    ADD CONSTRAINT fkey_user_productlog FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3553 (class 2606 OID 59035)
-- Name: tbs_user fkey_user_roleid; Type: FK CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tbs_user
    ADD CONSTRAINT fkey_user_roleid FOREIGN KEY (roleid) REFERENCES public.tbs_role(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3550 (class 2606 OID 59040)
-- Name: tb_salescode fkey_user_sales; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_salescode
    ADD CONSTRAINT fkey_user_sales FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3552 (class 2606 OID 59045)
-- Name: tb_savings fkey_user_savings; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_savings
    ADD CONSTRAINT fkey_user_savings FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3559 (class 2606 OID 59050)
-- Name: tb_moneypaid fkey_usere_moneypaid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_moneypaid
    ADD CONSTRAINT fkey_usere_moneypaid FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3562 (class 2606 OID 59055)
-- Name: tb_productlog shopid_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_productlog
    ADD CONSTRAINT shopid_product FOREIGN KEY (shopid) REFERENCES public.tb_shop(recid);


--
-- TOC entry 3555 (class 2606 OID 59060)
-- Name: tb_enquiry tb_enquiry_tb_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_enquiry
    ADD CONSTRAINT tb_enquiry_tb_currency_fkey FOREIGN KEY (currencyid) REFERENCES public.tb_currency(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3556 (class 2606 OID 59065)
-- Name: tb_enquiry tb_enquiry_tb_quotationtype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_enquiry
    ADD CONSTRAINT tb_enquiry_tb_quotationtype_fkey FOREIGN KEY (quotationtypeid) REFERENCES public.tb_quotationtype(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3557 (class 2606 OID 59070)
-- Name: tb_enquiry tb_enquiry_tb_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_enquiry
    ADD CONSTRAINT tb_enquiry_tb_user_fkey FOREIGN KEY (userid) REFERENCES public.tbs_user(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3564 (class 2606 OID 59075)
-- Name: tb_district tb_region_tb_district_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kpuser
--

ALTER TABLE ONLY public.tb_district
    ADD CONSTRAINT tb_region_tb_district_fkey FOREIGN KEY (regionid) REFERENCES public.tb_region(recid) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Completed on 2019-06-27 03:48:23 EDT

--
-- PostgreSQL database dump complete
--

