view: users {
  sql_table_name: users ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    tiers: [0, 10, 20, 30, 40, 50, 60, 70]
    style: integer
    sql: ${age} ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  measure: count {
    label: "Unique Users"
    type: count
    drill_fields: [detail*]
  }


  measure: average_age {
    type: average
    value_format_name: decimal_2
    sql: ${age} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [id, first_name, last_name, email, age, created_date, orders.count, order_items.count]
  }










################################################################
# A/B Test Example
################################################################

#   dimension: userid {
#     label: "User ID"
#     view_label: "A/B Testing"
#     sql: ${id} ;;
#   }
#
# # arbitrary split for purposes of this example
#   dimension: test_group {
#     view_label: "A/B Testing"
#     description: "Control or Experimental Group"
#     type: string
#     sql: CASE
#           WHEN left(${userid},1) <= 3 THEN 'Experimental'
#           ELSE 'Control'
#         END;;
#   }
#
# ######### test group counts #########
#   measure: number_of_users_control {
#     view_label: "A/B Testing"
#     group_label: "1. Sample Size"
#     description: "Number of users in the control group"
#     type: count_distinct
#     sql: ${userid} ;;
#     filters: {
#       field: test_group
#       value: "Control"
#     }
#   }
#
#   measure: number_of_users_experimental {
#     view_label: "A/B Testing"
#     group_label: "1. Sample Size"
#     description: "Number of users in the experimental group"
#     type: count_distinct
#     sql: ${userid} ;;
#     filters: {
#       field: test_group
#       value: "Experimental"
#     }
#   }
#
#
# ######### variable of interest #########
# # in this example, the metric being measured is lifetime orders of our different user groups
#   measure: average_lifetime_orders_control {
#     view_label: "A/B Testing"
#     group_label: "2. Outcome"
#     description: "Average lifetime orders of users from the control group"
#     type: average
#     sql: ${user_order_facts.lifetime_orders} ;;
#     filters: {
#       field: test_group
#       value: "Control"
#     }
#     value_format_name: decimal_2
#   }
#
#   measure: average_lifetime_orders_experimental {
#     view_label: "A/B Testing"
#     group_label: "2. Outcome"
#     description: "Average lifetime orders of users from the experimental group"
#     type: average
#     sql: ${user_order_facts.lifetime_orders} ;;
#     filters: {
#       field: test_group
#       value: "Experimental"
#     }
#     value_format_name: decimal_2
#   }
#
# ######### standard deviation, t score, and significance calculations #########
# # t-test is used in this example because the metric being measured is a mean
# # chi squared could also be used - see this example: https://discourse.looker.com/t/simplified-a-b-test-analysis-redshift-python-udf-and-p-value-measure/2635
#
#   measure: stdev_control {
#     view_label: "A/B Testing"
#     group_label: "3. Stats"
#     type: number
#     sql: 1.0 * STDDEV_SAMP(CASE WHEN ${test_group} = 'Control' THEN ${user_order_facts.lifetime_orders} ELSE NULL END);;
#     value_format_name: decimal_2
#   }
#
#   measure: stdev_experimental {
#     view_label: "A/B Testing"
#     group_label: "3. Stats"
#     type: number
#     sql: 1.0 * STDDEV_SAMP(CASE WHEN ${test_group} = 'Experimental' THEN ${user_order_facts.lifetime_orders} ELSE NULL END);;
#     value_format_name: decimal_2
#   }
#
#   measure: t_score {
#     view_label: "A/B Testing"
#     group_label: "3. Stats"
#     type: number
#     sql: 1.0 * (${average_lifetime_orders_control} - ${average_lifetime_orders_experimental}) /
#           SQRT(
#             (POWER(${stdev_control},2) / ${number_of_users_control}) + (POWER(${stdev_experimental},2) / ${number_of_users_experimental})
#           ) ;;
#     value_format_name: decimal_2
#   }
#
#   measure: significance_level{
#     view_label: "A/B Testing"
#     group_label: "3. Stats"
#     sql: CASE
#           WHEN (ABS(${t_score}) > 3.291) THEN '.0005'
#           WHEN (ABS(${t_score}) > 3.091) THEN '.001'
#           WHEN (ABS(${t_score}) > 2.576) THEN '.005'
#           WHEN (ABS(${t_score}) > 2.326) THEN '.01'
#           WHEN (ABS(${t_score}) > 1.960) THEN '.025'
#           WHEN (ABS(${t_score}) > 1.645) THEN '.05'
#           WHEN (ABS(${t_score}) > 1.282) THEN '.1'
#           ELSE 'Insignificant'
#         END ;;
#   }
#
#   measure: significant {
#     view_label: "A/B Testing"
#     group_label: "3. Stats"
#     type: yesno
#     sql: ${significance_level} <> 'Insignificant' ;;
#   }

















}
