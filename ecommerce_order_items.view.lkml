view: order_items {
  sql_table_name: order_items ;;
  ########## IDs, Foreign Keys, Counts ###########

  parameter: test {
    type: unquoted
    allowed_value: { label: "test" value: "{{ _user_attributes['citylist'] }}" }
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count_distinct
    sql: ${id} ;;
    drill_fields: [created_date, total_sale_price]
    link: {
      label: "Show as scatter plot"
      url: "
      {% assign vis_config = '{
  \"stacking\"                  : \"\",
  \"show_value_labels\"         : false,
  \"label_density\"             : 25,
  \"legend_position\"           : \"center\",
  \"x_axis_gridlines\"          : true,
  \"y_axis_gridlines\"          : true,
  \"show_view_names\"           : false,
  \"limit_displayed_rows\"      : false,
  \"y_axis_combined\"           : true,
  \"show_y_axis_labels\"        : true,
  \"show_y_axis_ticks\"         : true,
  \"y_axis_tick_density\"       : \"default\",
  \"y_axis_tick_density_custom\": 5,
  \"show_x_axis_label\"         : false,
  \"show_x_axis_ticks\"         : true,
  \"x_axis_scale\"              : \"auto\",
  \"y_axis_scale_mode\"         : \"linear\",
  \"show_null_points\"          : true,
  \"point_style\"               : \"circle\",
  \"ordering\"                  : \"none\",
  \"show_null_labels\"          : false,
  \"show_totals_labels\"        : false,
  \"show_silhouette\"           : false,
  \"totals_color\"              : \"#808080\",
  \"type\"                      : \"looker_scatter\",
  \"interpolation\"             : \"linear\",
  \"series_types\"              : {},
  \"colors\": [
    \"palette: Santa Cruz\"
  ],
  \"series_colors\"             : {},
  \"x_axis_datetime_tick_count\": null,
  \"trend_lines\": [
    {
      \"color\"             : \"#000000\",
      \"label_position\"    : \"left\",
      \"period\"            : 30,
      \"regression_type\"   : \"average\",
      \"series_index\"      : 1,
      \"show_label\"        : true,
      \"label_type\"        : \"string\",
      \"label\"             : \"30 day moving average\"
    }
  ]
}' %}
        {{ link }}&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis&limit=5000"
    }
  }

  measure: order_count {
    type: count_distinct
    drill_fields: [detail*]
    sql: ${order_id} ;;
  }


  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;


    action: {
      label: "Send this to slack channel"
      url: "https://hooks.zapier.com/hooks/catch/1662138/tvc3zj/"

      param: {
        name: "user_dash_link"
        value: "https://demo.looker.com/dashboards/160?Email={{ users.email._value}}"
      }

      form_param: {
        name: "Message"
        type: textarea
      }

      form_param: {
        name: "Recipient"
        type: select
        default: "zevl"
        option: {
          name: "zevl"
          label: "Zev"
        }
        option: {
          name: "slackdemo"
          label: "Slack Demo User"
        }

      }

      form_param: {
        name: "Channel"
        type: select
        default: "cs"
        option: {
          name: "cs"
          label: "Customer Support"
        }
        option: {
          name: "general"
          label: "General"
        }

      }


    }



  }

  ########## Time Dimensions ##########

  dimension_group: returned {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [date, week, month, raw]
    sql: ${TABLE}.shipped_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [date, week, month, raw]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: created {
    #X# group_label:"Order Date"
    type: time
    timeframes: [time, hour, date, week, month, month_name, year, hour_of_day, day_of_week, month_num, raw, week_of_year]
    sql: ${TABLE}.created_at ;;
  }

  dimension: reporting_period {
    group_label: "Order Date"
    sql: CASE
        WHEN date_part('year',${created_raw}) = date_part('year',current_date)
        AND ${created_raw} < CURRENT_DATE
        THEN 'This Year to Date'

        WHEN date_part('year',${created_raw}) + 1 = date_part('year',current_date)
        AND date_part('dayofyear',${created_raw}) <= date_part('dayofyear',current_date)
        THEN 'Last Year to Date'

      END
       ;;
  }

  dimension: days_since_sold {
    hidden: yes
    sql: datediff('day',${created_raw},CURRENT_DATE) ;;
  }

  dimension: months_since_signup {
    type: number
    sql: DATEDIFF('month',${users.created_raw},${created_raw}) ;;
  }

########## Logistics ##########

  dimension: status {
    sql: ${TABLE}.status ;;
  }

  dimension: days_to_process {
    type: number
    sql: CASE
        WHEN ${status} = 'Processing' THEN DATEDIFF('day',${created_raw},GETDATE())*1.0
        WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN DATEDIFF('day',${created_raw},${shipped_raw})*1.0
        WHEN ${status} = 'Cancelled' THEN NULL
      END
       ;;
  }

  dimension: shipping_time {
    type: number
    sql: datediff('day',${shipped_raw},${delivered_raw})*1.0 ;;
  }

  measure: average_days_to_process {
    type: average
    value_format_name: decimal_2
    sql: ${days_to_process} ;;
  }

  measure: average_shipping_time {
    type: average
    value_format_name: decimal_2
    sql: ${shipping_time} ;;
    drill_fields: [products.category, users.age_tier, average_shipping_time]
    link: { label: "See as custom viz (heatmap)"
      url: "
      {% assign vis_config = '{
      \"minColor\"              : \"#d6d6d6\",
      \"maxColor\"              : \"#9a33e3\",
      \"dataLabels\"            : false,
      \"custom_color_enabled\"  : false,
      \"custom_color\"          : \"forestgreen\",
      \"show_single_value_title\": true,
      \"show_comparison\"       : false,
      \"comparison_type\"       : \"value\",
      \"comparison_reverse_colors\": false,
      \"show_comparison_label\" : true,
      \"show_view_names\"       : true,
      \"show_row_numbers\"      : true,
      \"truncate_column_names\" : false,
      \"hide_totals\"           : false,
      \"hide_row_totals\"       : false,
      \"table_theme\"           : \"editable\",
      \"limit_displayed_rows\"  : false,
      \"enable_conditional_formatting\": false,
      \"conditional_formatting_include_totals\": false,
      \"conditional_formatting_include_nulls\": false,
      \"type\"                  : \"highcharts_heatmap\",
      \"stacking\"              : \"\",
      \"show_value_labels\"     : false,
      \"label_density\"         : 25,
      \"legend_position\"       : \"center\",
      \"x_axis_gridlines\"      : false,
      \"y_axis_gridlines\"      : true,
      \"y_axis_combined\"       : true,
      \"show_y_axis_labels\"    : true,
      \"show_y_axis_ticks\"     : true,
      \"y_axis_tick_density\"   : \"default\",
      \"y_axis_tick_density_custom\": 5,
      \"show_x_axis_label\"     : true,
      \"show_x_axis_ticks\"     : true,
      \"x_axis_scale\"          : \"auto\",
      \"y_axis_scale_mode\"     : \"linear\",
      \"ordering\"              : \"none\",
      \"show_null_labels\"      : false,
      \"show_totals_labels\"    : false,
      \"show_silhouette\"       : false,
      \"totals_color\"          : \"#808080\",
      \"series_types\"          : {},
      \"hidden_fields\"         : [
      \"order_items.count\",
      \"order_items.total_sale_price\"
      ]
      }' %}
      {{ link }}&vis_config={{ vis_config | encode_uri }}&sorts=products.category+asc,users.age_tier+asc&toggle=dat,pik,vis&limit=5000"
    }
  }

