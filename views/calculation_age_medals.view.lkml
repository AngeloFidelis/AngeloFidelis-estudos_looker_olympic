view: calculations_age_medals {
  derived_table: {
    persist_for: "24 hours"
    sql: SELECT
        athletes.id,
        athletes.age,
        COUNT(medals.medal_type) AS medal_count
      FROM `lookerstudylab.olympic_looker_dataset.athletes` AS athletes
      INNER JOIN `lookerstudylab.olympic_looker_dataset.medals` AS medals
      ON athletes.id = medals.id_athlete
      GROUP BY athletes.id, athletes.age ;;
  }

  parameter: select_operation {
    type: unquoted
    default_value: "ce"
    allowed_value: {
      label: "Standard Deviation"
      value: "sd"
    }
    allowed_value: {
      label: "Correlation"
      value: "cn"
    }
    allowed_value: {
      label: "Covariance"
      value: "ce"
    }
  }

  dimension: id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    hidden: yes
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: medal_count {
    hidden: yes
    type: number
    sql: ${TABLE}.medal_count ;;
  }

  measure: calculation {
    label_from_parameter: select_operation
    type: number
    sql:
      {% if select_operation._parameter_value == 'sd' %}
        ${standard_deviation}
      {% elsif select_operation._parameter_value == 'cn' %}
        ${correlation_age_medal}
      {% else %}
        ${covariance}
      {% endif %}
    ;;
  }
  measure: title_dynamic_calculation {
    sql: ${calculation} ;;
    html:
      <a>
        {% if select_operation._parameter_value == 'sd' %}
          Standard Deviation
        {% elsif select_operation._parameter_value == 'cn' %}
          Correlation
        {% else %}
          Covariance
        {% endif %}
      </a>
    ;;
  }

  measure: standard_deviation {
    description: "statistical measure that quantifies the dispersion or variability of a data set relative to its mean"
    type: number
    sql: STDDEV_SAMP(${age}) ;;
    value_format: "#.##"
  }

  measure: correlation_age_medal {
    description: "measures the strength and direction of the linear relationship between two variables"
    type: number
    sql: CORR(${medal_count}, ${age}) ;;
    value_format: "#.##"
  }

  measure: covariance {
    description: "measures the direction of the linear relationship between two variables, but unlike correlation, it is not standardized. This means that covariance can take on any value and its interpretation depends on the units of the variables involved."
    type: number
    sql: COVAR_SAMP(${medal_count}, ${age}) ;;
    value_format: "#.##"
  }
}
