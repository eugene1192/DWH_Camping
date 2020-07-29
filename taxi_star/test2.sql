WITH cte_geo AS ( 
SELECT 
    LEVEL AS levl
    , CONNECT_BY_ROOT parent_geo_id root
    , PRIOR parent_geo_id parentAll 
    , parent_geo_id
    , child_geo_id 
    , CONNECT_BY_ISLEAF as IsLeaf 
    , SYS_CONNECT_BY_PATH(child_geo_id, '->') As Path
FROM 
    u_dw_references.t_geo_object_links 
    CONNECT BY PRIOR child_geo_id=parent_geo_id
    ORDER SIBLINGS BY link_type_id   
)
SELECT
    nvl(a.root, - 1)                         t_geo_sys_id,
    nvl(gs.geo_system_id, - 1)               geo_system_id,
    nvl(gs.geo_system_code, 'n/a')           geo_system_code,
    nvl(gs.geo_system_desc, 'n/a')           geo_system_desc,
    nvl(a.parentall, - 1)                    t_geo_parts_id,
    nvl(gp.part_id, - 1)                     part_id,
    nvl(gp.part_code, 'n/a')                 part_code,
    nvl(gp.part_desc, 'n/a')                 part_desc,
  --  nvl(gp.localization_id, 0)               localization_id,
    nvl(a.parent_geo_id, - 1)                t_geo_regions_id,
    nvl(gr.region_id, - 1)                   region_id,
    nvl(gr.region_code, 'N/a')               region_code,
    nvl(gr.region_desc, 'N/a')               region_desc,
   -- nvl(gr.localization_id, 0)               localization_id,
    nvl(a.child_geo_id, - 1)                 a_t_country,
    nvl(cnt.country_id, - 1)                 country_id,
    nvl(cnt.country_desc, 'n/a')             country_desc,
    nvl(cnt.country_code_a2, 'n/a')          country_code_a2,
    nvl(cnt.country_code_a3, 'n/a')          country_code_a3,
    ttt.z,
    ttt.x,
    ttt.v,
    ttt.c,
    ttt.w,
    ttt.g,
    ttt.h,
    ttt.k,
    ttt.l,
    ttt.u,
    ttt.i,
    ttt.h     
FROM (
SELECT DISTINCT * FROM cte_geo 
    
    WHERE
            root = 447
            AND isleaf = 1
            AND levl = 3) x
            JOIN u_dw_references.lc_geo_systems gs1 ON x.root = gs1.geo_id
        JOIN u_dw_references.lc_geo_parts gp1 ON x.parentall = gp1.geo_id
        JOIN u_dw_references.lc_geo_regions gr1 ON x.parent_geo_id = gr1.geo_id
        JOIN u_dw_references.lc_countries cnt1 ON x.child_geo_id = cnt1.geo_id 
        cross join(select -1 z, -1 x, 'n/a' v, 'n/a' c, -1 w, -1 g, 'n/a' h, 'n/a' k,-1 l, -1 u,'n/a' i, 'n/a' h from dual ) ttt