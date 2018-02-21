- dashboard: test
  title: test
  layout: newspaper
  elements:
  - title: New Tile
    name: New Tile
    model: the_look
    explore: order_items
    type: looker_line
    fields:
    - order_items.total_sale_price
    - order_items.created_month_name
    - order_items.created_year
    pivots:
    - order_items.created_year
    filters:
      order_items.created_date: 5 years
      products.category: Jeans
    sorts:
    - order_items.created_year asc
    - order_items.created_month_name asc
    limit: 500
    column_limit: 15
    query_timezone: America/Los_Angeles
    stacking: normal
    legend_position: right
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    show_x_axis_label: true
    show_x_axis_ticks: true
    show_null_points: false
    interpolation: monotone
    colors:
    - "#5245ed"
    - "#ff8f95"
    - "#1ea8df"
    - "#353b49"
    - "#49cec1"
    - "#b3a0dd"
    - "#db7f2a"
    - "#706080"
    - "#a2dcf3"
    - "#776fdf"
    - "#e9b404"
    - "#635189"
    x_axis_label: Month Name
    row: 0
    col: 0
    width: 24
    height: 9
