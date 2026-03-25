/* 1. Standardize ACS tables and add INDICATOR column */
proc sql;
    create table work.agesex_clean as
    select 
        variable as category,
        substr(NAME, 7) as ZCTA,
        'AGE_GENDER_GROUP' as INDICATOR,
        estimate as ESTIMATE
    from work.agesex;

    create table work.race_clean as
    select 
        variable as category,
        substr(NAME, 7) as ZCTA,
        'RACE_GROUP' as INDICATOR,
        estimate as ESTIMATE
    from work.race;

    create table work.ethnicity_clean as
    select 
        variable as category,
        substr(NAME, 7) as ZCTA,
        'ETHNICITY_GROUP' as INDICATOR,
        estimate as ESTIMATE
    from work.ethnicity;

    create table work.fpl_clean as
    select 
        variable as category,
        substr(NAME, 7) as ZCTA,
        'FPL_GROUP' as INDICATOR,
        estimate as ESTIMATE
    from work.fpl;

    create table work.healthinscoverage_clean as
    select 
        variable as category,
        substr(NAME, 7) as ZCTA,
        'INSURANCE_TYPE_GROUP' as INDICATOR,
        estimate as ESTIMATE
    from work.healthinscoverage;

    create table work.language_clean as
    select 
        variable as category,
        substr(NAME, 7) as ZCTA,
        'LANGUAGE_GROUP' as INDICATOR,
        estimate as ESTIMATE
    from work.language;
quit;

/* 2. Append all cleaned tables into one census table */
proc sql;
    create table work.census_clean as
    select * from work.agesex_clean
    union all
    select * from work.race_clean
    union all
    select * from work.ethnicity_clean
    union all
    select * from work.fpl_clean
    union all
    select * from work.healthinscoverage_clean
    union all
    select * from work.language_clean;
quit;

/* 3. Filter ZIP-to-ZCTA crosswalk table for desired states */
proc sql;
    create table work.zip_filtered as
    select *
    from work.ziptozcta
    where STATE in ('CA','DC','MD','VA','PA');
quit;

/* 4. Merge census with ZIP crosswalk and add DATA_STREAM and COALITION */
proc sql;
    create table work.census_final as
    select 
        c.*,
        z.state,
        'CensusDataset' as DATA_STREAM,
        case 
            when z.state = 'CA' then 'CA Coalition'
            when z.state = 'DC' then 'DC Coalition'
            else ''
        end as COALITION
    from work.census_clean as c
    left join work.zip_filtered as z
    on c.ZCTA = z.zcta
    where not missing(c.ZCTA) 
      and not missing(c.ESTIMATE);
quit;
