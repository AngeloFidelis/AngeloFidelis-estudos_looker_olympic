include: details_olympic.view
view: athletes {
  extends: [details_olympic]
  sql_table_name: `olympic_looker_dataset.athletes` ;;
  drill_fields: [id]

  parameter: select_by_birth {
    type: unquoted
    allowed_value: {
      label: "Date"
      value: "d"
    }
    allowed_value: {
      label: "Weekly"
      value: "w"
    }
    allowed_value: {
      label: "Monthly"
      value: "m"
    }
    allowed_value: {
      label: "Quarterly"
      value: "q"
    }
    allowed_value: {
      label: "Yearly"
      value: "y"
    }
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
    html:
      {% if value < 18 %}
        <p style="font-size:0.8rem; padding: 2px 0 2px 0; color:white; background-color:#CD6155; text-align:center;">{{value}}</p>
      {% elsif value >=18 and value <60 %}
        <p style="font-size:0.8rem; padding: 2px 0 2px 0; color:white; background-color:#1D8348; text-align:center;">{{value}}</p>
      {% else %}
        <p style="font-size:0.8rem; padding: 2px 0 2px 0; color:white; background-color:#0C7BDC; text-align:center;">{{value}}</p>
      {% endif %}
    ;;
  }

  dimension: birth_country {
    type: string
    sql: ${TABLE}.birth_country ;;
  }

  dimension_group: birth {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.birth_date ;;
  }
  dimension: dynamic_birth {
    sql:
      {% if select_by_birth._parameter_value == "d" %}
        ${birth_date}
      {% elsif select_by_birth._parameter_value == "w" %}
        ${birth_week}
      {% elsif select_by_birth._parameter_value == "m" %}
        ${birth_month}
      {% elsif select_by_birth._parameter_value == "q" %}
        ${birth_quarter}
      {% else %}
        ${birth_year}
      {% endif %}
    ;;
  }

  dimension: birth_place {
    type: string
    sql: ${TABLE}.birth_place ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}.country_code ;;
  }

  dimension: discipline_code {
    type: string
    sql: ${TABLE}.discipline_code ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: height {
    type: number
    sql: CAST(SUBSTRING(${TABLE}.height, 1, 3) as INT64) ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    link: {
      label: "Google"
      url: "https://www.google.com/search?q={{ name }}"
      icon_url: "https://www.google.com/images/branding/product/ico/googleg_lodp.ico"
    }
  }

  dimension: residence_country {
    type: string
    sql: ${TABLE}.residence_country ;;
  }

  dimension: short_name {
    type: string
    sql: ${TABLE}.short_name ;;
  }

  ######################## edições ##########################

  measure: count {
    type: count
    drill_fields: [show_details*]
  }

  set: show_details {
    fields: [
      name,
      country,
      medals.medal_type,
      discipline,
      athletes.height,
      athletes.age
    ]
  }

  dimension: age_tier {
    type: tier
    tiers: [18, 25, 35, 45, 55, 65]
    style: integer
    sql: ${age} ;;
  }

  dimension: age_diff {
    type: number
    sql: DATE_DIFF(CURRENT_DATE, ${birth_date},YEAR) ;;
  }

  measure: avg_age {
    type: average
    sql: ${age} ;;
    value_format: "##.##"
  }
  measure: avg_height {
    type: average
    sql: ${height} ;;
    value_format: "##.##"
  }
}
