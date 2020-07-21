drop table sa_calendar;
create table sa_calendar as 
SELECT 
CAST((TO_CHAR(sd+rn , 'MM')||TO_CHAR(sd+rn , 'DD')||TO_CHAR(sd+rn , 'YYYY') ) AS INTEGER) date_id,
  TRUNC( sd + rn ) day_vchar_id,
  TO_CHAR( sd + rn, 'fmDay' ) day_name,
  TO_CHAR( sd + rn, 'D' ) day_number_in_week,
  TO_CHAR( sd + rn, 'DD' ) day_number_in_month,
  TO_CHAR( sd + rn, 'DDD' ) day_number_in_year,
  TO_CHAR( sd + rn, 'W' ) calendar_week_number,
  ( CASE
      WHEN TO_CHAR( sd + rn, 'D' ) IN (  1, 2, 3, 4, 5, 6 ) THEN
        NEXT_DAY( sd + rn, 'SUNDAY')
      ELSE
        ( sd + rn )
    END ) week_ending_date,
  TO_CHAR( sd + rn, 'MM' ) calendar_month_number,
  TO_CHAR( LAST_DAY( sd + rn ), 'DD' ) days_in_cal_month,
  LAST_DAY( sd + rn ) end_of_cal_month,
  TO_CHAR( sd + rn, 'FMMonth' ) calendar_month_name,
  ( ( CASE
      WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
        TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
        TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
        TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
        TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    END ) - TRUNC( sd + rn, 'Q' ) + 1 ) days_in_cal_quarter,
  TRUNC( sd + rn, 'Q' ) beg_of_cal_quarter,
  ( CASE
      WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
        TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
        TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
        TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
      WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
        TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    END ) end_of_cal_quarter,
  TO_CHAR( sd + rn, 'Q' ) calendar_quarter_number,
  TO_CHAR( sd + rn, 'YYYY' ) calendar_year,
  ( TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    - TRUNC( sd + rn, 'YEAR' ) ) days_in_cal_year,
  TRUNC( sd + rn, 'YEAR' ) beg_of_cal_year,
  TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' ) end_of_cal_year
FROM
  ( 
    SELECT 
      TO_DATE( '12/31/2018', 'MM/DD/YYYY' ) sd,
      rownum rn
    FROM dual
      CONNECT BY level <= 1825
  );

select * from sa_calendar;

drop table t_day;
create table t_day  as 
    select  c.DATE_ID , 
            c.DAY_VCHAR_ID,
            c.DAY_NAME,
            c.DAY_NUMBER_IN_WEEK,
            c.DAY_NUMBER_IN_MONTH,
            c.DAY_NUMBER_IN_YEAR
    from sa_calendar c;
    
  select * from t_day order by date_id desc;   
drop table t_week;
create table t_week  as 
    select  c.DATE_ID week_id,
            c.WEEK_ENDING_DATE-6 BEG_WEEK_DATE,
            c.WEEK_ENDING_DATE END_WEEK_DATE, 
            c.CALENDAR_WEEK_NUMBER            
    from sa_calendar c 
    where c.date_id=CAST((TO_CHAR(WEEK_ENDING_DATE , 'MM')||TO_CHAR(WEEK_ENDING_DATE , 'DD')||TO_CHAR(WEEK_ENDING_DATE , 'YYYY') ) AS INTEGER);    

 
drop table t_month;
create table t_month as 
    select 
    c.date_id month_id,
    c.CALENDAR_MONTH_NAME,
    c.CALENDAR_MONTH_NUMBER,
    c.DAYS_IN_CAL_MONTH,
    c.END_OF_CAL_MONTH - c.DAYS_IN_CAL_MONTH+1 as BEG_OF_CAL_MONTH,
    c.END_OF_CAL_MONTH    
    from sa_calendar c
    where c.date_id=CAST((TO_CHAR(END_OF_CAL_MONTH , 'MM')||TO_CHAR(END_OF_CAL_MONTH , 'DD')||TO_CHAR(END_OF_CAL_MONTH , 'YYYY') ) AS INTEGER);    

select * from t_month;

drop table t_quarter;
create table t_quarter as 
    select 
        c.date_id as quarter_id,
        c.CALENDAR_QUARTER_NUMBER,
        c.DAYS_IN_CAL_QUARTER,
        c.BEG_OF_CAL_QUARTER,
        c.END_OF_CAL_QUARTER,
        c.calendar_year
    from sa_calendar c
    where c.date_id=CAST((TO_CHAR(BEG_OF_CAL_QUARTER , 'MM')||TO_CHAR(BEG_OF_CAL_QUARTER , 'DD')||TO_CHAR(BEG_OF_CAL_QUARTER , 'YYYY') ) AS INTEGER);    
select * from t_quarter;


drop table t_year;
create table t_year as
    select 
         c.date_id as year_id,
         c.CALENDAR_YEAR,
         c.DAYS_IN_CAL_YEAR,
         c.BEG_OF_CAL_YEAR,
         c.END_OF_CAL_YEAR
    from sa_calendar c
    where c.date_id=CAST((TO_CHAR(BEG_OF_CAL_YEAR , 'MM')||TO_CHAR(BEG_OF_CAL_YEAR , 'DD')||TO_CHAR(BEG_OF_CAL_YEAR , 'YYYY') ) AS INTEGER);    
    
select * from t_quarter;

--select * from t_day d, t_week w where d.DAY_VCHAR_ID between w.WEEK_BEGIN_DATE and w.WEEK_ENDING_DATE; --week day

select * from 
      t_day d
    , t_week w 
    , t_month m 
    , t_quarter q 
    , t_year y
where 
    (d.DAY_VCHAR_ID between w.beg_week_date and w.end_week_date )
    and (d.DAY_VCHAR_ID between m.beg_of_cal_month and m.END_OF_CAL_MONTH)
    and (d.DAY_VCHAR_ID between q.BEG_OF_CAL_QUARTER and q.end_of_cal_quarter)
    and (d.DAY_VCHAR_ID between y.BEG_OF_CAL_YEAR and y.END_OF_CAL_YEAR)
    order by DAY_VCHAR_ID;
/*
select  t_day.date_id ,
        t_week.end_week_id
from t_week , t_day 
group by  t_week.end_week_id, t_day.date_id 
 having t_day.date_id=t_week.end_week_id;
*/