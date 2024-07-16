view: details_olympic {
  extension: required

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}.discipline ;;
  }
}
