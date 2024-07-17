view: details_olympic {
  extension: required

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
    link: {
      label: "Google"
      url: "https://www.google.com/search?q={{ value }}"
      icon_url: "https://flagcdn.com/w320/{{ value | downcase | slice:0,2 }}.png"
    }
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}.discipline ;;
  }
}
