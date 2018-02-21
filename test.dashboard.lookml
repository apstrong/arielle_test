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
    show_value_labels: false
    label_density: 25
    legend_position: right
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    show_null_points: false
    point_style: none
    interpolation: monotone
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
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
    series_colors: {}
    x_axis_label: Month Name
    swap_axes: false
    row: 0
    col: 0
    width: 24
    height: 9
