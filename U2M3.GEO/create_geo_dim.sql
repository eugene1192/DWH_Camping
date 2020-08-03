--DROP TABLE u_dw_dim_tax.dim_geo_obj_scd;
CONNECT pdbadm_evrublevskiy / adm08#evrublevskiy
TRUNCATE TABLE u_dw_dim_tax.dim_geo_obj_scd;
CREATE TABLE u_dw_dim_tax.dim_geo_obj_scd (
    dim_geo_id              VARCHAR2(40),
    geo_code                NVARCHAR2(10),
    obj_geo_sys_id          NUMBER,
    cnt_child_geo_sys       NUMBER,
    geo_system_id           NUMBER,
    geo_system_code         NVARCHAR2(30),
    geo_system_desc         NVARCHAR2(100),
    obj_geo_parts_id        NUMBER,
    cnt_child_geo_parts     NUMBER,
    part_id                 NUMBER,
    part_code               NVARCHAR2(20),
    part_desc               NVARCHAR2(100),
    obj_geo_regions_id      NUMBER,
    cnt_child_geo_regions   NUMBER,
    region_id               NUMBER,
    region_code             NVARCHAR2(30),
    region_desc             NVARCHAR2(100),
    obj_geo_country_id      NUMBER,
    country_id              NUMBER,
    country_desc            NVARCHAR2(100),
    country_code_a2         NVARCHAR2(10),
    country_code_a3         NVARCHAR2(20),
    obj_cntr_group_systems  NUMBER,
    grp_system_id           NUMBER,
    grp_system_code         NVARCHAR2(20),
    grp_system_desc         NVARCHAR2(100),
    obj_cntr_groups         NUMBER,
    group_id                NUMBER,
    group_code              NVARCHAR2(20),
    group_desc              NVARCHAR2(100),
    obj_cntr_sub_groups     NUMBER,
    sub_group_id            NUMBER,
    sub_group_code          NVARCHAR2(20),
    sub_group_desc          NVARCHAR2(100)
);

ALTER TABLE u_dw_dim_tax.dim_geo_obj_scd ADD (
    CONSTRAINT uk_dim_geo_id UNIQUE ( dim_geo_id )
);

