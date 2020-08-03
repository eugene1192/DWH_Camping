create or REPLACE PACKAGE body load_t_dim_date
as 
        PROCEDURE loat_t_day AS
    BEGIN
        INSERT INTO u_dw_data.t_day
            SELECT
                c.date_id,
                c.day_vchar_id,
                c.day_name,
                c.day_number_in_week,
                c.day_number_in_month,
                c.day_number_in_year
            FROM
                u_dw_ext_app.sa_calendar c;
    COMMIT;
    END loat_t_day;

    PROCEDURE load_t_week AS
    BEGIN
        INSERT INTO u_dw_data.t_week
            SELECT
                c.date_id                 week_id,
                c.week_ending_date - 6      beg_week_date,
                c.week_ending_date        end_week_date,
                c.calendar_week_number
            FROM
                u_dw_ext_app.sa_calendar c
            WHERE
                c.date_id = CAST((to_char(week_ending_date, 'MM')
                                  || to_char(week_ending_date, 'DD')
                                  || to_char(week_ending_date, 'YYYY')) AS INTEGER);
    COMMIT;
    END load_t_week;
    
    PROCEDURE LOAD_T_MONTH
    AS
        BEGIN
            INSERT INTO u_dw_data.t_month 
                select 
                c.date_id month_id,
                c.CALENDAR_MONTH_NAME,
                c.CALENDAR_MONTH_NUMBER,
                c.DAYS_IN_CAL_MONTH,
                c.END_OF_CAL_MONTH - c.DAYS_IN_CAL_MONTH+1 as BEG_OF_CAL_MONTH,
                c.END_OF_CAL_MONTH    
                from u_dw_ext_app.sa_calendar c
                where 
                    c.date_id=CAST((TO_CHAR(END_OF_CAL_MONTH , 'MM')
                    ||TO_CHAR(END_OF_CAL_MONTH , 'DD')
                    ||TO_CHAR(END_OF_CAL_MONTH , 'YYYY') ) AS INTEGER);    
        COMMIT;
        END LOAD_T_MONTH;
        
        PROCEDURE LOAD_T_QARTER
            AS
                BEGIN
                INSERT INTO  u_dw_data.t_quarter 
                    select 
                        c.date_id as quarter_id,
                        c.CALENDAR_QUARTER_NUMBER,
                        c.DAYS_IN_CAL_QUARTER,
                        c.BEG_OF_CAL_QUARTER,
                        c.END_OF_CAL_QUARTER
                       from u_dw_ext_app.sa_calendar c
                    where
                        c.date_id=CAST((TO_CHAR(BEG_OF_CAL_QUARTER , 'MM')
                        ||TO_CHAR(BEG_OF_CAL_QUARTER , 'DD')
                        ||TO_CHAR(BEG_OF_CAL_QUARTER , 'YYYY') ) AS INTEGER);   
        COMMIT;
        END LOAD_T_QARTER;
        
        PROCEDURE LOAD_T_YEAR 
            AS
                BEGIN
                    INSERT INTO   u_dw_data.t_year 
                        select 
                             c.date_id as year_id,
                             c.CALENDAR_YEAR,
                             c.DAYS_IN_CAL_YEAR,
                             c.BEG_OF_CAL_YEAR,
                             c.END_OF_CAL_YEAR
                        from u_dw_ext_app.sa_calendar c
                        where 
                            c.date_id=CAST((TO_CHAR(BEG_OF_CAL_YEAR , 'MM')
                            ||TO_CHAR(BEG_OF_CAL_YEAR , 'DD')
                            ||TO_CHAR(BEG_OF_CAL_YEAR , 'YYYY') ) AS INTEGER);  
        COMMIT;
        END LOAD_T_YEAR;
        
        PROCEDURE LOAD_DIM_DATE
        AS
            BEGIN
                INSERT INTO u_dw_dim_tax.dim_date 
                    select * from 
                          u_dw_data.t_day d
                        , u_dw_data.t_week w 
                        , u_dw_data.t_month m 
                        , u_dw_data.t_quarter q 
                        , u_dw_data.t_year y
                    where 
                        (d.DAY_VCHAR_ID between w.beg_week_date and w.end_week_date )
                        and (d.DAY_VCHAR_ID between m.beg_of_cal_month and m.END_OF_CAL_MONTH)
                        and (d.DAY_VCHAR_ID between q.BEG_OF_CAL_QUARTER and q.end_of_cal_quarter)
                        and (d.DAY_VCHAR_ID between y.BEG_OF_CAL_YEAR and y.END_OF_CAL_YEAR)
                        order by DAY_VCHAR_ID;
        COMMIT;
        END LOAD_DIM_DATE;
END load_t_dim_date;