explore: dmt_sample {
  hidden: yes
  view_label: "Leads"
}

view: dmt_sample {
  sql_table_name: arielle.dmt_sample ;;

  dimension: dealer_group {
    type: string
    sql: ${TABLE}.Dealer_Group ;;
  }

  dimension: dealership {
    type: string
    sql: ${TABLE}.Dealership ;;
  }

  dimension: lead_arrival_time {
    type: string
    sql: ${TABLE}.Lead_Arrival_Time ;;
  }

  filter: date_group {
    label: "Date Granularity"
    description: "Do you want to see the x-axis by date, week, month, quarter, or year?"
    suggestions: ["Date","Week","Month","Quarter", "Year"]
  }

  dimension: dynamic_lead_date {
    label: "Date"
    description: "Dynamic axis"
    group_label: "Lead Date"
    sql: CASE
          WHEN {% parameter date_group %} = 'Date' THEN cast(${lead_date} as string)
          WHEN {% parameter date_group %} = 'Week' THEN cast(${lead_week} as string)
          WHEN {% parameter date_group %} = 'Month' THEN cast(${lead_month} as string)
          WHEN {% parameter date_group %} = 'Quarter' THEN cast(${lead_quarter} as string)
          WHEN {% parameter date_group %} = 'Year' THEN cast(${lead_year} as string)
          ELSE cast(${lead_date} as string)
        END ;;
  }

  dimension_group: lead {
    type: time
    timeframes: [
      raw,
      date,
      day_of_week,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Lead_Date ;;
  }


  dimension_group: lead_custom {
    label: " "
    group_label: "Lead Date"
    type: time
    timeframes: [hour_of_day, time]
    sql: cast(concat(cast(${TABLE}.Lead_Date as string), ' ', cast(${TABLE}.Lead_Arrival_Time as string)) as timestamp) ;;
  }

  dimension: lead_guid {
    hidden: yes
    type: string
    sql: ${TABLE}.Lead_Guid ;;
  }

  dimension: lead_name {
    type: string
    sql: ${TABLE}.Lead_Name ;;
  }

  dimension: lead_response {
    type: string
    sql: ${TABLE}.Lead_Response ;;
  }

  dimension: lead_source {
    type: string
    sql: ${TABLE}.Lead_Source ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.Make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.Model ;;
  }

  dimension: request_type {
    type: string
    sql: ${TABLE}.Request_Type ;;
  }

  dimension: response_score {
    type: number
    sql: ${TABLE}.Response_Score ;;
  }

  dimension: response_score_indicator {
    type: string
    sql: ${TABLE}.Response_Score_Indicator ;;
  }

  dimension: sales_person {
    type: string
    sql: ${TABLE}.Salesperson ;;
  }

  dimension: is_sold {
    type: yesno
    sql: ${TABLE}.Sold_ ;;
  }

  dimension: stock_type {
    type: string
    sql: ${TABLE}.Stock_Type ;;
  }

  dimension: time_to_respond_mins {
    type: number
    sql: ${TABLE}.Time_to_Respond__mins_ ;;
  }


  dimension: vehicle_year {
    type: number
    sql: ${TABLE}.Vehicle_Year ;;
  }

  measure: number_of_leads {
    type: count
    drill_fields: [lead_name, dealer_group, dealership, sales_person, time_to_respond_mins, vehicle_year, make, model]
  }

  measure: average_time_to_respond_minutes {
    type: average
    sql: ${time_to_respond_mins} ;;
    value_format_name: decimal_1
    drill_fields: [sales_person, average_time_to_respond_minutes_detail]
  }

  measure: number_of_leads_sold {
    type: count
    filters: {
      field: is_sold
      value: "Yes"
    }
  }

  measure: percent_sold {
    type: number
    sql: ${number_of_leads_sold} / CASE WHEN ${number_of_leads} = 0 THEN NULL ELSE ${number_of_leads} END;;
    value_format_name: percent_1
    drill_fields: [number_of_leads_sold, number_of_leads]
  }






















  measure: average_time_to_respond_minutes_detail {
    hidden: yes
    type: average
    sql: ${time_to_respond_mins} ;;
    value_format_name: decimal_1
    drill_fields: [lead_date, lead_name, dealership, dealer_group, request_type, sales_person, time_to_respond_mins]
  }



}
