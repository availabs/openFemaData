UPDATE severe_weather_open_fema_data_merge.disaster_summaries_merge_without_hazard_type_2 dst
set total_loss = coalesce(ihp_verified_loss, 0) + coalesce(project_amount, 0) + coalesce(sba_loss, 0) +
                 coalesce(nfip, 0) + coalesce(usda_crop_damage, 0)

