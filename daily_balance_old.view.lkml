explore: daily_balance_old {}
view: daily_balance_old {
#   sql_table_name: example_test.daily_balance_live ;;
derived_table: {
  sql: SELECT * FROM example_test.daily_balance_live ;;
  persist_for: "1 hours"
}

# ACCOUNT

  dimension: account {
    view_label: "Account"
    type: number
    sql: ${TABLE}.account ;;
  }

# DAILY

  dimension: date_date {
    label: "Date"
    type: date
    view_label: "Daily"
    sql: ${date_raw} ;;
  }
  measure: end_of_day_balance {
    view_label: "Daily"
    type: sum
    sql: ${balance} ;;
  }

# WEEKLY

  dimension: date_week {
    label: "Week"
    type: date_week
    view_label: "Weekly"
    sql: ${date_raw} ;;
  }
  measure: end_of_week_balance {
    view_label: "Weekly"
    type: sum
    sql: CASE WHEN ${end_of_week} THEN ${balance} END ;;
    drill_fields: [account, date_date, end_of_day_balance]
  }

#   MONTHLY

  dimension: date_month {
    label: "Month"
    type: date_month
    view_label: "Monthly"
    sql: ${date_raw} ;;
  }
  measure: end_of_month_balance {
    view_label: "Monthly"
    type: sum
    sql: CASE WHEN ${end_of_month} THEN ${balance} END ;;
    drill_fields: [account, date_date, end_of_day_balance]
  }

#   QUARTERLY

  dimension: date_quarter {
    label: "Quarter"
    type: date_quarter
    view_label: "Quarterly"
    sql: ${date_raw} ;;
  }
  measure: end_of_quarter_balance {
    view_label: "Quarterly"
    type: sum
    sql: CASE WHEN ${end_of_quarter} THEN ${balance} END ;;
    drill_fields: [account, date_month, end_of_month_balance]
  }

# YEARLY

  dimension: date_year {
    label: "Year"
    type: date_year
    view_label: "Yearly"
    sql: ${date_raw} ;;
  }
  measure: end_of_year_balance {
    view_label: "Yearly"
    type: sum
    sql: CASE WHEN ${end_of_year} THEN ${balance} END ;;
    drill_fields: [account, date_month, end_of_month_balance]
  }

# HIDDEN

  dimension_group: date_plus_1 {
    hidden: yes
    type: time
    sql: CAST(DATE_ADD(${date_date}, INTERVAL 1 day) as timestamp) ;;
  }

  dimension: end_of_week {
    hidden: yes
    view_label: "Weekly"
    type: yesno
    sql: ${date_week} != ${date_plus_1_week} ;;
  }

  dimension: end_of_month {
    hidden: yes
    view_label: "Monthly"
    type: yesno
    sql: ${date_month} != ${date_plus_1_month} ;;
  }

  dimension: end_of_quarter {
    hidden: yes
    view_label: "Quarter"
    type: yesno
    sql: ${date_quarter} != ${date_plus_1_quarter} ;;
  }

  dimension: end_of_year {
    hidden: yes
    view_label: "Year"
    type: yesno
    sql: ${date_year} != ${date_plus_1_year} ;;
  }

  dimension: balance {
    hidden: yes
    type: number
    value_format_name: usd
    sql: ${TABLE}.balance ;;
  }

  dimension: date_raw {
    hidden: yes
    type: date_raw
    sql: CAST(${TABLE}.date as timestamp) ;;
  }












}