########## Financial Information ##########

  dimension: sale_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.sale_price ;;
  }

  dimension: gross_margin {
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  dimension: item_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    type: tier
    sql: 100*${item_gross_margin_percentage} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    style: interval
  }

  measure: total_sale_price {
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [total_sale_price, created_month_num, created_year]
    link: {
      label: "Show as stacked line"
      url: "
      {% assign vis_config = '{
  \"stacking\"              : \"normal\",
  \"show_value_labels\"     : false,
  \"label_density\"         : 25,
  \"legend_position\"       : \"right\",
  \"x_axis_gridlines\"      : false,
  \"y_axis_gridlines\"      : true,
  \"show_view_names\"       : false,
  \"limit_displayed_rows\"  : false,
  \"y_axis_combined\"       : true,
  \"show_y_axis_labels\"    : true,
  \"show_y_axis_ticks\"     : true,
  \"y_axis_tick_density\"   : \"default\",
  \"y_axis_tick_density_custom\": 5,
  \"show_x_axis_label\"     : true,
  \"show_x_axis_ticks\"     : true,
  \"x_axis_scale\"          : \"auto\",
  \"y_axis_scale_mode\"     : \"linear\",
  \"show_null_points\"      : false,
  \"point_style\"           : \"none\",
  \"interpolation\"         : \"monotone\",
  \"custom_color_enabled\"  : false,
  \"custom_color\"          : \"forestgreen\",
  \"show_single_value_title\": true,
  \"show_comparison\"       : false,
  \"comparison_type\"       : \"value\",
  \"comparison_reverse_colors\": false,
  \"show_comparison_label\" : true,
  \"type\"                  : \"looker_line\",
  \"ordering\"              : \"none\",
  \"show_null_labels\"      : false,
  \"show_totals_labels\"    : false,
  \"show_silhouette\"       : false,
  \"totals_color\"          : \"#808080\",
  \"series_types\": {},
  \"colors\": [
    \"#5245ed\",
    \"#ff8f95\",
    \"#1ea8df\",
    \"#353b49\",
    \"#49cec1\",
    \"#b3a0dd\",
    \"#db7f2a\",
    \"#706080\",
    \"#a2dcf3\",
    \"#776fdf\",
    \"#e9b404\",
    \"#635189\"
  ],
  \"series_colors\"         : {},
  \"x_axis_label\"          : \"Month Number\",
  \"swap_axes\"             : false
}' %}
        {{ link }}&vis_config={{ vis_config | encode_uri }}&pivots=order_items.created_year&toggle=dat,pik,vis&limit=5000"
    } # NOTE the &pivots=
  }

  measure: total_gross_margin {
    type: sum
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [users.zip, total_gross_margin]
    link: { label: "Show on map"
      url: "
      {% assign vis_config = '{
  \"map_plot_mode\"             : \"points\",
  \"heatmap_gridlines\"         : false,
  \"heatmap_gridlines_empty\"   : false,
  \"heatmap_opacity\"           : 0.5,
  \"show_region_field\"         : true,
  \"draw_map_labels_above_data\": false,
  \"map_tile_provider\"         : \"positron\",
  \"map_position\"              : \"fit_data\",
  \"map_scale_indicator\"       : \"off\",
  \"map_pannable\"              : true,
  \"map_zoomable\"              : true,
  \"map_marker_type\"           : \"circle\",
  \"map_marker_icon_name\"      : \"default\",
  \"map_marker_radius_mode\"    : \"proportional_value\",
  \"map_marker_units\"          : \"meters\",
  \"map_marker_proportional_scale_type\": \"linear\",
  \"map_marker_color_mode\"     : \"fixed\",
  \"show_view_names\"           : false,
  \"show_legend\"               : true,
  \"quantize_map_value_colors\" : false,
  \"reverse_map_value_colors\"  : false,
  \"type\"                      : \"looker_map\",
  \"stacking\"                  : \"\",
  \"show_value_labels\"         : false,
  \"label_density\"             : 25,
  \"legend_position\"           : \"center\",
  \"x_axis_gridlines\"          : false,
  \"y_axis_gridlines\"          : true,
  \"limit_displayed_rows\"      : false,
  \"y_axis_combined\"           : true,
  \"show_y_axis_labels\"        : true,
  \"show_y_axis_ticks\"         : true,
  \"y_axis_tick_density\"       : \"default\",
  \"y_axis_tick_density_custom\": 5,
  \"show_x_axis_label\"         : true,
  \"show_x_axis_ticks\"         : true,
  \"x_axis_scale\"              : \"auto\",
  \"y_axis_scale_mode\"         : \"linear\",
  \"ordering\"                  : \"none\",
  \"show_null_labels\"          : false,
  \"show_totals_labels\"        : false,
  \"show_silhouette\"           : false,
  \"totals_color\"              : \"#808080\",
  \"series_types\"              : {}
}' %}
        {{ link }}&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis&limit=99999&applied_limit=5000"
    }
  }

  measure: average_sale_price {
    type: average
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: median_sale_price {
    type: median
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: average_gross_margin {
    type: average
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${total_gross_margin}/ NULLIF(${total_sale_price},0) ;;
  }

  measure: average_spend_per_user {
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price} / NULLIF(${users.count},0) ;;
  }

########## Return Information ##########

  dimension: is_returned {
    type: yesno
    sql: ${returned_raw} IS NOT NULL ;;
  }

  measure: returned_count {
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: is_returned
      value: "yes"
    }
    drill_fields: [detail*]
    link: {label: "Explore Top 20 Results" url: "{{ returned_count._link}}&sorts=order_items.sale_price+desc&limit=20" }
  }

  measure: returned_total_sale_price {
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: is_returned
      value: "yes"
    }
  }

  measure: return_rate {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${returned_count} / nullif(${count},0) ;;
    link: {label: "Explore Top 20 Results" url: "{{ returned_count._link}}&limit=20" }
  }




########## Sets ##########

  set: detail {
    fields: [id, order_id, status, created_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
  set: return_detail {
    fields: [id, order_id, status, created_date, returned_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
}