INSERT INTO u_dw_dim_tax.dim_geo_obj_scd
    WITH cte_geo AS (
        SELECT
            level                                        AS levl,
            CONNECT_BY_ROOT parent_geo_id                root,
            PRIOR parent_geo_id                          parentall,
            parent_geo_id,
            child_geo_id,
            CONNECT_BY_ISLEAF                            AS isleaf,
            sys_connect_by_path(child_geo_id, '->')      AS path
        FROM
            u_dw_references.t_geo_object_links
        CONNECT BY
            PRIOR child_geo_id = parent_geo_id
        ORDER SIBLINGS BY
            link_type_id
    )
    SELECT
        sys_guid()                                dim_geo_id,
        'geo_system'                              code,
        nvl(a.root, - 1)                          t_geo_sys_id,
        COUNT(a.parentall)
        OVER(PARTITION BY a.root)                 child_geo_sys,
        nvl(gs.geo_system_id, - 1)                geo_system_id,
        nvl(gs.geo_system_code, 'n/a')            geo_system_code,
        nvl(gs.geo_system_desc, 'n/a')            geo_system_desc,
        nvl(a.parentall, - 1)                     t_geo_parts_id,
        COUNT(a.parent_geo_id)
        OVER(PARTITION BY a.parentall)            child_geo_parts,
        nvl(gp.part_id, - 1)                      part_id,
        nvl(gp.part_code, 'n/a')                  part_code,
        nvl(gp.part_desc, 'n/a')                  part_desc,
  --  nvl(gp.localization_id, 0)               localization_id,
            nvl(a.parent_geo_id, - 1)                 t_geo_regions_id,
        COUNT(a.child_geo_id)
        OVER(PARTITION BY a.parent_geo_id)        child_geo_regions,
        nvl(gr.region_id, - 1)                    region_id,
        nvl(gr.region_code, 'N/a')                region_code,
        nvl(gr.region_desc, 'N/a')                region_desc,
   -- nvl(gr.localization_id, 0)               localization_id,
            nvl(a.child_geo_id, - 1)                  a_t_country,
        nvl(cnt.country_id, - 1)                  country_id,
        nvl(cnt.country_desc, 'n/a')              country_desc,
        nvl(cnt.country_code_a2, 'n/a')           country_code_a2,
        nvl(cnt.country_code_a3, 'n/a')           country_code_a3,
        nvl(b.root, - 1)                          t_cntr_group_systems,
        nvl(cntgps.grp_system_id, - 1)            grp_system_id,
        nvl(cntgps.grp_system_code, 'n/a')        grp_system_code,
        nvl(cntgps.grp_system_desc, 'n/a')        grp_system_desc,
        nvl(b.parentall, - 1)                     t_cntr_groups,
        nvl(cntgp.group_id, - 1)                  group_id,
        nvl(cntgp.group_code, 'n/a')              group_code,
        nvl(cntgp.group_desc, 'n/a')              group_desc,
        nvl(b.parent_geo_id, - 1)                 t_cntr_sub_groups,
        nvl(cntsgp.sub_group_id, - 1)             sub_group_id,
        nvl(cntsgp.sub_group_code, 'n/a')         sub_group_code,
        nvl(cntsgp.sub_group_desc, 'n/a')         sub_group_desc
  --  , b.child_geo_id b_t_country
    
    FROM
        (
            (
                SELECT DISTINCT
                    *
                FROM
                    cte_geo
                WHERE
                        root = 447
                    AND isleaf = 1
                    AND levl = 3
            )    a
            LEFT JOIN (
                SELECT DISTINCT
                    *
                FROM
                    cte_geo
                WHERE
                        root = 476
                    AND isleaf = 1
                    AND levl = 3
            )                                        b ON a.child_geo_id = b.child_geo_id
            JOIN u_dw_references.lc_geo_systems           gs ON a.root = gs.geo_id
            JOIN u_dw_references.lc_geo_parts             gp ON a.parentall = gp.geo_id
            JOIN u_dw_references.lc_geo_regions           gr ON a.parent_geo_id = gr.geo_id
            JOIN u_dw_references.lc_countries             cnt ON a.child_geo_id = cnt.geo_id
            JOIN u_dw_references.lc_cntr_group_systems    cntgps ON b.root = cntgps.geo_id
            JOIN u_dw_references.lc_cntr_groups           cntgp ON b.parentall = cntgp.geo_id
            JOIN u_dw_references.lc_cntr_sub_groups       cntsgp ON b.parent_geo_id = cntsgp.geo_id
        )
  --  ORDER by a.child_geo_id;
    UNION
    ( SELECT
        sys_guid()                               dim_geo_id,
        'geo_group'                              code,
        COUNT(x.parentall)
        OVER(PARTITION BY x.root)                child_geo_sys,
        nvl(x.root, - 1)                         t_geo_sys_id,
        nvl(gs1.geo_system_id, - 1)              geo_system_id,
        nvl(gs1.geo_system_code, 'n/a')          geo_system_code,
        nvl(gs1.geo_system_desc, 'n/a')          geo_system_desc,
        nvl(x.parentall, - 1)                    t_geo_parts_id,
        COUNT(x.parent_geo_id)
        OVER(PARTITION BY x.parentall)           child_geo_parts,
        nvl(gp1.part_id, - 1)                    part_id,
        nvl(gp1.part_code, 'n/a')                part_code,
        nvl(gp1.part_desc, 'n/a')                part_desc,
  --  nvl(gp.localization_id, 0)               localization_id,
            nvl(x.parent_geo_id, - 1)                t_geo_regions_id,
        COUNT(x.child_geo_id)
        OVER(PARTITION BY x.parent_geo_id)       child_geo_regions,
        nvl(gr1.region_id, - 1)                  region_id,
        nvl(gr1.region_code, 'N/a')              region_code,
        nvl(gr1.region_desc, 'N/a')              region_desc,
   -- nvl(gr.localization_id, 0)               localization_id,
            nvl(x.child_geo_id, - 1)                 a_t_country,
        nvl(cnt1.country_id, - 1)                country_id,
        nvl(cnt1.country_desc, 'n/a')            country_desc,
        nvl(cnt1.country_code_a2, 'n/a')         country_code_a2,
        nvl(cnt1.country_code_a3, 'n/a')         country_code_a3,
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
        ttt.t
    FROM
             (
            SELECT DISTINCT
                *
            FROM
                cte_geo
            WHERE
                    root = 447
                AND isleaf = 1
                AND levl = 3
        ) x
        JOIN u_dw_references.lc_geo_systems    gs1 ON x.root = gs1.geo_id
        JOIN u_dw_references.lc_geo_parts      gp1 ON x.parentall = gp1.geo_id
        JOIN u_dw_references.lc_geo_regions    gr1 ON x.parent_geo_id = gr1.geo_id
        JOIN u_dw_references.lc_countries      cnt1 ON x.child_geo_id = cnt1.geo_id
        CROSS JOIN (
            SELECT
                - 1     z,
                - 1     x,
                'n/a'   v,
                'n/a'   c,
                - 1     w,
                - 1     g,
                'n/a'   h,
                'n/a'   k,
                - 1     l,
                - 1     u,
                'n/a'   i,
                'n/a'   t
            FROM
                dual
        )   ttt
    );

SELECT
    *
FROM
    u_dw_dim_tax.dim_geo_obj_scd;