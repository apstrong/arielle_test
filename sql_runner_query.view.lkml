explore: sql_runner_query {}
view: sql_runner_query {
  derived_table: {
    sql: SELECT CASE WHEN sale_price <20 THEN 'Chicago, Illinois' ELSE 'Santiago, Chile' END as location, * FROM public.order_items LIMIT 10
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: location_no_html {
    type: string
    sql: ${TABLE}.location ;;
  }

  measure: location_list {
    type: list
    list_field: location_no_html
  }

  measure: location_list_or_other {
    type: string
    sql: ${location_list} ;;
    html: {% if sql_runner_query.location._is_filtered %} {{ location_list._value }} {% else %} Other {% endif %} ;;
  }

  dimension: id {
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: returned_at {
    type: time
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped_at {
    type: time
    sql: ${TABLE}.shipped_at ;;
  }

  dimension_group: delivered_at {
    type: time
    sql: ${TABLE}.delivered_at ;;
  }

  set: detail {
    fields: [
      location,
      id,
      order_id,
      user_id,
      inventory_item_id,
      sale_price,
      status,
      created_at_time,
      returned_at_time,
      shipped_at_time,
      delivered_at_time
    ]
  }
}
