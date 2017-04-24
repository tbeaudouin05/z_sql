SELECT wa.venture_code,
       wa.buying_planning_cat_type as "Category - WSSI",
       (CASE
            WHEN wa.buying_department = '01)Regional PL' THEN 'RPL'
            WHEN wa.buying_department = '02)Regional Brand Outright' THEN 'RBO'
            WHEN wa.buying_department = '03)Regional Brand Consignment' THEN 'RBC'
            WHEN wa.buying_department = '04)Local PL' THEN 'LBO'
            WHEN wa.buying_department = '05)Local Brand Outright' THEN 'LBO'
            WHEN wa.buying_department = '06)Local Brand Consignment' THEN 'LBC'
            WHEN wa.buying_department = '07)Regional Brand Crosslisting' THEN 'RBO'
            WHEN wa.buying_department = '08)Local Brand Crosslisting' THEN 'LBO'
            WHEN wa.buying_department = '09)Others' THEN 'MP'
            WHEN wa.buying_department ='10)MP' THEN 'MP'
            WHEN wa.buying_department ='11)X-Dock or Dropshipping' THEN 'MP'
            ELSE 'MP'
        END) AS "Department",
       wa.sub_category_type,
       wa.brand_name,
       wa.sku_config,
       wa.image_url,
       sum(coalesce(wa.items_sold,0)-coalesce(wa.cxl_items_sold,0)-coalesce(wa.rtn_items_sold,0)) as "net_items_sold",
       sum(case when wa.start_date::datetime = dateadd('week',-1, date_trunc('week',current_date)) then wa.current_stock else 0 end) as "current_stock",
       sum(case when wa.start_date::datetime = dateadd('week',-1, date_trunc('week',current_date)) then coalesce(wa.nmv_lcy,0) else 0 end) as "nmv_lcy",
       sum(case when wa.start_date::datetime = dateadd('week',-1, date_trunc('week',current_date)) then wa.impressions else 0 end) as "impressions",
       sum(coalesce(wa.nmv_lcy,0)-coalesce(wa.cxl_nmv_lcy,0)-coalesce(wa.rtn_nmv_lcy,0)) as "net_total_nmv_lcy",
       sum(case when wa.start_date::datetime = dateadd('week',-1, date_trunc('week',current_date)) then coalesce(wa.nmv_lcy,0)-coalesce(wa.cxl_nmv_lcy,0)-coalesce(wa.rtn_nmv_lcy,0) else 0 end) as "net_nmv_lcy",
       sum(case when wa.start_date::datetime = dateadd('week',-1, date_trunc('week',current_date)) then coalesce(wa.gmv_lcy,0)-coalesce(wa.cxl_gmv_lcy,0)-coalesce(wa.rtn_gmv_lcy,0) - (coalesce(wa.gmv_amd_lcy,0)-coalesce(wa.cxl_gmv_amd_lcy,0)-coalesce(wa.rtn_gmv_amd_lcy,0)) else 0 end) as "net_md_lcy",
       sum(case when wa.start_date::datetime = dateadd('week',-1, date_trunc('week',current_date)) then wa.rrp_lcy else 0 end) as "rrp_lcy",
       sum(case when wa.start_date::datetime = dateadd('week',-1, date_trunc('week',current_date)) then wa.crp_lcy else 0 end) as "crp_lcy",
       dateadd('week',-1, date_trunc('week',current_date)) as "week"
FROM buying.weekly_agg as wa
Join
(select distinct
venture_code,
sku_config
from buying.weekly_agg
where coalesce(current_stock,0)>0 and 
Current_date - interval '365 days' >= start_date) sl
on wa.venture_code = sl.venture_code and wa.sku_config = sl.sku_config
where is_visible=1 and wa.venture_code not in ('vn','th') 
GROUP BY 1,
         2,
         3,
         4,
         5,
         6,
         7